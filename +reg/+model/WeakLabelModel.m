classdef WeakLabelModel < reg.mvc.BaseModel
    %WEAKLABELMODEL Stub model generating weak supervision labels.

    properties
        % Configuration for weak labeling
        config
    end

    methods
        function obj = WeakLabelModel(config)
            if nargin > 0
                obj.config = config;
            end
        end

        function chunksT = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "WeakLabelModel.load is not implemented.");
        end
        function [Yweak, Yboot] = process(~, chunksT) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "WeakLabelModel.process is not implemented.");
        end
    end
end
