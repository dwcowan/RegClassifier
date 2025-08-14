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
            cfgRaw = obj.ConfigModel.load(); %#ok<NASGU>
            cfg = obj.ConfigModel.process([]); %#ok<NASGU>
            files = obj.PDFIngestModel.load(); %#ok<NASGU>
            docsT = obj.PDFIngestModel.process([]); %#ok<NASGU>
            chunksRaw = obj.TextChunkModel.load(); %#ok<NASGU>
            chunksT = obj.TextChunkModel.process([]); %#ok<NASGU>
            featuresRaw = obj.FeatureModel.load(); %#ok<NASGU>
            [features, embeddings, vocab] = obj.FeatureModel.process([]); %#ok<NASGU>
            projE = obj.ProjectionHeadModel.process([]); %#ok<NASGU>
            weakRaw = obj.WeakLabelModel.load(); %#ok<NASGU>
            [Yweak, Yboot] = obj.WeakLabelModel.process([]); %#ok<NASGU>
            clsRaw = obj.ClassifierModel.load(); %#ok<NASGU>
            [models, scores, thresholds, pred] = obj.ClassifierModel.process([]); %#ok<NASGU>
            searchRaw = obj.SearchIndexModel.load(); %#ok<NASGU>
            searchIx = obj.SearchIndexModel.process([]); %#ok<NASGU>
            dbRaw = obj.DatabaseModel.load(); %#ok<NASGU>
            obj.DatabaseModel.process([]);
            reportRaw = obj.ReportModel.load(); %#ok<NASGU>
            reportData = obj.ReportModel.process([]); %#ok<NASGU>
            obj.View.display(reportData);
        end
    end
end
