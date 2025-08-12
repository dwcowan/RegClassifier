%% NAME-REGISTRY:TEST testIngestAndChunkProcessesDocuments
function tests = testIngestAndChunkProcessesDocuments
%TESTINGESTANDCHUNKPROCESSESDOCUMENTS Validate document ingestion and chunking pipeline.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Integration'}; % testProcessesDocuments
end

function testProcessesDocuments(testCase)
  tmpFolderFixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
  pdfPath = fullfile(tmpFolderFixture.Folder, "dummy.pdf");
  fid = fopen(pdfPath, "w"); fclose(fid);
  pdfPathsCell = {pdfPath};
  reg.ingestPdfs(pdfPathsCell);
  reg.chunkText(table(), 0, 0);
  testCase.assumeFail('Not implemented yet');
end
