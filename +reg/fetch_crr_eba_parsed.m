function T = fetch_crr_eba_parsed(varargin)
%FETCH_CRR_EBA_PARSED Download CRR articles (EBA ISRB) with parsed Article numbers.
% Name-Value: 'OutDir' (default: data/eba_isrb/crr)
p = inputParser;
addParameter(p,'OutDir', fullfile("data","eba_isrb","crr"));
parse(p,varargin{:});
outDir = p.Results.OutDir;
if ~isfolder(outDir), mkdir(outDir); end

base = "https://eba.europa.eu";
root = base + "/regulation-and-policy/single-rulebook/interactive-single-rulebook/12674";
html = webread(root);
tree = htmlTree(html);
a = findElement(tree, "a");
hrefs = getAttribute(a, "href");
txt   = extractHTMLText(a);
mask  = contains(txt, "Article") & contains(hrefs, "/interactive-single-rulebook/");
hrefs = hrefs(mask);
titles= txt(mask);
[~, ia] = unique(hrefs, 'stable'); hrefs = hrefs(ia); titles = titles(ia);

n = numel(hrefs);
article_num = strings(n,1);
ids = strings(n,1);
files = strings(n,1);
titlesS = strings(n,1);
urls = strings(n,1);
for i = 1:n
    url = base + string(hrefs{i});
    try
        page = webread(url);
        htmlPath = fullfile(outDir, sprintf('CRR_art_%04d.html', i));
        txtPath  = fullfile(outDir, sprintf('CRR_art_%04d.txt', i));
        fid=fopen(htmlPath,'w'); fwrite(fid, page); fclose(fid);
        t = htmlTree(page);
        bodyTxt = extractHTMLText(t);
        writelines(string(bodyTxt), txtPath);
        % Try to parse "Article 180", "Article 4(1)(a)" etc.
        titleStr = string(titles{i});
        m = regexp(titleStr, 'Article\s+([0-9A-Za-z\(\)\.]+)', 'tokens', 'once');
        if ~isempty(m)
            article_num(i) = string(m{1});
        else
            % Fallback: scan body for first "Article N"
            m2 = regexp(bodyTxt, 'Article\s+([0-9A-Za-z\(\)\.]+)', 'tokens', 'once');
            if ~isempty(m2), article_num(i) = string(m2{1}); end
        end
        ids(i) = "CRR_" + (article_num(i) ~= "" ? article_num(i) : string(i));
        files(i) = htmlPath;
        titlesS(i) = titleStr;
        urls(i) = url;
        pause(0.2);
    catch ME
        warning("Failed fetching %s: %s", url, ME.message);
    end
end

T = table(ids, article_num, titlesS, urls, files, 'VariableNames', ...
    {'article_id','article_num','title','url','html_file'});
writetable(T, fullfile(outDir,"index.csv"));
fprintf("Saved %d CRR article pages to %s
", height(T), outDir);
end
