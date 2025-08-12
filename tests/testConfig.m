%% NAME-REGISTRY:TEST testConfig
function tests = testConfig
%TESTCONFIG Verify config override precedence.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
% ## Tags
%   - Unit: testOverridesPrecedence

tests = functiontests(localfunctions);
tests(1).Tags = {'Unit'}; % testOverridesPrecedence
end

function testOverridesPrecedence(testCase)
  import tests.fixtures.EnvironmentFixture
  testCase.applyFixture(EnvironmentFixture);

  rootDir = fileparts(fileparts(mfilename('fullpath')));
  pipelinePathStr = fullfile(rootDir, "pipeline.json");
  knobsPathStr = fullfile(rootDir, "knobs.json");
  paramsPathStr = fullfile(rootDir, "params.json");
  filePathsCell = {pipelinePathStr, knobsPathStr, paramsPathStr};
  for i = 1:numel(filePathsCell)
    testCase.addTeardown(@() deleteFile(filePathsCell{i}));
  end

  pipelineStruct = struct("shared", 1, "pipelineOnly", 10);
  knobsStruct = struct("shared", 2, "knobOnly", 20);
  paramsStruct = struct("shared", 3, "paramsOnly", 30);
  writeJson(pipelinePathStr, pipelineStruct);
  writeJson(knobsPathStr, knobsStruct);
  writeJson(paramsPathStr, paramsStruct);

  configStruct = config();

  verifyEqual(testCase, configStruct.shared, 3);
  verifyEqual(testCase, configStruct.pipelineOnly, 10);
  verifyEqual(testCase, configStruct.knobOnly, 20);
  verifyEqual(testCase, configStruct.paramsOnly, 30);
end

function writeJson(pathStr, dataStruct)
  fid = fopen(pathStr, "w");
  cleanupObj = onCleanup(@() fclose(fid));
  fwrite(fid, jsonencode(dataStruct), "char");
end

function deleteFile(pathStr)
  if exist(pathStr, "file")
    delete(pathStr);
  end
end
