classdef Document
    %DOCUMENT Domain entity representing an ingested document.
    %   Encapsulates raw text and optional metadata for a single document.

    properties
        Id string = ""
        Text string = ""
        Metadata struct = struct()
    end

    methods
        function obj = Document(id, text, metadata)
            %DOCUMENT Construct a document instance.
            %   OBJ = DOCUMENT(id, text, metadata) stores identifying
            %   information and associated content. METADATA is optional
            %   and defaults to an empty struct.
            if nargin >= 1
                obj.Id = id;
            end
            if nargin >= 2
                obj.Text = text;
            end
            if nargin >= 3
                obj.Metadata = metadata;
            end
        end

    end

    methods (Static)
        function save(documents) %#ok<INUSD>
            %SAVE Persist document objects to storage.
            %   SAVE(documents) writes DOCUMENTS to the configured
            %   storage backend.
            error("reg:model:NotImplemented", ...
                "Document.save is not implemented.");
        end

        function documents = load(ids) %#ok<INUSD,STOUT>
            %LOAD Retrieve documents by identifier.
            %   documents = LOAD(ids) fetches documents from storage.
            error("reg:model:NotImplemented", ...
                "Document.load is not implemented.");
        end

        function result = query(varargin) %#ok<STOUT>
            %QUERY Execute a document search.
            %   result = QUERY(varargin) returns matching documents.
            error("reg:model:NotImplemented", ...
                "Document.query is not implemented.");
        end
    end
end
