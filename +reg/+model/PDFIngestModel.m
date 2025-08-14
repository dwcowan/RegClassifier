classdef PDFIngestModel < reg.mvc.BaseModel
    %PDFINGESTMODEL Stub model converting PDFs to document table.

    properties
        % Directory containing the PDF files to ingest
        inputDir
    end

    methods
        function obj = PDFIngestModel(inputDir)
            if nargin > 0
                obj.inputDir = inputDir;
            end
        end

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
