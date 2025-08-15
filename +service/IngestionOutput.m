classdef IngestionOutput
    %INGESTIONOUTPUT Value object for ingestion results.
    %   Encapsulates documents and text chunks produced during
    %   preprocessing so downstream services remain loosely coupled to the
    %   concrete models that generated them.

    properties
        Documents
        Chunks
        Features
    end

    methods
        function obj = IngestionOutput(docs, chunks, feats)
            if nargin > 0
                obj.Documents = docs;
                obj.Chunks = chunks;
                if nargin > 2
                    obj.Features = feats;
                end
            end
        end
    end
end

