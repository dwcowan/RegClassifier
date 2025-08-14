function tests = testDocSetdiff
%TESTDOCSETDIFF Unit tests for helpers.docSetdiff
    tests = functiontests(localfunctions);
end

function testReturnsDocumentsMissingFromSecondCorpus(testCase)
    corpusAVec = struct('docId', {'A', 'B', 'C'});
    corpusBVec = struct('docId', {'B'});
    diffDocsVec = helpers.docSetdiff(corpusAVec, corpusBVec);
    verifyEqual(testCase, {diffDocsVec.docId}, {'A', 'C'});
end
