%% NAME-REGISTRY:TEST testPDFIngest
function tests = testPDFIngest
%TESTPDFINGEST Placeholder tests for PDF ingestion module.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTPDFINGESTREADSPDFS Verify PDF ingestion reads provided files.
function testPDFIngestReadsPdfs(testCase)

  tmpFolderFixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
  pdfPath = fullfile(tmpFolderFixture.Folder, "dummy.pdf");
  fid = fopen(pdfPath, "w"); fclose(fid);
  pdfPathsCell = {pdfPath};
  reg.ingestPdfs(pdfPathsCell);
  testCase.assumeFail('Not implemented yet');

end
