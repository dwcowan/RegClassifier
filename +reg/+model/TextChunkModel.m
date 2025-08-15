classdef TextChunkModel < reg.mvc.BaseModel
    %TEXTCHUNKMODEL Stub model splitting documents into chunks.
    %
    % Input documentsTable schema (see PDFIngestModel):
    %   doc_id (string) : unique document identifier
    %   text   (string) : full document text
    %   meta   (struct) : file metadata
    %
    % Output chunksTable schema returned by PROCESS:
    %   chunk_id  (string) : unique chunk identifier
    %   doc_id    (string) : parent document identifier
    %   text      (string) : chunk text content
    %   start_idx (double) : starting token index in source doc
    %   end_idx   (double) : ending token index in source doc

    properties
        % Shared configuration reference
        cfg reg.model.ConfigModel = reg.model.ConfigModel();
    end

    methods
        function obj = TextChunkModel(cfg)
            %TEXTCHUNKMODEL Construct text chunking model.
            %   OBJ = TEXTCHUNKMODEL(cfg) reads chunking parameters such as
            %   cfg.chunkSizeTokens and cfg.chunkOverlap.
            if nargin > 0
                obj.cfg = cfg;
            end
        end

        function documentsTable = load(~, varargin) %#ok<INUSD>
            %LOAD Fetch documents for chunking.
            %   documentsTable = LOAD(obj) retrieves documents to split.
            %   Parameters
            %       varargin - Placeholder for future options (unused)
            %   Returns
            %       documentsTable (table): Input documents and metadata.
            %   Side Effects
            %       None.
            %   Legacy Reference
            %       Equivalent to `chunk_text` input gathering.
            %   Extension Point
            %       Override to stream documents from external sources.
            % Pseudocode:
            %   1. Load documents from storage
            %   2. Return as documentsTable
            error("reg:model:NotImplemented", ...
                "TextChunkModel.load is not implemented.");
        end
        function chunksTable = process(~, documentsTable) %#ok<INUSD>
            %PROCESS Split documents into text chunks.
            %   chunksTable = PROCESS(obj, documentsTable) returns a table of
            %   text segments.
            %   Parameters
            %       documentsTable (table): Documents to split.
            %   Returns
            %       chunksTable (table): Tokenized text segments.
            %   Side Effects
            %       May modify documentsTable to track offsets.
            %   Legacy Reference
            %       Equivalent to `chunk_text`.
            %   Extension Point
            %       Customize chunk boundaries or overlapping logic.
            % Pseudocode:
            %   1. Tokenize each document
            %   2. Break tokens into cfg.chunkSizeTokens segments
            %   3. Assemble chunksTable with metadata
            error("reg:model:NotImplemented", ...
                "TextChunkModel.process is not implemented.");
        end
    end
end
