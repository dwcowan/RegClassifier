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
            %   OBJ = FINETUNECONTROLLER(...) assembles components for the
            %   fine-tuning workflow. Equivalent to
            %   `reg_finetune_encoder_workflow` setup.
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
            %   TRIPLETS = BUILDTRIPLETS(obj) produces training triplets.
            %   Equivalent to `ft_build_contrastive_dataset`.
            raw = obj.FineTuneDataModel.load();
            triplets = obj.FineTuneDataModel.process(raw);
        end

        function net = trainEncoder(obj, triplets) %#ok<INUSD>
            %TRAINENCODER Fine-tune encoder given triplets.
            %   NET = TRAINENCODER(obj, triplets) returns a trained model.
            %   Equivalent to `ft_train_encoder`.
            raw = obj.EncoderFineTuneModel.load();
            net = obj.EncoderFineTuneModel.process(raw);
        end

        function metrics = evaluate(obj, net) %#ok<INUSD>
            %EVALUATE Compute evaluation metrics on fine-tuned encoder.
            %   METRICS = EVALUATE(obj, net) returns evaluation scores.
            %   Equivalent to `ft_eval`.
            raw = obj.EvaluationModel.load();
            metrics = obj.EvaluationModel.process(raw);
        end

        function saveModel(~, net, varargin)
            %SAVEMODEL Persist fine-tuned encoder to disk.
            %   SAVEMODEL(obj, net, filename) saves the network to a MAT
            %   file. Equivalent to model saving in `ft_train_encoder`.
            if ~isempty(varargin)
                filename = varargin{1};
            else
                filename = "fine_tuned_encoder.mat";
            end
            save(filename, "net", "-v7.3");
        end

        function run(obj)
            %RUN Execute full fine-tuning workflow.
            %   Equivalent to `reg_finetune_pipeline`.
            triplets = obj.buildTriplets(); %#ok<NASGU>
            net = obj.trainEncoder(triplets); %#ok<NASGU>
            metrics = obj.evaluate(net);
            obj.saveModel(net);
            obj.View.display(metrics);
        end
    end
end
