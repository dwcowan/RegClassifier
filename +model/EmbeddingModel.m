classdef EmbeddingModel < reg.mvc.BaseModel
    %EMBEDDINGMODEL Generate dense embeddings from feature data.

    properties
        ConfigModel reg.model.ConfigModel
        EmbeddingRepo reg.repository.EmbeddingRepository
        SearchRepo reg.repository.SearchIndexRepository
    end

    methods
        function obj = EmbeddingModel(cfgModel, embeddingRepo, searchRepo)
            if nargin > 0
                obj.ConfigModel = cfgModel;
            end
            if nargin > 1
                obj.EmbeddingRepo = embeddingRepo;
            end
            if nargin > 2
                obj.SearchRepo = searchRepo;
            end
        end

        function input = load(~, features)
            %LOAD Wrap raw FEATURES in an EmbeddingInput value object.
            input = reg.service.EmbeddingInput(features);
        end

        function output = process(obj, input) %#ok<INUSD>
            %PROCESS Produce dense vectors from INPUT.
            if ~isempty(obj.ConfigModel)
                cfgRaw = obj.ConfigModel.load();
                cfg = obj.ConfigModel.process(cfgRaw); %#ok<NASGU>
            end
            output = reg.service.EmbeddingOutput([]);
            if ~isempty(obj.EmbeddingRepo)
                obj.EmbeddingRepo.save(output);
            end
            if ~isempty(obj.SearchRepo)
                obj.SearchRepo.save(output);
            end
            error("reg:model:NotImplemented", ...
                "EmbeddingModel.process is not implemented.");
        end
    end
end
