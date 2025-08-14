classdef EncoderFineTuneModel < reg.mvc.BaseModel
    %ENCODERFINETUNEMODEL Stub model for encoder fine-tuning.

    properties
        % Fine-tuning configuration
        config
    end

    methods
        function obj = EncoderFineTuneModel(config)
            %ENCODERFINETUNEMODEL Construct fine-tuning model.
            %   OBJ = ENCODERFINETUNEMODEL(config) sets parameters for
            %   encoder training. Equivalent to initialization in
            %   `ft_train_encoder`.
            if nargin > 0
                obj.config = config;
            end
        end

        function inputs = load(~, varargin) %#ok<INUSD>
            %LOAD Prepare data for encoder fine-tuning.
            %   INPUTS = LOAD(obj) gathers training triplets or batches.
            %   Equivalent to `ft_train_encoder` data loading.
            error("reg:model:NotImplemented", ...
                "EncoderFineTuneModel.load is not implemented.");
        end
        function net = process(~, inputs) %#ok<INUSD>
            %PROCESS Fine-tune the encoder network.
            %   NET = PROCESS(obj, inputs) returns a trained encoder.
            %   Equivalent to `ft_train_encoder`.
            error("reg:model:NotImplemented", ...
                "EncoderFineTuneModel.process is not implemented.");
        end
    end
end
