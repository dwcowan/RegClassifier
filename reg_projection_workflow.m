% Train and evaluate a projection head to improve retrieval/clustering
C = config();
reg.print_active_knobs(C);
if ~isfield(C,'knobs'), C.knobs = reg.load_knobs(); end
if isempty(gcp('nocreate')), parpool('threads'); end

% Load or build chunks/features as in main pipeline
docsT = reg.ingest_pdfs(C.input_dir);
chunksT = reg.chunk_text(docsT, C.chunk_size_tokens, C.chunk_overlap);

% Compute base embeddings
Ebase = reg.precompute_embeddings(chunksT.text, C);  % N x d

% Build weak labels (or use your existing predictions if you have them)
Yweak = reg.weak_rules(chunksT.text, C.labels);
Yboot = Yweak >= C.min_rule_conf;  % N x L logical

% Create training triplets
P = reg.build_pairs(Yboot, 'MaxTriplets', 150000);

% Train projection head
p = {'ProjDim', 384, 'Epochs', 5, 'BatchSize', 512, 'LR', 1e-3, 'Margin', 0.2};
if isfield(C.knobs,'Projection')
  if isfield(C.knobs.Projection,'ProjDim'), p{2} = C.knobs.Projection.ProjDim; end
  if isfield(C.knobs.Projection,'Epochs'),  p{4} = C.knobs.Projection.Epochs; end
  if isfield(C.knobs.Projection,'BatchSize'),p{6} = C.knobs.Projection.BatchSize; end
  if isfield(C.knobs.Projection,'LR'),      p{8} = C.knobs.Projection.LR; end
  if isfield(C.knobs.Projection,'Margin'),  p{10}= C.knobs.Projection.Margin; end
end
head = reg.train_projection_head(Ebase, P, p{:});

% Project embeddings
Eproj = reg.embed_with_head(Ebase, head);

% Evaluate retrieval at K (using weak labels as positives)
posSets = cell(size(Yboot,1),1);
for i = 1:size(Yboot,1)
    labs = Yboot(i,:);
    posSets{i} = find(any(Yboot(:,labs),2));
    posSets{i}(posSets{i}==i) = [];
end
[recall10, mAP] = reg.eval_retrieval(Eproj, posSets, 10);
fprintf('Retrieval: Recall@10=%.3f  mAP=%.3f\n', recall10, mAP);

% Evaluate clustering quality (purity proxy & silhouette)
S = reg.eval_clustering(Eproj, Yboot);
fprintf('Clustering: Purity=%.3f  Silhouette=%.3f\n', S.purity, S.silhouette);

% Optionally update hybrid search to use projected embeddings
[docsTok, vocab, Xtfidf] = reg.ta_features(chunksT.text);
searchIx = reg.hybrid_search(Xtfidf, Eproj, vocab); %#ok<NASGU>

% Save head for reuse
save('projection_head.mat','head','-v7.3');
