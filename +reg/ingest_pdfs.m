function T = ingest_pdfs(inputDir)
%INGEST_PDFS Read PDFs; OCR if needed. Returns table(doc_id, text, meta)
files = dir(fullfile(inputDir, "*.pdf"));
if isempty(files)
    % Create a tiny dummy document if none present (for tests/demo)
    text = "Section 1: Internal Ratings Based (IRB) approach introduces PD, LGD, and EAD. " + ...
           "Section 2: Liquidity Coverage Ratio (LCR) requires HQLA and outflow assumptions. " + ...
           "Section 3: AML/KYC controls for customer due diligence.";
    T = table("DOC_1", string(text), {struct('path',"dummy",'bytes',numel(text),'modified',now)}, ...
        'VariableNames', {'doc_id','text','meta'});
    return
end

doc_id = strings(numel(files),1);
text   = strings(numel(files),1);
meta   = cell(numel(files),1);
for i = 1:numel(files)
    p = string(fullfile(files(i).folder, files(i).name));
    try
        % R2025b: Only valid parameters are Password, Encoding, ExtractionMethod, Pages
        txt = extractFileText(p);
        if strlength(strtrim(txt)) < 20
            % Try OCR if text extraction gave insufficient content
            try
                % R2025b: Use ExtractionMethod instead of UseOCR
                txt = extractFileText(p, 'ExtractionMethod', 'ocr');
            catch ocrErr
                warning('OCR failed for %s: %s. Using extracted text anyway.', p, ocrErr.message);
            end
        end
    catch extractErr
        % If extraction completely fails, try OCR as fallback
        try
            % R2025b: Use ExtractionMethod instead of UseOCR
            txt = extractFileText(p, 'ExtractionMethod', 'ocr');
        catch ocrErr
            % If both fail, use empty string and warn
            warning('PDF extraction failed for %s: %s. Creating empty document.', p, extractErr.message);
            txt = '';
        end
    end
    doc_id(i) = "DOC_" + string(i);
    text(i)   = string(txt);
    meta{i}   = struct('path', p, 'bytes', files(i).bytes, 'modified', files(i).datenum);
end
T = table(doc_id, text, meta, 'VariableNames', {'doc_id','text','meta'});
end
