classdef ProjectionHeadModel < reg.mvc.BaseModel
    %PROJECTIONHEADMODEL Stub model applying projection head to embeddings.

    properties
        % Configuration for projection head
        config
    end

    methods
        function obj = ProjectionHeadModel(config)
            if nargin > 0
                obj.config = config;
            end
        end

        function E = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "ProjectionHeadModel.load is not implemented.");
        end
        function Eproj = process(~, E) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "ProjectionHeadModel.process is not implemented.");
        end
    end
end
