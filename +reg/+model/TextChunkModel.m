classdef TextChunkModel < reg.mvc.BaseModel
    %TEXTCHUNKMODEL Stub model splitting documents into chunks.

    properties
        % Number of tokens per chunk
        chunkSizeTokens
    end

    methods
        function obj = TextChunkModel(chunkSizeTokens)
            %TEXTCHUNKMODEL Construct text chunking model.
            %   OBJ = TEXTCHUNKMODEL(chunkSizeTokens) defines the token
            %   size for each chunk. Equivalent to configuration in
            %   `chunk_text`.
            if nargin > 0
                obj.chunkSizeTokens = chunkSizeTokens;
            end
        end

        function docsT = load(~, varargin) %#ok<INUSD>
            %LOAD Fetch documents for chunking.
            %   DOCST = LOAD(obj) retrieves a table of documents to split.
            %   Equivalent to `chunk_text` input gathering.
            error("reg:model:NotImplemented", ...
                "TextChunkModel.load is not implemented.");
        end
        function chunksT = process(~, docsT) %#ok<INUSD>
            %PROCESS Split documents into text chunks.
            %   CHUNKST = PROCESS(obj, docsT) returns a table of text
            %   segments. Equivalent to `chunk_text`.
            error("reg:model:NotImplemented", ...
                "TextChunkModel.process is not implemented.");
        end
    end
end
