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
end
