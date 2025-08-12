%% NAME-REGISTRY:TEST testPDFIngestReadsPdfs
function tests = testPDFIngestReadsPdfs
%TESTPDFINGESTREADSPDFS Verify PDF ingestion reads provided files.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Integration'}; % testReadsPdfs
end

function testReadsPdfs(testCase)
  tmpFolderFixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
  pdfPath = fullfile(tmpFolderFixture.Folder, "dummy.pdf");
  fid = fopen(pdfPath, "w"); fclose(fid);
  pdfPathsCell = {pdfPath};
  reg.ingestPdfs(pdfPathsCell);
  testCase.assumeFail('Not implemented yet');
end
