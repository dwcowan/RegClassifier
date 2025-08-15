classdef EmbeddingModel < reg.mvc.BaseModel
    %EMBEDDINGMODEL Generate dense embeddings from feature data.

    properties
        ConfigModel reg.model.ConfigModel
    end

    methods
        function obj = EmbeddingModel(cfgModel)
            if nargin > 0
                obj.ConfigModel = cfgModel;
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
            reg.model.Embedding.save(output.Vectors);
            error("reg:model:NotImplemented", ...
                "EmbeddingModel.process is not implemented.");
        end
    end
end
