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
        txt = extractFileText(p, 'IgnoreInvisibleText',true);
        if strlength(strtrim(txt)) < 20
            txt = extractFileText(p, 'UseOCR', true);
        end
    catch
        txt = extractFileText(p, 'UseOCR', true);
    end
    doc_id(i) = "DOC_" + string(i);
    text(i)   = string(txt);
    meta{i}   = struct('path', p, 'bytes', files(i).bytes, 'modified', files(i).datenum);
end
T = table(doc_id, text, meta, 'VariableNames', {'doc_id','text','meta'});
end
