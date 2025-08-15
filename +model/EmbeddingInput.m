classdef EmbeddingInput
    %EMBEDDINGINPUT Value object representing features destined for the
    %embedding backend.

    properties
        Features
    end

    methods
        function obj = EmbeddingInput(features)
            if nargin > 0
                obj.Features = features;
            end
        end
    end
end
