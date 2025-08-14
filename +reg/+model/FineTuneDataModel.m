classdef FineTuneDataModel < reg.mvc.BaseModel
    %FINETUNEDATAMODEL Stub model building contrastive triplets.

    properties
        % Settings for constructing fine-tuning data
        config
    end

    methods
        function obj = FineTuneDataModel(config)
            %FINETUNEDATAMODEL Construct contrastive data model.
            %   OBJ = FINETUNEDATAMODEL(config) stores settings for
            %   generating training triplets. Equivalent to
            %   `ft_build_contrastive_dataset` setup.
            if nargin > 0
                obj.config = config;
            end
        end

        function inputs = load(~, varargin) %#ok<INUSD>
            %LOAD Gather raw data for triplet construction.
            %   INPUTS = LOAD(obj) returns structures needed to build
            %   triplets. Equivalent to `ft_build_contrastive_dataset`
            %   loading.
            error("reg:model:NotImplemented", ...
                "FineTuneDataModel.load is not implemented.");
        end
        function triplets = process(~, inputs) %#ok<INUSD>
            %PROCESS Build contrastive triplets from inputs.
            %   TRIPLETS = PROCESS(obj, inputs) returns an array of triplet
            %   structs. Equivalent to `ft_build_contrastive_dataset`.
            error("reg:model:NotImplemented", ...
                "FineTuneDataModel.process is not implemented.");
        end
    end
end
