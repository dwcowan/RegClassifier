classdef FineTuneDataModel < reg.mvc.BaseModel
    %FINETUNEDATAMODEL Stub model building contrastive triplets.

    properties
        % Settings for constructing fine-tuning data
        config
    end

    methods
        function obj = FineTuneDataModel(config)
            if nargin > 0
                obj.config = config;
            end
        end

        function inputs = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "FineTuneDataModel.load is not implemented.");
        end
        function triplets = process(~, inputs) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "FineTuneDataModel.process is not implemented.");
        end
    end
end
