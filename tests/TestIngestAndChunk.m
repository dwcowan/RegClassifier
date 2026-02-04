classdef TestIngestAndChunk < RegTestCase
    %TESTINGESTANDCHUNK Integration test for PDF ingestion and text chunking.
    %   Tests the complete pipeline from PDF to chunks, verifying chunk
    %   properties, boundaries, and document representation.

    methods (Test)
        function testIngestAndChunk(tc)
            %TESTINGESTANDCHUNK Test full ingestion and chunking pipeline.
            %   Verifies that PDFs are ingested and chunked correctly with
            %   proper overlap, size constraints, and document coverage.
            C = config();
            docsT = reg.ingest_pdfs(C.input_dir);
            tc.verifyGreaterThanOrEqual(height(docsT), 1, ...
                'Should ingest at least one document');

            % Test chunking with explicit parameters
            chunkSize = 60;
            overlap = 10;
            chunksT = reg.chunk_text(docsT, chunkSize, overlap);

            % Verify basic properties
            tc.verifyGreaterThan(height(chunksT), 0, ...
                'Chunking should produce at least one chunk');
            tc.verifyTrue(all(strlength(chunksT.text) > 0), ...
                'All chunks should have non-empty text');

            % Verify table structure
            tc.verifyTrue(ismember('chunk_id', chunksT.Properties.VariableNames), ...
                'Chunk table should have chunk_id column');
            tc.verifyTrue(ismember('doc_id', chunksT.Properties.VariableNames), ...
                'Chunk table should have doc_id column');
            tc.verifyTrue(ismember('text', chunksT.Properties.VariableNames), ...
                'Chunk table should have text column');

            % Verify all document IDs in chunks exist in source documents
            tc.verifyTrue(all(ismember(chunksT.doc_id, docsT.doc_id)), ...
                'All chunk doc_ids should correspond to ingested documents');

            % Verify all source documents are represented in chunks
            uniqueDocIds = unique(chunksT.doc_id);
            tc.verifyEqual(numel(uniqueDocIds), height(docsT), ...
                'All ingested documents should be represented in chunks');

            % Verify chunk size constraints (approximate due to tokenization)
            for i = 1:min(10, height(chunksT))  % Check first 10 chunks
                tokens = split(chunksT.text(i));
                numTokens = numel(tokens);
                tc.verifyLessThanOrEqual(numTokens, chunkSize + overlap + 10, ...
                    sprintf('Chunk %d token count should not greatly exceed size + overlap', i));
            end

            % Verify chunk IDs are unique
            tc.verifyEqual(numel(unique(chunksT.chunk_id)), height(chunksT), ...
                'All chunk IDs should be unique');
        end
    end
end
