function out = fetch_crr_eurlex(varargin)
%FETCH_CRR_EURLEX Download consolidated CRR PDF from EUR-Lex by date code.
% Usage:
%   fetch_crr_eurlex('Date','20250629')
% Saves to data/raw/crr_YYYYMMDD.pdf
p = inputParser;
addParameter(p,'Date','20250629'); % default (override when new consolidation appears)
parse(p,varargin{:});
d = p.Results.Date;
url = sprintf(['https://eur-lex.europa.eu/legal-content/EN/TXT/PDF/', ...
               '?uri=CELEX:02013R0575-%s'], d);
outDir = fullfile("data","raw"); if ~isfolder(outDir), mkdir(outDir); end
out = fullfile(outDir, "crr_" + d + ".pdf");
try
    websave(out, url);
    fprintf("Saved CRR consolidated PDF: %s\n", out);
catch ME
    error("EUR-Lex download failed: %s", ME.message);
end
end
