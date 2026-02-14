C = config();
% TODO: display active knobs once reg.print_active_knobs is implemented
if isempty(gcp('nocreate')), parpool('threads'); end

% A) Ingest PDFs (with OCR fallback) → document table
docsT = reg.ingest_pdfs(C.input_dir);   % columns: doc_id, path, text, meta

% B) Chunk documents → chunk table
chunksT = reg.chunk_text(docsT, C.chunk_size_tokens, C.chunk_overlap); % chunk_id, doc_id, text, start_idx, end_idx

% C) Features: TF-IDF bag + LDA topics + embeddings
[docsTok, vocab, Xtfidf] = reg.ta_features(chunksT.text);
bag = bagOfWords(docsTok);
numDocs = bag.NumDocuments;
% Handle LDA topic modeling (skip if disabled or insufficient data)
if isempty(C.lda_topics) || C.lda_topics <= 0
    % LDA disabled
    numTopics = 0;
else
    numTopics = min(C.lda_topics, numDocs);
    if numTopics < C.lda_topics
        warning('Reducing LDA topics from %d to %d due to limited documents', C.lda_topics, numTopics);
    end
end

if numTopics > 0
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

features = [Xtfidf, sparse(topicDist), E];

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


% D) Weak supervision → bootstrap training labels
Yweak = reg.weak_rules(chunksT.text, C.labels);
Yboot = Yweak >= C.min_rule_conf;

% E) Train and predict
models = reg.train_multilabel(features, Yboot, C.kfold);
[scores, thresholds, pred] = reg.predict_multilabel(models, features, Yboot); %#ok<NASGU>

% F) Hybrid search index
searchIx = reg.hybrid_search(Xtfidf, E, vocab); %#ok<NASGU>

% G) (Optional) DB
if C.db.enable
    conn = reg.ensure_db(C.db);
    reg.upsert_chunks(conn, chunksT, C.labels, pred, scores);
    if isstruct(conn) && isfield(conn,'sqlite'); close(conn.sqlite); end
    if exist('database.ODBCConnection','class') || exist('database.jdbc.connection','class'), close(conn); end
end

% H) Report
pdfPath = generate_reg_report(C.report_title, chunksT, C.labels, pred, scores, mdlLDA, vocab);
fprintf("Report ready: %s\n", pdfPath);
