classdef TextChunkModel < reg.mvc.BaseModel
    %TEXTCHUNKMODEL Stub model splitting documents into chunks.

    properties
        % Number of tokens per chunk
        chunkSizeTokens
    end

    methods
        function obj = TextChunkModel(chunkSizeTokens)
            if nargin > 0
                obj.chunkSizeTokens = chunkSizeTokens;
            end
        end

        function docsT = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "TextChunkModel.load is not implemented.");
        end
        function chunksT = process(~, docsT) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "TextChunkModel.process is not implemented.");
        end
    end
end
