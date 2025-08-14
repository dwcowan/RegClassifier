classdef ProjectionHeadModel < reg.mvc.BaseModel
    %PROJECTIONHEADMODEL Stub model applying projection head to embeddings.

    properties
        % Configuration for projection head
        config
    end

    methods
        function obj = ProjectionHeadModel(config)
            %PROJECTIONHEADMODEL Construct projection head model.
            %   OBJ = PROJECTIONHEADMODEL(config) sets projection head
            %   parameters. Equivalent to initialization in
            %   `train_projection_head`.
            if nargin > 0
                obj.config = config;
            end
        end

        function E = load(~, varargin) %#ok<INUSD>
            %LOAD Retrieve embeddings for projection.
            %   E = LOAD(obj) obtains base embeddings to project.
            %   Equivalent to `train_projection_head` data loading.
            error("reg:model:NotImplemented", ...
                "ProjectionHeadModel.load is not implemented.");
        end
        function Eproj = process(~, E) %#ok<INUSD>
            %PROCESS Apply projection head to embeddings.
            %   EPROJ = PROCESS(obj, E) returns projected embeddings.
            %   Equivalent to `train_projection_head`.
            error("reg:model:NotImplemented", ...
                "ProjectionHeadModel.process is not implemented.");
        end
    end
end
