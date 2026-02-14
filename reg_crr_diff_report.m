function reg_crr_diff_report(dirA, dirB, varargin)
%REG_CRR_DIFF_REPORT Generate a PDF diff report comparing two CRR EBA text dumps.
% Example:
%   reg_crr_diff_report('data/eba_isrb/crr_20241201', 'data/eba_isrb/crr_20250629')
import mlreportgen.report.*
import mlreportgen.dom.*

p = inputParser;
addParameter(p,'OutDir','runs/crr_diff_report');
addParameter(p,'SampleCount',10);
parse(p,varargin{:});
O = p.Results.OutDir; if ~isfolder(O), mkdir(O); end

% Compute diff summary & patch
R = reg.crr_diff_versions(dirA, dirB, 'OutDir', O);
summaryCSV = fullfile(O,'summary.csv');
patchFile  = fullfile(O,'patch.txt');

% Report
r = Report(fullfile(O,'crr_diff_report'),'pdf');
append(r, TitlePage('Title', 'CRR Version Diff Report', 'Subtitle', sprintf('%s vs %s', dirA, dirB)));
append(r, TableOfContents);

% Summary table
S = readtable(summaryCSV);
sec = Section('Summary');
append(sec, Paragraph(sprintf('Added: %d  Removed: %d  Changed: %d  Same: %d', R.added, R.removed, R.changed, R.same)));
append(sec, FormalTable(S(1:min(height(S),50),:)));
append(r, sec);

% Sample changed files (first N entries)
changed = S(strcmp(S.status,'CHANGED'),:);
N = min(height(changed), p.Results.SampleCount);
if N > 0
    sec2 = Section(sprintf('Samples (first %d changed files)', N));
    txt = fileread(patchFile);
    % For brevity, include first ~300 lines of patch
    lines = splitlines(string(txt));
    if numel(lines) > 300, lines = lines(1:300); end
    % Handle API change: PreformattedText -> Preformatted
    try
        pre = Preformatted(join(lines, newline));
    catch
        pre = PreformattedText(join(lines, newline));
    end
    append(sec2, pre);
    append(r, sec2);
end

close(r);
fprintf('Wrote diff report: %s', fullfile(O,'crr_diff_report.pdf'));
end
