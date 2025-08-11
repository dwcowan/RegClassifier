function T = fetch_crr_eba(args)
%FETCH_CRR_EBA Download CRR articles from EBA Interactive Single Rulebook (HTML + plaintext).
% T = FETCH_CRR_EBA(Name,Value) downloads CRR articles and returns a table with
% metadata about the downloaded files.
%
% Name-Value arguments:
%   'Timeout'     Timeout in seconds for each web request. Default is 15.
%   'MaxArticles' Maximum number of articles to download. Default is Inf.
%
% The function attempts to download up to MaxArticles. If a request times out,
% any articles successfully fetched before the timeout are returned.

arguments
    args.Timeout (1,1) double {mustBePositive} = 15
    args.MaxArticles (1,1) double {mustBePositive} = Inf
end

base = "https://eba.europa.eu";
root = base + "/regulation-and-policy/single-rulebook/interactive-single-rulebook/12674";
webOpts = weboptions('Timeout',args.Timeout);
try
    html = webread(root, webOpts);
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
nTotal = numel(hrefs);
n = min(nTotal, args.MaxArticles);
n = floor(n);
hrefs = hrefs(1:n); titles = titles(1:n);
ids = strings(n,1); files = strings(n,1); titlesS = strings(n,1); urls = strings(n,1);
for i = 1:n
    url = base + string(hrefs{i});
    try
        page = webread(url, webOpts);
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
        isInterrupt = isa(ME, 'matlab.exception.InterruptException') || ...
            strcmp(ME.identifier, 'MATLAB:OperationTerminatedByUser') || ...
            any(cellfun(@(e) isa(e, 'matlab.exception.InterruptException') || ...
            strcmp(e.identifier, 'MATLAB:OperationTerminatedByUser'), ME.cause));
        if isInterrupt
            rethrow(ME);
        end
        warning("Failed fetching %s: %s", url, ME.message);
        if contains(ME.identifier, 'Timeout')
            break
        end
    end
end
valid = ids ~= "";
T = table(ids(valid), titlesS(valid), urls(valid), files(valid), 'VariableNames', {'article_id','title','url','html_file'});
writetable(T, fullfile(outDir,"index.csv"));
fprintf("Saved %d CRR article pages to %s\n", height(T), outDir);
end
