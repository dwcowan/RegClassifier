classdef PDFIngestModel < reg.mvc.BaseModel
    %PDFINGESTMODEL Stub model converting PDFs to document table.

    properties
        % Directory containing the PDF files to ingest
        inputDir
    end

    methods
        function obj = PDFIngestModel(inputDir)
            %PDFINGESTMODEL Construct the ingest model.
            %   OBJ = PDFINGESTMODEL(inputDir) creates a model pointing to the
            %   directory containing PDF files. Equivalent to `ingest_pdfs`
            %   initialization logic.
            if nargin > 0
                obj.inputDir = inputDir;
            end
        end

        function files = load(~, varargin) %#ok<INUSD>
            %LOAD Locate PDF files for ingestion.
            %   FILES = LOAD(obj) returns a list of file paths to be
            %   processed. Returns a string array. Equivalent to
            %   `ingest_pdfs` file discovery.
            error("reg:model:NotImplemented", ...
                "PDFIngestModel.load is not implemented.");
        end
        function docsT = process(~, files) %#ok<INUSD>
            %PROCESS Convert PDFs to document table.
            %   DOCST = PROCESS(obj, files) reads the PDF paths and returns a
            %   table containing document data. Equivalent to `ingest_pdfs`.
            error("reg:model:NotImplemented", ...
                "PDFIngestModel.process is not implemented.");
        end
    end
end
