classdef Chunk
    %CHUNK Domain entity representing a segment of a document.
    %   Stores chunk text along with provenance information.

    properties
        Id string = ""
        DocumentId string = ""
        Text string = ""
        StartIdx double = NaN
        EndIdx double = NaN
    end

    methods
        function obj = Chunk(id, docId, text, startIdx, endIdx)
            %CHUNK Construct a chunk instance.
            %   OBJ = CHUNK(id, docId, text, startIdx, endIdx) records
            %   chunk boundaries within the source document.
            if nargin >= 1
                obj.Id = id;
            end
            if nargin >= 2
                obj.DocumentId = docId;
            end
            if nargin >= 3
                obj.Text = text;
            end
            if nargin >= 4
                obj.StartIdx = startIdx;
            end
            if nargin >= 5
                obj.EndIdx = endIdx;
            end
        end
    end
end
