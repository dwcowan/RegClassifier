classdef CorpusVersion
%CORPUSVERSION Versioned corpus with diff capability
    properties
        versionId (1,1) string
        documentVec (1,:) struct
    end
    methods
        function obj = CorpusVersion(versionId, documentVec)
        %CORPUSVERSION Construct a CorpusVersion.
        %   obj = CORPUSVERSION(versionId, documentVec)
            arguments
                versionId (1,1) string
                documentVec (1,:) struct = struct([])
            end
            obj.versionId = versionId;
            obj.documentVec = documentVec;
        end
        function diffStruct = diff(obj, other)
        %DIFF Compute differences between two corpus versions.
        %   diffStruct = DIFF(obj, other) returns a struct with fields:
        %       addedDocs   - documents only in other
        %       removedDocs - documents only in obj
            arguments
                obj (1,1) model.CorpusVersion
                other (1,1) model.CorpusVersion
            end
            diffStruct = struct();
            [~, idxAdded] = builtin('setdiff', {other.documentVec.docId}, {obj.documentVec.docId});
            diffStruct.addedDocs = other.documentVec(idxAdded);
            [~, idxRemoved] = builtin('setdiff', {obj.documentVec.docId}, {other.documentVec.docId});
            diffStruct.removedDocs = obj.documentVec(idxRemoved);
        end
    end
end
