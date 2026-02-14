function out = reg_crr_sync(varargin)
%REG_CRR_SYNC One-stop sync for CRR sources (EUR-Lex PDF + EBA ISRB articles).
% Usage:
%   reg_crr_sync('Date','20250629')
% Creates:
%   data/raw/crr_YYYYMMDD.pdf (EUR-Lex)
%   data/eba_isrb/crr_YYYYMMDD/*  (EBA HTML + TXT + index.csv)
p = inputParser;
addParameter(p,'Date', datestr(now,'yyyymmdd'));
parse(p,varargin{:});
D = p.Results.Date;

% 1) EUR-Lex consolidated PDF
try
    pdfPath = reg.fetch_crr_eurlex('Date', D);
catch ME
    warning('EUR-Lex fetch failed: %s', ME.message);
    pdfPath = "";
end

% 2) EBA ISRB articles (date-stamped subfolder)
outDir = fullfile("data","eba_isrb","crr_" + D);
if ~isfolder(outDir), mkdir(outDir); end
try
    T = reg.fetch_crr_eba_parsed('OutDir', outDir);
catch ME
    warning('EBA fetch failed: %s', ME.message);
    T = table();
end

out = struct('pdf', pdfPath, 'eba_dir', outDir, 'eba_index', fullfile(outDir,'index.csv'));
fprintf('CRR sync complete. PDF=%s  EBA_DIR=%s\n', pdfPath, outDir);
end
