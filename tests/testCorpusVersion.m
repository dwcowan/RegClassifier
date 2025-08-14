function tests = testCorpusVersion
%TESTCORPUSVERSION Unit tests for CorpusVersion
    tests = functiontests(localfunctions);
end

function testDiffComputesAddedAndRemoved(testCase)
    oldCorpus = model.CorpusVersion("old", struct('docId', {'A', 'B'}));
    newCorpus = model.CorpusVersion("new", struct('docId', {'B', 'C'}));
    diffStruct = oldCorpus.diff(newCorpus);
    verifyEqual(testCase, {diffStruct.addedDocs.docId}, {'C'});
    verifyEqual(testCase, {diffStruct.removedDocs.docId}, {'A'});
end
