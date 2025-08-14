classdef PDFIngestModel < reg.mvc.BaseModel
    %PDFINGESTMODEL Stub model converting PDFs to document table.

    properties
        % Directory containing the PDF files to ingest (default: "")
        inputDir = "";
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

        function pdfFiles = load(~, varargin) %#ok<INUSD>
            %LOAD Locate PDF files for ingestion.
            %   pdfFiles = LOAD(obj) returns a list of file paths to be
            %   processed.
            %   Parameters
            %       varargin - Placeholder for future options (unused)
            %   Returns
            %       pdfFiles (string array): Paths to PDF documents.
            %   Side Effects
            %       None.
            %   Legacy Reference
            %       Equivalent to `ingest_pdfs` file discovery.
            %   Extension Point
            %       Override to support remote storage or filtering.
            % Pseudocode:
            %   1. Scan inputDir for *.pdf files
            %   2. Sort or filter list as needed
            %   3. Return pdfFiles
            error("reg:model:NotImplemented", ...
                "PDFIngestModel.load is not implemented.");
        end
        function documentsTable = process(~, pdfFiles) %#ok<INUSD>
            %PROCESS Convert PDFs to document table.
            %   documentsTable = PROCESS(obj, pdfFiles) reads the PDF paths
            %   and returns a table containing document data.
            %   Parameters
            %       pdfFiles (string array): Paths to source PDFs.
            %   Returns
            %       documentsTable (table): Parsed document metadata and text.
            %   Side Effects
            %       May write intermediate artifacts such as extracted text.
            %   Legacy Reference
            %       Equivalent to `ingest_pdfs`.
            %   Extension Point
            %       Hook to inject custom parsers or metadata extraction.
            % Pseudocode:
            %   1. Loop over pdfFiles and extract text
            %   2. Assemble document metadata into table rows
            %   3. Return documentsTable
            error("reg:model:NotImplemented", ...
                "PDFIngestModel.process is not implemented.");
        end
    end
end
