classdef PipelineController < reg.mvc.BaseController
    %PIPELINECONTROLLER Orchestrates end-to-end pipeline flow.
    
    properties
        ConfigModel
        PDFIngestModel
        TextChunkModel
        FeatureModel
        ProjectionHeadModel
        WeakLabelModel
        ClassifierModel
        SearchIndexModel
        DatabaseModel
        ReportModel
    end
    
    methods
        function obj = PipelineController(cfgModel, pdfModel, chunkModel, featModel, projModel, weakModel, clsModel, searchModel, dbModel, reportModel, view)
            %PIPELINECONTROLLER Construct controller wiring the full pipeline.
            %   OBJ = PIPELINECONTROLLER(...) assembles all models and a view.
            %   Equivalent to setup in `reg_pipeline`.
            obj@reg.mvc.BaseController(cfgModel, view);
            obj.ConfigModel = cfgModel;
            obj.PDFIngestModel = pdfModel;
            obj.TextChunkModel = chunkModel;
            obj.FeatureModel = featModel;
            obj.ProjectionHeadModel = projModel;
            obj.WeakLabelModel = weakModel;
            obj.ClassifierModel = clsModel;
            obj.SearchIndexModel = searchModel;
            obj.DatabaseModel = dbModel;
            obj.ReportModel = reportModel;
        end

        function run(obj)
            %RUN Execute the end-to-end pipeline.
            %   Orchestrates ingestion, feature extraction, weak labeling,
            %   model training, indexing, persistence and reporting.
            %
            %   Preconditions
            %       * All model properties must be configured
            %       * Input directory and DB credentials defined in cfg
            %   Side Effects
            %       * Writes search index and classifier outputs to DB
            %       * Produces a final PDF/HTML report via view
            %
            %   Legacy mapping follows `reg_pipeline`:
            %       Step 2 ↔ `ingest_pdfs`
            %       Step 3 ↔ `chunk_text`
            %       Step 4 ↔ `ta_features` + embedding helpers
            %       Step 5 ↔ `embed_with_head`
            %       Step 6 ↔ `weak_rules`
            %       Step 7 ↔ `train_multilabel`/`predict_multilabel`
            %       Step 8 ↔ `hybrid_search`
            %       Step 9 ↔ `upsert_chunks`
            %       Step 10 ↔ `generate_reg_report`

            % Step 1: Retrieve configuration
            cfgRaw = obj.ConfigModel.load();
            cfg = obj.ConfigModel.process(cfgRaw);

            % Step 2: Ingest PDFs into documents table
            %   PDFIngestModel should verify file readability and handle OCR
            %   failures gracefully.
            %   Failure Modes
            %       * Input directory missing/empty resulting in dummy docs.
            %       * `extractFileText` errors or unusable OCR output.
            %   Mitigation
            %       * Warn or abort when no real documents found.
            %       * Retry extraction with OCR and allow caller to supply
            %         custom handlers for unreadable files.
            files = obj.PDFIngestModel.load(cfg);
            docsT = obj.PDFIngestModel.process(files);

            % Step 3: Chunk documents into text segments
            %   Relies on tokens/overlap parameters from cfg.
            chunksRaw = obj.TextChunkModel.load(docsT);
            chunksT = obj.TextChunkModel.process(chunksRaw);

            % Step 4: Extract features and embeddings
            %   FeatureModel expected to fall back (e.g., to fastText) if the
            %   preferred embedding backend fails.
            featuresRaw = obj.FeatureModel.load(chunksT);
            [features, embeddings, vocab] = obj.FeatureModel.process(featuresRaw); %#ok<NASGU>

            % Step 5: Apply projection head to embeddings
            %   Head model should validate dimensions of embeddings and warn
            %   if projection parameters are incompatible.
            projRaw = obj.ProjectionHeadModel.load(embeddings);
            projE = obj.ProjectionHeadModel.process(projRaw);

            % Step 6: Generate weak labels
            %   WeakLabelModel enforces label schema and handles rule errors.
            weakRaw = obj.WeakLabelModel.load(projE);
            [Yweak, Yboot] = obj.WeakLabelModel.process(weakRaw); %#ok<NASGU>

            % Step 7: Train classifiers and make predictions
            %   ClassifierModel should validate that Yweak is non-empty.
            clsRaw = obj.ClassifierModel.load(Yweak);
            [models, scores, thresholds, pred] = obj.ClassifierModel.process(clsRaw); %#ok<NASGU>

            % Step 8: Build search index
            %   SearchIndexModel must ensure vocabulary and embeddings align.
            searchRaw = obj.SearchIndexModel.load(pred);
            searchIx = obj.SearchIndexModel.process(searchRaw); %#ok<NASGU>

            % Step 9: Persist results to database
            %   DatabaseModel should handle connection errors and rollbacks.
            %   Failure Modes
            %       * Missing `lbl_*`/`score_*` columns causing ALTER TABLE calls.
            %       * Connection drops mid-transaction or conflicting writes.
            %   Mitigation
            %       * Validate schema before bulk upsert and wrap writes in a
            %         retryable transaction.
            %       * Surface partial failures so upstream steps can retry.
            dbRaw = obj.DatabaseModel.load(searchIx);
            dbResult = obj.DatabaseModel.process(dbRaw);

            % Step 10: Assemble report data and display
            %   ReportModel verifies that metrics and predictions are present
            %   before rendering.
            reportRaw = obj.ReportModel.load(dbResult);
            reportData = obj.ReportModel.process(reportRaw);
            obj.View.display(reportData);
        end
    end
end
