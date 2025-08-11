classdef TestPDFIngest < matlab.unittest.TestCase
    methods (Test)
        function ingest_text_pdf(tc)
            C = config();
            folder = fullfile("tests","fixtures");
            files = dir(fullfile(folder, "sim_text.pdf"));
            tc.assumeNotEmpty(files, "Missing sim_text.pdf");
            % Temporarily point input_dir to fixtures
            C.input_dir = folder;
            docsT = reg.ingest_pdfs(C.input_dir);
            tc.verifyGreaterThanOrEqual(height(docsT), 1);
            tc.verifyTrue(contains(lower(docsT.text(1)), "internal ratings based"));
        end

        function ingest_image_pdf_with_ocr_if_available(tc)
            if ~exist('ocr','file')
                tc.assumeFail("OCR not available; skipping OCR ingest test.");
            end
            C = config();
            folder = fullfile("tests","fixtures");
            files = dir(fullfile(folder, "sim_image_only.pdf"));
            tc.assumeNotEmpty(files, "Missing sim_image_only.pdf");
            C.input_dir = folder;
            docsT = reg.ingest_pdfs(C.input_dir);
            % Expect AML/KYC or SRT tokens present if OCR succeeded
            hit = contains(lower(docsT.text), ["aml","kyc","srt","securitisation"]);
            tc.verifyTrue(any(hit), "OCR ingest did not produce expected tokens.");
        end
    end
end
