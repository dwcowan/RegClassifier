function diffDocsVec = docSetdiff(corpusAVec, corpusBVec)
%DOCSETDIFF Return documents in corpusAVec missing from corpusBVec by docId
%   diffDocsVec = DOCSETDIFF(corpusAVec, corpusBVec) returns the elements of
%   corpusAVec whose docId field does not appear in corpusBVec.

    arguments
        corpusAVec (1,:) struct
        corpusBVec (1,:) struct
    end

    [~, idxVec] = builtin('setdiff', {corpusAVec.docId}, {corpusBVec.docId});
    diffDocsVec = corpusAVec(idxVec);
end
