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
            %   RUN(obj) performs ingestion, feature extraction, training,
            %   indexing, persistence and reporting. Equivalent to
            %   `reg_pipeline`.
            % Step 1: Retrieve configuration
            cfgRaw = obj.ConfigModel.load(); %#ok<NASGU>
            cfg = obj.ConfigModel.process(cfgRaw); %#ok<NASGU>

            % Step 2: Ingest PDFs into documents table
            files = obj.PDFIngestModel.load(cfg); %#ok<NASGU>
            docsT = obj.PDFIngestModel.process(files); %#ok<NASGU>

            % Step 3: Chunk documents into text segments
            chunksRaw = obj.TextChunkModel.load(docsT); %#ok<NASGU>
            chunksT = obj.TextChunkModel.process(chunksRaw); %#ok<NASGU>

            % Step 4: Extract features and embeddings
            featuresRaw = obj.FeatureModel.load(chunksT); %#ok<NASGU>
            [features, embeddings, vocab] = obj.FeatureModel.process(featuresRaw); %#ok<NASGU>

            % Step 5: Apply projection head to embeddings
            projRaw = obj.ProjectionHeadModel.load(embeddings); %#ok<NASGU>
            projE = obj.ProjectionHeadModel.process(projRaw); %#ok<NASGU>

            % Step 6: Generate weak labels
            weakRaw = obj.WeakLabelModel.load(projE); %#ok<NASGU>
            [Yweak, Yboot] = obj.WeakLabelModel.process(weakRaw); %#ok<NASGU>

            % Step 7: Train classifiers and make predictions
            clsRaw = obj.ClassifierModel.load(Yweak); %#ok<NASGU>
            [models, scores, thresholds, pred] = obj.ClassifierModel.process(clsRaw); %#ok<NASGU>

            % Step 8: Build search index
            searchRaw = obj.SearchIndexModel.load(pred); %#ok<NASGU>
            searchIx = obj.SearchIndexModel.process(searchRaw); %#ok<NASGU>

            % Step 9: Persist results to database
            dbRaw = obj.DatabaseModel.load(searchIx); %#ok<NASGU>
            dbResult = obj.DatabaseModel.process(dbRaw); %#ok<NASGU>

            % Step 10: Assemble report data and display
            reportRaw = obj.ReportModel.load(dbResult); %#ok<NASGU>
            reportData = obj.ReportModel.process(reportRaw); %#ok<NASGU>
            obj.View.display(reportData);
        end
    end
end
