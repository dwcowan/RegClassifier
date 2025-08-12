%% NAME-REGISTRY:TEST testIngestAndChunk
function tests = testIngestAndChunk
%TESTINGESTANDCHUNK Placeholder tests for ingest and chunk modules.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%% NAME-REGISTRY:TEST testIngestAndChunkProcessesDocuments
function testIngestAndChunkProcessesDocuments(testCase)
%TESTINGESTANDCHUNKPROCESSESDOCUMENTS Validate document ingestion and chunking pipeline.

  tmpFolderFixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
  pdfPath = fullfile(tmpFolderFixture.Folder, "dummy.pdf");
  fid = fopen(pdfPath, "w"); fclose(fid);
  pdfPathsCell = {pdfPath};
  reg.ingestPdfs(pdfPathsCell);
  reg.chunkText(table(), 0, 0);
  testCase.assumeFail('Not implemented yet');

end
