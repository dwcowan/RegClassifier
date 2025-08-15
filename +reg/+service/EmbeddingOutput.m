classdef EmbeddingOutput
    %EMBEDDINGOUTPUT Value object carrying dense vector representations.

    properties
        Vectors
    end

    methods
        function obj = EmbeddingOutput(vecs)
            if nargin > 0
                obj.Vectors = vecs;
            end
        end
    end
end

