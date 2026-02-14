classdef TestPDFIngest < fixtures.RegTestCase
    %TESTPDFINGEST Tests for PDF ingestion with OCR fallback.
    %   Tests reg.ingest_pdfs function with text-based and image-only PDFs.
    %   Verifies table structure, column types, and content extraction quality.

    methods (Test)
        function ingestTextPdf(tc)
            %INGESTTEXTPDF Test ingestion of text-based PDF.
            %   Verifies that text PDFs are ingested correctly with proper
            %   table structure and expected content.
            C = config();
            folder = fullfile("tests","fixtures");
            files = dir(fullfile(folder, "sim_text.pdf"));
            tc.assumeNotEmpty(files, "Missing sim_text.pdf");
            % Temporarily point input_dir to fixtures
            C.input_dir = folder;
            docsT = reg.ingest_pdfs(C.input_dir);

            % Verify table structure and size
            tc.verifyGreaterThanOrEqual(height(docsT), 1, ...
                'Should ingest at least one document');

            % Verify required columns exist
            tc.verifyTrue(ismember('doc_id', docsT.Properties.VariableNames), ...
                'Document table should have doc_id column');
            tc.verifyTrue(ismember('text', docsT.Properties.VariableNames), ...
                'Document table should have text column');

            % Verify column types
            tc.verifyClass(docsT.doc_id, 'string', ...
                'doc_id should be string type');
            tc.verifyClass(docsT.text, 'string', ...
                'text should be string type');

            % Verify content quality
            tc.verifyGreaterThan(strlength(docsT.text(1)), 10, ...
                'Ingested text should have substantial length');
            tc.verifyTrue(contains(lower(docsT.text(1)), "internal ratings based"), ...
                'Should extract expected regulatory content from fixture PDF');

            % Verify all doc_ids are unique
            tc.verifyEqual(numel(unique(docsT.doc_id)), height(docsT), ...
                'All document IDs should be unique');
        end

        function ingestImagePdfWithOcrIfAvailable(tc)
            %INGESTIMAGEPDFWITHOCRIFAVAILABLE Test OCR fallback for image PDFs.
            %   Verifies that image-only PDFs trigger OCR and extract text.
            if ~exist('ocr','file')
                tc.assumeFail("OCR not available; skipping OCR ingest test.");
            end
            C = config();
            folder = fullfile("tests","fixtures");
            files = dir(fullfile(folder, "sim_image_only.pdf"));
            tc.assumeNotEmpty(files, "Missing sim_image_only.pdf");
            C.input_dir = folder;
            docsT = reg.ingest_pdfs(C.input_dir);

            % Verify table structure
            tc.verifyGreaterThanOrEqual(height(docsT), 1, ...
                'Should ingest at least one document via OCR');
            tc.verifyTrue(ismember('text', docsT.Properties.VariableNames), ...
                'Document table should have text column');

            % Verify OCR extracted some text
            tc.verifyGreaterThan(strlength(docsT.text(1)), 0, ...
                'OCR should extract non-empty text from image PDF');

            % Expect AML/KYC or SRT tokens present if OCR succeeded
            hit = contains(lower(docsT.text), ["aml","kyc","srt","securitisation"]);
            tc.verifyTrue(any(hit), ...
                'OCR ingest should produce expected regulatory tokens');
        end
    end
end
