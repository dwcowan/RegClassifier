classdef EncoderFineTuneModel < reg.mvc.BaseModel
    %ENCODERFINETUNEMODEL Stub model for encoder fine-tuning.
    
    methods
        function inputs = load(~, varargin) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "EncoderFineTuneModel.load is not implemented.");
        end
        function net = process(~, inputs) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "EncoderFineTuneModel.process is not implemented.");
        end
    end
end
