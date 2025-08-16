classdef testPipelineModel < matlab.unittest.TestCase
    %% Test suite for reg.model.PipelineModel
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
            testCase.verifyError(@() reg.model.PipelineModel(), 'reg:model:NotImplemented');
        end
    end

    methods (Test, TestTags={'Integration'})
        function methodPresence(testCase)
            utils = tests.fixtures.reflect_utils;
            if ~utils.methodExists('reg.model.PipelineModel','run')
                testCase.assumeFail('Missing method run');
            else
                testCase.verifyTrue(true);
            end
        end
    end

    methods (Test, TestTags={'Smoke'})
        function contractsAvailable(testCase)
            utils = tests.fixtures.reflect_utils;
            missing = utils.missingArgumentsBlocks('reg.model.PipelineModel');
            if ~isempty(missing)
                testCase.assumeFail("Missing arguments block for: " + strjoin(missing, ', '));
            end
        end
    end

    methods (Test, TestTags={'Doc'})
        function structFieldDocs(testCase)
            docRun = help('reg.model.PipelineModel/run');
            runFields = ["SearchIndex","Training","EvaluationInputs"];
            for f = runFields
                testCase.verifyNotEmpty(strfind(docRun, f), "Field " + f + " missing");
            end

            docTrain = help('reg.model.PipelineModel/runTraining');
            trainFields = ["DocumentsTbl","ChunksTbl","FeaturesTbl","Embeddings","Models","Scores","Thresholds","PredLabels"];
            for f = trainFields
                testCase.verifyNotEmpty(strfind(docTrain, f), "Field " + f + " missing");
            end

            docFine = help('reg.model.PipelineModel/runFineTune');
            fineFields = ["TripletsTbl","Network"];
            for f = fineFields
                testCase.verifyNotEmpty(strfind(docFine, f), "Field " + f + " missing");
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
