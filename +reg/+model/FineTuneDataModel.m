classdef FineTuneDataModel < reg.mvc.BaseModel
    %FINETUNEDATAMODEL Stub model building contrastive triplets.

    properties
        % Shared configuration reference
        cfg reg.model.ConfigModel = reg.model.ConfigModel();
    end

    methods
        function obj = FineTuneDataModel(cfg)
            %FINETUNEDATAMODEL Construct contrastive data model.
            %   OBJ = FINETUNEDATAMODEL(cfg) utilises fields such as
            %   cfg.fineTuneLoss and cfg.fineTuneBatchSize.
            if nargin > 0
                obj.cfg = cfg;
            end
        end

        function rawData = load(~, varargin) %#ok<INUSD>
            %LOAD Gather raw data for triplet construction.
            %   rawData = LOAD(obj) returns structures needed to build
            %   triplets.
            %   Parameters
            %       varargin - Placeholder for future options (unused)
            %   Returns
            %       rawData (struct): Source pairs and negatives.
            %   Side Effects
            %       None.
            %   Legacy Reference
            %       Equivalent to `ft_build_contrastive_dataset` loading.
            %   Extension Point
            %       Override to generate synthetic negatives or sampling.
            % Pseudocode:
            %   1. Load positive and negative examples
            %   2. Return as rawData struct
            error("reg:model:NotImplemented", ...
                "FineTuneDataModel.load is not implemented.");
        end
        function triplets = process(~, rawData) %#ok<INUSD>
            %PROCESS Build contrastive triplets from inputs.
            %   triplets = PROCESS(obj, rawData) returns an array of triplet
            %   structs.
            %   Parameters
            %       rawData (struct): Raw positive/negative pairs.
            %   Returns
            %       triplets (table): Contrastive triplets for training.
            %   Side Effects
            %       May shuffle or balance triplets.
            %   Legacy Reference
            %       Equivalent to `ft_build_contrastive_dataset`.
            %   Extension Point
            %       Customize sampling strategies or hard negative mining.
            % Pseudocode:
            %   1. Pair anchors with positives and negatives
            %   2. Assemble into triplets table
            %   3. Return triplets
            error("reg:model:NotImplemented", ...
                "FineTuneDataModel.process is not implemented.");
        end
    end
end
