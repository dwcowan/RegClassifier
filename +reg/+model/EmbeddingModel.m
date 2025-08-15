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
            %LOAD Wrap raw FEATURES in a simple struct for downstream use.
            %   INPUT = LOAD(~, FEATURES) returns a struct with field
            %   ``Features`` containing the raw feature matrix.
            input = struct('Features', features);
        end

        function output = process(obj, input) %#ok<INUSD>
            %PROCESS Produce dense vectors from INPUT.
            %   OUTPUT = PROCESS(obj, INPUT) returns a struct with field
            %   ``Vectors`` holding the resulting embedding matrix.
            if ~isempty(obj.ConfigModel)
                cfgRaw = obj.ConfigModel.load();
                cfg = obj.ConfigModel.process(cfgRaw); %#ok<NASGU>
            end
            output = struct('Vectors', []);
            reg.model.saveEmbeddings(output.Vectors);
            error("reg:model:NotImplemented", ...
                "EmbeddingModel.process is not implemented.");
        end
    end
end
