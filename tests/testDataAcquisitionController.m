function tests = testDataAcquisitionController
%TESTDATAACQUISITIONCONTROLLER Tests for DataAcquisitionController
    tests = functiontests(localfunctions);
end

function testDiffVersionsComputesAddedAndRemoved(testCase)
    controllerObj = controller.DataAcquisitionController();
    oldDocs = struct('docId', {'A', 'B'});
    newDocs = struct('docId', {'B', 'C'});
    save("old.mat", "-struct", struct('documentVec', oldDocs));
    save("new.mat", "-struct", struct('documentVec', newDocs));
    c = onCleanup(@() delete(["old.mat", "new.mat"]));
    diffStruct = controllerObj.diffVersions("old", "new");
    verifyEqual(testCase, {diffStruct.addedDocs.docId}, {'C'});
    verifyEqual(testCase, {diffStruct.removedDocs.docId}, {'A'});
end
