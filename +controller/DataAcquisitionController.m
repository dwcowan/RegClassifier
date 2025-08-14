classdef DataAcquisitionController
%DATAACQUISITIONCONTROLLER Fetch corpora and compute differences
    methods
        function diffStruct = diffVersions(~, oldCorpusVec, newCorpusVec)
        %DIFFVERSIONS Compute added and removed documents between corpora
        %   diffStruct = DIFFVERSIONS(oldCorpusVec, newCorpusVec) returns a
        %   struct with fields addedDocs and removedDocs.

            arguments
                oldCorpusVec (1,:) struct
                newCorpusVec (1,:) struct
            end

            diffStruct = struct();
            diffStruct.addedDocs = helpers.docSetdiff(newCorpusVec, oldCorpusVec);
            diffStruct.removedDocs = helpers.docSetdiff(oldCorpusVec, newCorpusVec);
        end
    end
end
