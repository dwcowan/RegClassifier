function T = fetch_crr_eba()
%FETCH_CRR_EBA Download CRR articles from EBA Interactive Single Rulebook (HTML + plaintext).
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
n = numel(hrefs); ids = strings(n,1); files = strings(n,1); titlesS = strings(n,1); urls = strings(n,1);
for i = 1:n
    url = base + string(hrefs{i});
    try
        page = webread(url);
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
T = table(ids, titlesS, urls, files, 'VariableNames', {'article_id','title','url','html_file'});
writetable(T, fullfile(outDir,"index.csv"));
fprintf("Saved %d CRR article pages to %s\n", height(T), outDir);
end
