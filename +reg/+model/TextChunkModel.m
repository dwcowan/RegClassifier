classdef TextChunkModel < reg.mvc.BaseModel
    %TEXTCHUNKMODEL Stub model splitting documents into chunks.
    
    methods
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
