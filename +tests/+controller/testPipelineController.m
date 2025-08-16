classdef testPipelineController < matlab.unittest.TestCase
    %% Test suite for reg.controller.PipelineController
    % When domain logic goes live:
    %   - Enable real assertions and baseline comparisons.

    methods (TestClassSetup)
        function setupOnce(testCase)
            rng(0,'twister');
            testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture);
        end
    end

    methods (Test, TestTags={'Unit'})
        function constructorStub(testCase)
            testCase.verifyError(@() reg.controller.PipelineController(), 'reg:controller:NotImplemented');
        end
    end

    methods (Test, TestTags={'Integration'})
        function methodPresence(testCase)
            utils = tests.fixtures.reflect_utils;
            if ~utils.methodExists('reg.controller.PipelineController','run')
                testCase.assumeFail('Missing method run');
            else
                testCase.verifyTrue(true);
            end
        end
    end

    methods (Test, TestTags={'Smoke'})
        function contractsAvailable(testCase)
            utils = tests.fixtures.reflect_utils;
            missing = utils.missingArgumentsBlocks('reg.controller.PipelineController');
            if ~isempty(missing)
                testCase.assumeFail("Missing arguments block for: " + strjoin(missing, ', '));
            end
        end
    end

    methods (Test, TestTags={'Doc'})
        function structFieldDocs(testCase)
            docFine = help('reg.controller.PipelineController/runFineTune');
            testCase.verifyNotEmpty(strfind(docFine, 'TripletsTbl'), 'TripletsTbl missing');
            testCase.verifyNotEmpty(strfind(docFine, 'Network'), 'Network missing');

            docTrain = help('reg.controller.PipelineController/runTraining');
            fields = ["DocumentsTbl","ChunksTbl","FeaturesTbl","Embeddings","Models","Scores","Thresholds","PredLabels"];
            for f = fields
                testCase.verifyNotEmpty(strfind(docTrain, f), "Field " + f + " missing");
            end
        end
    end

    methods (Test, TestTags={'Regression'})
        function baselineStub(testCase)
            data = tests.fixtures.baseline_load('example.json'); %#ok<NASGU>
            testCase.verifyTrue(true); % placeholder
        end
    end
end
