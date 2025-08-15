classdef Embedding
    %EMBEDDING Domain entity representing a dense vector.
    %   Associates a vector with its originating chunk or document.

    properties
        Vector double = []
        ChunkId string = ""
    end

    methods
        function obj = Embedding(vec, chunkId)
            %EMBEDDING Construct an embedding instance.
            %   OBJ = EMBEDDING(vec, chunkId) stores VECTOR and provenance
            %   information via CHUNKID.
            if nargin >= 1, obj.Vector = vec; end
            if nargin >= 2, obj.ChunkId = chunkId; end
        end
    end
end
