% Evaluate baseline vs projection head vs fine-tuned encoder and generate a PDF
% report including per-label recall and clustering quality metrics.
import mlreportgen.report.*
import mlreportgen.dom.*

C = config();
% TODO: display active knobs once reg.print_active_knobs is implemented
if isempty(gcp('nocreate')), parpool('threads'); end

% Data & labels
docsT = reg.ingest_pdfs(C.input_dir);
chunksT = reg.chunk_text(docsT, C.chunk_size_tokens, C.chunk_overlap);
Yweak = reg.weak_rules(chunksT.text, C.labels);
Yboot = Yweak >= C.min_rule_conf;

% Build posSets for IR metrics
N = height(chunksT);
posSets = cell(N,1);
for i = 1:N
    labs = find(Yboot(i,:));  % Get indices of true labels
    if ~isempty(labs)
        pos = find(any(Yboot(:,labs),2));
        pos(pos==i) = [];
        posSets{i} = pos;
    else
        posSets{i} = [];  % No positive labels for this chunk
    end
end

% --- Variant A: Baseline BERT embeddings ---
E_base = reg.precompute_embeddings(chunksT.text, struct('embeddings_backend','bert','fasttext',struct('language','en')));
S_base = E_base * E_base';
[recall10_base, mAP_base] = reg.eval_retrieval(E_base, posSets, 10);
ndcg10_base = reg.metrics_ndcg(S_base, posSets, 10);

% --- Variant B: Projection head (if present) ---
E_proj = [];
recall10_proj = NaN; mAP_proj = NaN; ndcg10_proj = NaN;
if isfile('projection_head.mat')
    S = load('projection_head.mat','head');
    E_proj = reg.embed_with_head(E_base, S.head);
    S_proj = E_proj * E_proj';
    [recall10_proj, mAP_proj] = reg.eval_retrieval(E_proj, posSets, 10);
    ndcg10_proj = reg.metrics_ndcg(S_proj, posSets, 10);
end

% --- Variant C: Fine-tuned encoder (if present) ---
E_ft = [];
recall10_ft = NaN; mAP_ft = NaN; ndcg10_ft = NaN;
if isfile('fine_tuned_bert.mat')
    S = load('fine_tuned_bert.mat','netFT');
    % Embed all with fine-tuned net (reuse helper from ft_eval)
    E_ft = local_embed_ft(chunksT.text, S.netFT);
    S_ft = E_ft * E_ft';
    [recall10_ft, mAP_ft] = reg.eval_retrieval(E_ft, posSets, 10);
    ndcg10_ft = reg.metrics_ndcg(S_ft, posSets, 10);
end

% --- Log metrics (optional) ---
runId = string(datetime('now','Format','yyyyMMdd_HHmmss'));
reg.log_metrics(runId, "baseline", struct('RecallAt10',recall10_base,'mAP',mAP_base,'nDCG_at_10',ndcg10_base), 'Epoch', 0);
if ~isnan(recall10_proj), reg.log_metrics(runId, "projection", struct('RecallAt10',recall10_proj,'mAP',mAP_proj,'nDCG_at_10',ndcg10_proj), 'Epoch', 0); end
if ~isnan(recall10_ft),   reg.log_metrics(runId, "finetuned",  struct('RecallAt10',recall10_ft,'mAP',mAP_ft,'nDCG_at_10',ndcg10_ft), 'Epoch', 0); end

% --- Report ---
r = Report('reg_eval_report','pdf');
append(r, TitlePage('Title', 'Retrieval & Clustering Evaluation'));
append(r, TableOfContents);

% Summary table
sec = Section('Summary');
T = table( ...
    ["Baseline (BERT)"; "Projection Head"; "Fine-Tuned Encoder"], ...
    [recall10_base; recall10_proj; recall10_ft], ...
    [mAP_base; mAP_proj; mAP_ft], ...
    [ndcg10_base; ndcg10_proj; ndcg10_ft], ...
    'VariableNames', {'Variant','RecallAt10','mAP','nDCG@10'});
append(sec, FormalTable(T));
append(r, sec);

% Optional: small IRB-focused slice (filter chunks containing PD/LGD/EAD)
maskIRB = contains(lower(chunksT.text), ["pd","lgd","ead","internal ratings based","irb"]);
if any(maskIRB)
    sec2 = Section('IRB PD/LGD/EAD Subset');
    idxIRB = find(maskIRB);
    posSetsIRB = posSets(idxIRB); %#ok<NASGU>
    % Score on whichever embedding is best available (ft > proj > base)
    if ~isempty(E_ft), E = E_ft; elseif ~isempty(E_proj), E = E_proj; else, E = E_base; end
    Ssub = E(idxIRB,:) * E';   % query IRB subset against full corpus
    % For simplicity compute Recall@10 on subset queries
    recIRB = zeros(numel(idxIRB),1);
    for k = 1:numel(idxIRB)
        i = idxIRB(k);
        s = Ssub(k,:);
        s(i) = -inf;
        [~, ord] = sort(s,'descend');
        topK = ord(1:min(10,numel(ord)));
        recIRB(k) = any(ismember(topK, posSets{i}));
    end
    append(sec2, Paragraph(sprintf('IRB subset Recall@10: %.3f', mean(recIRB))));
    append(r, sec2);
end

%% --- Gold Mini-Pack Metrics ---
try
    if isfolder("gold")
        G = reg.load_gold("gold");
        Cgold = C; Cgold.labels = G.labels;
        E_gold = reg.precompute_embeddings(G.chunks.text, Cgold);
        posSets_gold = cell(height(G.chunks),1);
        for gi=1:height(G.chunks)
            labs = G.Y(gi,:);
            pos = find(any(G.Y(:,labs),2)); pos(pos==gi) = [];
            posSets_gold{gi} = pos;
        end
        [recall10_g, mAP_g] = reg.eval_retrieval(E_gold, posSets_gold, 10);
        ndcg10_g = reg.metrics_ndcg(E_gold*E_gold.', posSets_gold, 10);
        per_g = reg.eval_per_label(E_gold, G.Y, 10);
        secG = Section('Gold Mini-Pack Metrics');
        Tgold = table(["Recall@10";"mAP";"nDCG@10"], [recall10_g; mAP_g; ndcg10_g], ...
                      'VariableNames', {'Metric','Value'});
        append(secG, FormalTable(Tgold));
        tblG2 = table(G.labels(:), per_g.RecallAtK, 'VariableNames', {'Label','RecallAt10'});
        append(secG, FormalTable(tblG2));
        append(r, secG);
    end
catch ME
    warning("Gold pack metrics section skipped: %s", ME.message);
end

% --- Generate trend chart if history exists ---
csvHist = fullfile("runs","metrics.csv");
if isfile(csvHist)
    trendsPNG = fullfile("runs","trends.png");
    reg.plot_trends(csvHist, trendsPNG);
    secTr = Section('Trends Across Runs/Checkpoints');
    append(secTr, Image(trendsPNG));
    append(r, secTr);
end

% --- Co-retrieval heatmap on best available embedding ---
if ~isempty(E_ft), Ebest = E_ft; elseif ~isempty(E_proj), Ebest = E_proj; else, Ebest = E_base; end
[Mcore, order] = reg.label_coretrieval_matrix(Ebest, Yboot, 10);
labelsStr = string(C.labels);
heatPNG = fullfile("runs","coretrieval_heatmap.png");
reg.plot_coretrieval_heatmap(Mcore(order,order), labelsStr(order), heatPNG);
secHM = Section('Label Co-Retrieval Heatmap (Top-10)');
append(secHM, Image(heatPNG));
append(r, secHM);

% --- Gold Mini-Pack (optional) ---
try
    if isfile(fullfile("gold","sample_gold_chunks.csv")) && ...
       isfile(fullfile("gold","sample_gold_labels.json")) && ...
       isfile(fullfile("gold","sample_gold_Ytrue.csv"))
        G = reg.load_gold("gold");
        % Embed with best available model
        Cg = config(); Cg.labels = G.labels;
        Eg = reg.precompute_embeddings(G.chunks.text, Cg);
        % Overall metrics on gold
        posSetsG = cell(height(G.chunks),1);
        for i=1:height(G.chunks)
            labs = G.Y(i,:);
            pos = find(any(G.Y(:,labs),2)); pos(pos==i) = [];
            posSetsG{i} = pos;
        end
        [recall10_g, mAP_g] = reg.eval_retrieval(Eg, posSetsG, 10);
        ndcg10_g = reg.metrics_ndcg(Eg*Eg.', posSetsG, 10);
        perG = reg.eval_per_label(Eg, G.Y, 10);
        % Add to report
        secG2 = Section('Gold Mini-Pack Evaluation');
        Tg = table(["Recall@10";"mAP";"nDCG@10"], [recall10_g; mAP_g; ndcg10_g], 'VariableNames', {'Metric','Value'});
        append(secG2, FormalTable(Tg));
        tblG = table(G.labels(:), perG.RecallAtK, 'VariableNames', {'Label','RecallAt10'});
        append(secG2, FormalTable(tblG));
        append(r, secG2);
    end
catch ME
    warning("Gold section skipped: %s", ME.message);
end

% --- Close report (after ALL appends) ---
close(r);
fprintf('Wrote evaluation report: %s\n', r.OutputPath);

function E = local_embed_ft(textStr, netFT)
tok = reg.init_bert_tokenizer();
textStr = string(textStr);
N = numel(textStr);
mb = 64;
E = zeros(N, 384, 'single');
for s = 1:mb:N
    e = min(N, s+mb-1);
    % R2025b: encode returns [tokenCodes, segments] as cell arrays, not struct
    [tokenCodes, ~] = encode(tok, textStr(s:e));
    % Manually pad sequences to maxLen (R2025b encode doesn't auto-pad)
    paddingCode = double(tok.PaddingCode);
    numSeqs = numel(tokenCodes);
    maxLen = netFT.MaxSeqLength;
    ids = paddingCode * ones(numSeqs, maxLen);  % Pre-fill with padding
    for i = 1:numSeqs
        seq = double(tokenCodes{i});
        len = min(numel(seq), maxLen);
        ids(i, 1:len) = seq(1:len);
    end
    mask = double(ids ~= paddingCode);  % Attention mask: 1 for real tokens, 0 for padding
    % Reshape to 3D (1, maxLen, N) 'CTB' format for BERT sequenceInputLayer (C=1)
    ids = dlarray(gpuArray(single(permute(ids, [3,2,1]))),'CTB');
    segs = dlarray(gpuArray(single(ones(1, maxLen, numSeqs))),'CTB');
    mask = dlarray(gpuArray(single(permute(mask, [3,2,1]))),'CTB');
    out = predict(netFT.base, ids, segs, mask);
    Z = localPooled(out);
    Z = predict(netFT.head, Z);
    Z = gather(extractdata(Z))';
    n = vecnorm(Z,2,2); n(n==0)=1; Z = Z ./ n;
    E(s:e,:) = single(Z);
end
end

function Z = localPooled(out)
if isstruct(out) && isfield(out,'pooledOutput')
    Z = dlarray(out.pooledOutput,'CB');
elseif isstruct(out) && isfield(out,'sequenceOutput')
    seq = out.sequenceOutput;
    if ndims(seq)==3
        % seq is (hidden, seqLen, batch) 'CTB'; extract CLS token (position 1)
        Z = squeeze(seq(:,1,:));  % (hidden, batch)
        Z = dlarray(Z,'CB');
    else
        Z = dlarray(seq,'CB');
    end
else
    Z = dlarray(out,'CB');
end
end
