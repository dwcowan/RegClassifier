function T = fetch_crr_eba(varargin)
%FETCH_CRR_EBA Download CRR articles from EBA Interactive Single Rulebook (HTML + plaintext).
% T = fetch_crr_eba('maxArticles',N) limits the download to the first N articles.
% When the full corpus is fetched (default), pages are downloaded in parallel
% using PARFEVAL while enforcing a 0.2s politeness delay between requests.

p = inputParser;
addParameter(p,'maxArticles',inf);
parse(p,varargin{:});
maxArticles = p.Results.maxArticles;

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
% Deduplicate while preserving order
[~, ia] = unique(hrefs, 'stable');
hrefs = hrefs(ia); titles = titles(ia);

outDir = fullfile("data","eba_isrb","crr"); if ~isfolder(outDir), mkdir(outDir); end
nAll = numel(hrefs);
n = min(nAll, maxArticles);
ids = strings(n,1); files = strings(n,1); titlesS = strings(n,1); urls = strings(n,1);

if n < nAll
    % Sequential fetch when limiting number of articles
    for i = 1:n
        url = base + string(hrefs{i});
        [ids(i), titlesS(i), urls(i), files(i)] = fetchOne(base, hrefs{i}, titles{i}, i, outDir);
        pause(0.2); % politeness
    end
else
    % Full fetch: download in parallel with politeness delay
    pool = gcp('nocreate'); if isempty(pool), pool = parpool; end
    futures(n) = parallel.FevalFuture;
    for i = 1:n
        if i > 1, pause(0.2); end
        futures(i) = parfeval(pool,@fetchOne,4,base,hrefs{i},titles{i},i,outDir);
    end
    for j = 1:n
        try
            [idx, id, titleS, url, file] = fetchNext(futures);
            ids(idx) = id; titlesS(idx) = titleS; urls(idx) = url; files(idx) = file;
        catch ME
            warning("Failed fetching article %d: %s", j, ME.message);
        end
    end
end

T = table(ids, titlesS, urls, files, 'VariableNames', {'article_id','title','url','html_file'});
writetable(T, fullfile(outDir,"index.csv"));
fprintf("Saved %d CRR article pages to %s\n", height(T), outDir);
end

function [id, titleS, url, htmlPath] = fetchOne(base, href, title, idx, outDir)
%FETCHONE Fetch a single article and save HTML + plaintext
url = base + string(href);
id = "CRR_" + string(idx);
htmlPath = fullfile(outDir, id + ".html");
txtPath  = fullfile(outDir, id + ".txt");
try
    page = webread(url);
    fid=fopen(htmlPath,'w'); fwrite(fid, page); fclose(fid);
    t = htmlTree(page); bodyTxt = extractHTMLText(t);
    writelines(string(bodyTxt), txtPath);
    titleS = string(title);
catch ME
    warning("Failed fetching %s: %s", url, ME.message);
    titleS = ""; url = ""; htmlPath = "";
end
end
