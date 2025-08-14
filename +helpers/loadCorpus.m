function documentVec = loadCorpus(versionId)
%LOADCORPUS Load corpus documents from a MAT file
%   documentVec = LOADCORPUS(versionId) loads variable `documentVec`
%   from the MAT file named <versionId>.mat. Returns an empty struct
%   array if the file or variable is missing.

    arguments
        versionId (1,1) string
    end

    fileName = versionId + ".mat";
    if isfile(fileName)
        dataStruct = load(fileName, "documentVec");
        if isfield(dataStruct, "documentVec")
            documentVec = dataStruct.documentVec;
        else
            documentVec = struct([]);
        end
    else
        documentVec = struct([]);
    end
end
