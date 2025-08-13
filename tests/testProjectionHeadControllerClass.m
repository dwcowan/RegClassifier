function tests = testProjectionHeadControllerClass
%TESTPROJECTIONHEADCONTROLLERCLASS Unit tests for projectionHeadControllerClass.
    tests = functiontests(localfunctions);
end

function testTrainDelegatesToModel(~)
    embeddingMat = rand(4, 8);
    labelMat = rand(4, 2);
    controllerObj = controller.projectionHeadControllerClass();
    head = controllerObj.trainHead(embeddingMat, labelMat, 1, 0.1);
    assert(isa(head, 'model.projectionHeadClass'));
    assert(head.paramStruct.trained);
end

function testApplyDelegatesToModel(~)
    embeddingMat = rand(3, 8);
    labelMat = rand(3, 2);
    controllerObj = controller.projectionHeadControllerClass();
    head = controllerObj.trainHead(embeddingMat, labelMat, 1, 0.1);
    transformed = controllerObj.applyHead(head, embeddingMat);
    assert(isequal(transformed, embeddingMat));
end
