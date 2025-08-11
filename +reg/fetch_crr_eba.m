function T = fetch_crr_eba(varargin)
%FETCH_CRR_EBA Download CRR articles from EBA Interactive Single Rulebook (HTML + plaintext).
%   T = FETCH_CRR_EBA(Name,Value) downloads articles from the EBA
%   Interactive Single Rulebook. Name/value options:
%     'Timeout'     - timeout in seconds for web requests (default 15)
%     'MaxArticles' - maximum number of articles to download (default Inf)
%   The function returns a table of all successfully downloaded articles
%   and will return partial results if individual requests time out.

p = inputParser;
addParameter(p,'Timeout',15);
addParameter(p,'MaxArticles',Inf);
parse(p,varargin{:});
timeout = p.Results.Timeout;
maxArticles = p.Results.MaxArticles;

base = "https://eba.europa.eu";
root = base + "/regulation-and-policy/single-rulebook/interactive-single-rulebook/12674";
opts = weboptions('Timeout',timeout);
try
    html = webread(root, opts);
catch ME
    warning("Failed fetching %s: %s", root, ME.message);
    T = table(string.empty(0,1), string.empty(0,1), string.empty(0,1), string.empty(0,1), ...
        'VariableNames', {'article_id','title','url','html_file'});
    return
end
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
n = numel(hrefs);
m = floor(min(n, maxArticles));
ids = strings(m,1); files = strings(m,1); titlesS = strings(m,1); urls = strings(m,1);
for i = 1:m
    url = base + string(hrefs{i});
    try
        page = webread(url, opts);
        ids(i) = "CRR_" + string(i);
        htmlPath = fullfile(outDir, ids(i) + ".html");
        txtPath  = fullfile(outDir, ids(i) + ".txt");
        fid=fopen(htmlPath,'w'); fwrite(fid, page); fclose(fid);
        t = htmlTree(page); bodyTxt = extractHTMLText(t);
        writelines(string(bodyTxt), txtPath);
        files(i) = htmlPath;
        titlesS(i) = string(titles{i});
        urls(i) = url;
        pause(0.2); % politeness
    catch ME
        warning("Failed fetching %s: %s", url, ME.message);
    end
end
valid = ids ~= "";
T = table(ids(valid), titlesS(valid), urls(valid), files(valid), 'VariableNames', {'article_id','title','url','html_file'});
writetable(T, fullfile(outDir,"index.csv"));
fprintf("Saved %d CRR article pages to %s\n", height(T), outDir);
end
