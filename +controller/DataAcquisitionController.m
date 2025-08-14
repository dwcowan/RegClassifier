classdef DataAcquisitionController
%DATAACQUISITIONCONTROLLER Fetch corpora and compute differences
    methods
        function diffStruct = diffVersions(~, oldVersionId, newVersionId)
        %DIFFVERSIONS Compute added and removed documents between versions
        %   diffStruct = DIFFVERSIONS(oldVersionId, newVersionId) loads the
        %   corpora identified by the given version identifiers and returns
        %   a struct with fields addedDocs and removedDocs.

            arguments
                oldVersionId (1,1) string
                newVersionId (1,1) string
            end

            oldDocs = helpers.loadCorpus(oldVersionId);
            newDocs = helpers.loadCorpus(newVersionId);
            oldCorpus = model.CorpusVersion(oldVersionId, oldDocs);
            newCorpus = model.CorpusVersion(newVersionId, newDocs);
            diffStruct = oldCorpus.diff(newCorpus);
        end
    end
end
