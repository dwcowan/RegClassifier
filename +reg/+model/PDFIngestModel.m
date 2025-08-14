classdef PDFIngestModel < reg.mvc.BaseModel
    %PDFINGESTMODEL Stub model converting PDFs to document table.
    
    methods
        function files = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "PDFIngestModel.load is not implemented.");
        end
        function docsT = process(~, files) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "PDFIngestModel.process is not implemented.");
        end
    end
end
