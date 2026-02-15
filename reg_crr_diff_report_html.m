function reg_crr_diff_report_html(dirA, dirB, varargin)
%REG_CRR_DIFF_REPORT_HTML Generate an HTML diff report aligned by Article with EBA links.
% Requires both folders to be produced by fetch_crr_eba_parsed (so index.csv exists)
import mlreportgen.report.*
import mlreportgen.dom.*

p = inputParser;
addParameter(p,'OutDir','runs/crr_diff_report_html');
addParameter(p,'SampleCount',10);
parse(p,varargin{:});
O = p.Results.OutDir; if ~isfolder(O), mkdir(O); end

R = reg.crr_diff_articles(dirA, dirB, 'OutDir', O);
S = readtable(fullfile(O,'summary_by_article.csv'),'TextType','string');

r = Report(fullfile(O,'crr_diff_report'),'html-file');
append(r, TitlePage('Title', 'CRR Article-Aware Diff Report', 'Subtitle', sprintf('%s vs %s', dirA, dirB)));
append(r, TableOfContents);

% Overall summary
sec = Section('Summary');
append(sec, Paragraph(sprintf('Added: %d  Removed: %d  Changed: %d  Same: %d', R.added, R.removed, R.changed, R.same)));
append(r, sec);

% Changed articles table with links
ch = S(S.status=="CHANGED",:);
if ~isempty(ch)
    sec2 = Section('Changed Articles');
    tbl = BaseTable();
    tbl.TableEntriesStyle = {OuterMargin("0pt","0pt","0pt","0pt")};
    append(tbl, TableRow([TableEntry(Paragraph('Article')), TableEntry(Paragraph('Title (A)')), TableEntry(Paragraph('Title (B)')), TableEntry(Paragraph('Links'))]));
    n = min(height(ch), p.Results.SampleCount);
    for i=1:n
        a = ch.article_num(i);
        tA = ch.titleA(i); tB = ch.titleB(i);
        urlA = ch.urlA(i); urlB = ch.urlB(i);
        links = Paragraph();
        if strlength(urlA)>0, append(links, ExternalLink(urlA, 'A')); append(links, Text('  ')); end
        if strlength(urlB)>0, append(links, ExternalLink(urlB, 'B')); end
        append(tbl, TableRow([TableEntry(Paragraph(a)), TableEntry(Paragraph(tA)), TableEntry(Paragraph(tB)), TableEntry(links)]));
    end
    append(sec2, tbl);
    append(r, sec2);
end

% Include first ~300 lines from patch for context
patchFile  = fullfile(O,'patch_by_article.txt');
if isfile(patchFile)
    sec3 = Section('Patch Sample');
    lines = splitlines(string(fileread(patchFile)));
    if numel(lines) > 300, lines = lines(1:300); end
    % Handle API change: PreformattedText -> Preformatted in newer MATLAB
    try
        pre = Preformatted(join(lines, newline));
    catch
        pre = PreformattedText(join(lines, newline));
    end
    append(sec3, pre);
    append(r, sec3);
end

close(r);
fprintf('Wrote HTML diff report: %s\n', fullfile(O,'crr_diff_report.html'));
end
