classdef FineTuneDataModel < reg.mvc.BaseModel
    %FINETUNEDATAMODEL Stub model building contrastive triplets.
    
    methods
        function inputs = load(~, varargin) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "FineTuneDataModel.load is not implemented.");
        end
        function triplets = process(~, inputs) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "FineTuneDataModel.process is not implemented.");
        end
    end
end
