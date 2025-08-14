function tests = testDataAcquisitionController
%TESTDATAACQUISITIONCONTROLLER Tests for DataAcquisitionController
    tests = functiontests(localfunctions);
end

function testDiffVersionsComputesAddedAndRemoved(testCase)
    controllerObj = controller.DataAcquisitionController();
    oldCorpusVec = struct('docId', {'A', 'B'});
    newCorpusVec = struct('docId', {'B', 'C'});
    diffStruct = controllerObj.diffVersions(oldCorpusVec, newCorpusVec);
    verifyEqual(testCase, {diffStruct.addedDocs.docId}, {'C'});
    verifyEqual(testCase, {diffStruct.removedDocs.docId}, {'A'});
end
