C = config();

% A) Ingest PDFs (with OCR fallback) → document table
docsT = reg.ingest_pdfs(C.input_dir);   % columns: doc_id, path, text, meta

% B) Chunk documents → chunk table
chunksT = reg.chunk_text(docsT, C.chunk_size_tokens, C.chunk_overlap); % chunk_id, doc_id, text, start_idx, end_idx

% C) Features: TF-IDF bag + LDA topics + embeddings
[docsTok, vocab, Xtfidf] = reg.ta_features(chunksT.text);
bag = bagOfWords(docsTok);
numTopics = min(C.lda_topics, bag.NumDocuments);
mdlLDA = fitlda(bag, numTopics, 'Verbose',0);
topicDist = transform(mdlLDA, bag);
E = reg.doc_embeddings_fasttext(chunksT.text, C.fasttext);

features = [Xtfidf, sparse(topicDist), E];

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
