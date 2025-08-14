function tests = testLoadCorpus
%TESTLOADCORPUS Unit tests for helpers.loadCorpus
    tests = functiontests(localfunctions);
end

function testLoadCorpusReadsMatFile(testCase)
    documentVec = struct('docId', {'A'});
    save("v1.mat", "documentVec");
    c = onCleanup(@() delete("v1.mat"));
    loaded = helpers.loadCorpus("v1");
    verifyEqual(testCase, loaded, documentVec);
end
