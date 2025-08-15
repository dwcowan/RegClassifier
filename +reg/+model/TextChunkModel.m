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
        % No stored configuration; callers supply parameters directly.
    end

    methods
        function obj = TextChunkModel(varargin)
            %#ok<INUSD>
        end

        function documentsTable = load(~, cfg) %#ok<INUSD>
            %LOAD Fetch documents for chunking.
            %   documentsTable = LOAD(obj, cfg) retrieves documents to split.
            %   Parameters
            %       cfg - configuration struct controlling chunking
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
