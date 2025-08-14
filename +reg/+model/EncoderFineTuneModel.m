classdef EncoderFineTuneModel < reg.mvc.BaseModel
    %ENCODERFINETUNEMODEL Stub model for encoder fine-tuning.

    properties
        % Fine-tuning configuration
        config
    end

    methods
        function obj = EncoderFineTuneModel(config)
            if nargin > 0
                obj.config = config;
            end
        end

        function inputs = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "EncoderFineTuneModel.load is not implemented.");
        end
        function net = process(~, inputs) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "EncoderFineTuneModel.process is not implemented.");
        end
    end
end
