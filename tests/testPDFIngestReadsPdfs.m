%% NAME-REGISTRY:TEST testPDFIngestReadsPdfs
function testPDFIngestReadsPdfs(testCase)
%TESTPDFINGESTREADSPDFS Verify PDF ingestion reads provided files.

  tmpFolderFixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
  pdfPath = fullfile(tmpFolderFixture.Folder, "dummy.pdf");
  fid = fopen(pdfPath, "w"); fclose(fid);
  pdfPathsCell = {pdfPath};
  reg.ingestPdfs(pdfPathsCell);
  testCase.assumeFail('Not implemented yet');

end
