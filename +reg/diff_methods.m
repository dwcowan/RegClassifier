function R = diff_methods(queries, chunksT, C)
%DIFF_METHODS Compare Top-K results across encoder variants for given queries.
% queries: string array
% chunksT: table with .text and (optionally) .doc_id/article_id
% C: config struct (will be copied and adjusted per variant)
K = 10;
R = struct();
variants = {'baseline','projection','finetuned'};
E = struct();

% Baseline
C1 = C; C1.embeddings_backend = 'bert';
E.baseline = reg.precompute_embeddings(chunksT.text, C1);

% Projection head (optional)
if isfile('projection_head.mat')
    S = load('projection_head.mat','head');
    E.projection = reg.embed_with_head(E.baseline, S.head);
end

% Fine-tuned (optional)
if isfile('fine_tuned_bert.mat')
    S = load('fine_tuned_bert.mat','netFT');
    % Re-embed using fine-tuned encoder
    E.finetuned = reg.doc_embeddings_bert_gpu(chunksT.text, 'UseFineTuned', true);
end

% Encode queries using each variant and compute Top-K
for v = fieldnames(E).'
    vn = v{1};
    Ev = E.(vn);
    S = Ev * Ev.';
    out = struct();
    for qi = 1:numel(queries)
        q = queries(qi);
        % naive query encoding by treating query as a mini-document
        Eq = reg.precompute_embeddings(string(q), C1);
        score = Eq * Ev.';
        [~, ord] = sort(score, 'descend');
        ord = ord(1:min(K,end));
        out(qi).query = q;
        out(qi).top_idx = ord;
        out(qi).top_text = chunksT.text(ord);
        if ismember('doc_id', chunksT.Properties.VariableNames)
            out(qi).doc_id = chunksT.doc_id(ord);
        end
    end
    R.(vn) = out;
end

% Write a simple CSV per variant
outDir = fullfile("runs","diff_methods"); if ~isfolder(outDir), mkdir(outDir); end
for v = fieldnames(R).'
    vn = v{1};
    csv = fullfile(outDir, "diff_" + vn + ".csv");
    fid = -1;
    try
        fid = fopen(csv,'w');
        if fid == -1
            error('Failed to open file for writing: %s', csv);
        end
        fprintf(fid,"query,rank,doc_id,text\n");
        D = R.(vn);
        for qi = 1:numel(D)
            for r = 1:numel(D(qi).top_idx)
                docid = ""; if isfield(D(qi),'doc_id') && numel(D(qi).doc_id)>=r, docid = D(qi).doc_id(r); end
                t = D(qi).top_text(r);
                fprintf(fid, ""%s",%d,"%s","%s"\n", D(qi).query, r, docid, replace(t, '"',''''));
            end
        end
    catch ME
        if fid ~= -1
            fclose(fid);
        end
        rethrow(ME);
    end
    if fid ~= -1
        fclose(fid);
    end
end
fprintf('Wrote method diffs to %s\n', outDir);
end
