classdef FineTuneController < reg.mvc.BaseController
    %FINETUNECONTROLLER Orchestrates encoder fine-tuning workflow.
    
    properties
        PDFIngestModel
        TextChunkModel
        WeakLabelModel
        FineTuneDataModel
        EncoderFineTuneModel
        EvaluationModel
    end
    
    methods
        function obj = FineTuneController(pdfModel, chunkModel, weakModel, dataModel, encoderModel, evalModel, view)
            obj@reg.mvc.BaseController(pdfModel, view);
            obj.PDFIngestModel = pdfModel;
            obj.TextChunkModel = chunkModel;
            obj.WeakLabelModel = weakModel;
            obj.FineTuneDataModel = dataModel;
            obj.EncoderFineTuneModel = encoderModel;
            obj.EvaluationModel = evalModel;
        end
        
        function run(obj)
            files = obj.PDFIngestModel.load(); %#ok<NASGU>
            docsT = obj.PDFIngestModel.process([]); %#ok<NASGU>
            chunksRaw = obj.TextChunkModel.load(); %#ok<NASGU>
            chunksT = obj.TextChunkModel.process([]); %#ok<NASGU>
            weakRaw = obj.WeakLabelModel.load(); %#ok<NASGU>
            [Yweak, Yboot] = obj.WeakLabelModel.process([]); %#ok<NASGU>
            tripletRaw = obj.FineTuneDataModel.load(); %#ok<NASGU>
            triplets = obj.FineTuneDataModel.process([]); %#ok<NASGU>
            netRaw = obj.EncoderFineTuneModel.load(); %#ok<NASGU>
            net = obj.EncoderFineTuneModel.process([]); %#ok<NASGU>
            evalRaw = obj.EvaluationModel.load(); %#ok<NASGU>
            metrics = obj.EvaluationModel.process([]); %#ok<NASGU>
            obj.View.display(metrics);
        end
    end
end
