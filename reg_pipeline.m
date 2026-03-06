C = config();
% TODO: display active knobs once reg.print_active_knobs is implemented
if isempty(gcp('nocreate')), parpool('threads'); end

% A) Ingest PDFs (with OCR fallback) → document table
docsT = reg.ingest_pdfs(C.input_dir);   % columns: doc_id, path, text, meta

% Validate ingested documents
if isempty(docsT) || height(docsT) == 0
    error('No documents found in %s. Please check input_dir path.', C.input_dir);
end
if all(strlength(docsT.text) == 0)
    error('All documents are empty. Check PDF extraction or input files.');
end

% B) Chunk documents → chunk table
chunksT = reg.chunk_text(docsT, C.chunk_size_tokens, C.chunk_overlap); % chunk_id, doc_id, text, start_idx, end_idx

% Validate chunks
if isempty(chunksT) || height(chunksT) == 0
    error('No chunks generated. Check chunk_size_tokens and document content.');
end

% C) Features: TF-IDF bag + LDA topics + embeddings
[docsTok, vocab, Xtfidf] = reg.ta_features(chunksT.text);

% Handle LDA topic modeling (skip if disabled or insufficient data)
if ~isempty(C.lda_topics) && C.lda_topics > 0
    bag = bagOfWords(docsTok);
    numTopics = min(C.lda_topics, bag.NumDocuments);
    if numTopics < C.lda_topics
        warning('Reducing LDA topics from %d to %d due to limited documents', C.lda_topics, numTopics);
    end
    mdlLDA = fitlda(bag, numTopics, 'Verbose',0);
    topicDist = transform(mdlLDA, bag);
else
    mdlLDA = [];
    topicDist = [];
end
try
    if strcmpi(C.embeddings_backend,'bert')
        E = reg.doc_embeddings_bert_gpu(chunksT.text);
    else
        E = reg.doc_embeddings_fasttext(chunksT.text, C.fasttext);
    end
catch ME
    warning('Embeddings fallback to fastText due to: %s', ME.message);
    E = reg.doc_embeddings_fasttext(chunksT.text, C.fasttext);
end

% If a trained projection head exists, project embeddings for better retrieval/clustering
if exist('projection_head.mat','file')
    S = load('projection_head.mat','head');
    try
        E = reg.embed_with_head(E, S.head);
        fprintf("Applied projection head to embeddings.\n");
    catch ME
        warning("Projection head present but could not be applied: %s", ME.message);
    end
end

if isempty(topicDist)
    features = [double(Xtfidf), double(E)];
else
    features = [double(Xtfidf), double(topicDist), double(E)];
end


% D) Weak supervision → bootstrap training labels
if isempty(C.labels) || all(strlength(C.labels) == 0)
    error('reg:pipeline:NoLabels', ...
        'No labels defined. Set "labels" in pipeline.json (e.g., ["IRB","Liquidity_LCR","AML_KYC"]).');
end
Yweak = reg.weak_rules(chunksT.text, C.labels);
Yboot = Yweak >= C.min_rule_conf;

% E) Train and predict
models = reg.train_multilabel(features, Yboot, C.kfold);
[scores, thresholds, pred] = reg.predict_multilabel(models, features, Yboot); %#ok<NASGU>

% F) Hybrid search index
searchIx = reg.hybrid_search(Xtfidf, E, vocab, 'EmbeddingBackend', string(C.embeddings_backend)); %#ok<NASGU>

% G) (Optional) DB
if C.db.enable
    conn = reg.ensure_db(C.db);
    try
        reg.upsert_chunks(conn, chunksT, C.labels, pred, scores);
    catch ME
        warning('reg:pipeline:DBError', 'DB upsert failed: %s', ME.message);
    end
    reg.close_db(conn);
end

% H) Report
pdfPath = generate_reg_report(C.report_title, chunksT, C.labels, pred, scores, mdlLDA, vocab);
fprintf("Report ready: %s\n", pdfPath);
