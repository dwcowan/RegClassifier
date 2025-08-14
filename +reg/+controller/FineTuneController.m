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
            %FINETUNECONTROLLER Construct controller wiring models and view.
            obj@reg.mvc.BaseController(pdfModel, view);
            obj.PDFIngestModel = pdfModel;
            obj.TextChunkModel = chunkModel;
            obj.WeakLabelModel = weakModel;
            obj.FineTuneDataModel = dataModel;
            obj.EncoderFineTuneModel = encoderModel;
            obj.EvaluationModel = evalModel;
        end

        function triplets = buildTriplets(obj)
            %BUILDTRIPLETS Generate contrastive triplets via the data model.
            raw = obj.FineTuneDataModel.load();
            triplets = obj.FineTuneDataModel.process(raw);
        end

        function net = trainEncoder(obj, triplets) %#ok<INUSD>
            %TRAINENCODER Fine-tune encoder given triplets.
            raw = obj.EncoderFineTuneModel.load();
            net = obj.EncoderFineTuneModel.process(raw);
        end

        function metrics = evaluate(obj, net) %#ok<INUSD>
            %EVALUATE Compute evaluation metrics on fine-tuned encoder.
            raw = obj.EvaluationModel.load();
            metrics = obj.EvaluationModel.process(raw);
        end

        function saveModel(~, net, varargin)
            %SAVEMODEL Persist fine-tuned encoder to disk.
            if ~isempty(varargin)
                filename = varargin{1};
            else
                filename = "fine_tuned_encoder.mat";
            end
            save(filename, "net", "-v7.3");
        end

        function run(obj)
            %RUN Execute full fine-tuning workflow.
            triplets = obj.buildTriplets(); %#ok<NASGU>
            net = obj.trainEncoder(triplets); %#ok<NASGU>
            metrics = obj.evaluate(net);
            obj.saveModel(net);
            obj.View.display(metrics);
        end
    end
end
