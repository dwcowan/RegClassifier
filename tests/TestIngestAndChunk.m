classdef TestIngestAndChunk < matlab.unittest.TestCase
    methods (Test)
        function test_ingest_and_chunk(tc)
            C = config();
            docsT = reg.ingest_pdfs(C.input_dir);
            tc.verifyGreaterThanOrEqual(height(docsT), 1);
            chunksT = reg.chunk_text(docsT, 60, 10);
            tc.verifyGreaterThan(height(chunksT), 0);
            tc.verifyTrue(all(strlength(chunksT.text) > 0));
        end
    end
end
