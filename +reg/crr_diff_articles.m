function R = crr_diff_articles(dirA, dirB, varargin)
%CRR_DIFF_ARTICLES Article-aware diff of two EBA CRR corpora (align by article_num).
% Requires both dirs to have an index.csv from fetch_crr_eba_parsed.m
% Outputs CSV summary and an HTML-safe patch file.
p = inputParser;
addParameter(p,'OutDir','runs/crr_diff_articles'); 
addParameter(p,'MaxLines',300);
parse(p,varargin{:});
O = p.Results.OutDir; if ~isfolder(O), mkdir(O); end

idxA = readtable(fullfile(dirA,'index.csv'));
idxB = readtable(fullfile(dirB,'index.csv'));
% Normalize article_num text
idxA.article_num = string(idxA.article_num);
idxB.article_num = string(idxB.article_num);

% Build maps: article_num -> txt path + url
mapA = containers.Map('KeyType','char','ValueType','any');
mapB = containers.Map('KeyType','char','ValueType','any');
for i=1:height(idxA)
    [~,name] = fileparts(idxA.html_file{i});
    txtPath = fullfile(dirA, strrep(name,'.html','.txt'));
    if isfile(txtPath)
        mapA(char(idxA.article_num(i))) = struct('txt',txtPath,'url',string(idxA.url(i)),'title',string(idxA.title(i)));
    end
end
for i=1:height(idxB)
    [~,name] = fileparts(idxB.html_file{i});
    txtPath = fullfile(dirB, strrep(name,'.html','.txt'));
    if isfile(txtPath)
        mapB(char(idxB.article_num(i))) = struct('txt',txtPath,'url',string(idxB.url(i)),'title',string(idxB.title(i)));
    end
end

keysA = string(keys(mapA)); keysB = string(keys(mapB));
allKeys = unique([keysA; keysB]);

added=0; removed=0; changed=0; same=0;
% Open files with try-catch-finally for resource safety
fidCSV = -1; fidPatch = -1;
try
    fidCSV = fopen(fullfile(O,'summary_by_article.csv'),'w');
    if fidCSV == -1
        error('reg:crr_diff_articles:FileOpenFailed', ...
            'Failed to open summary_by_article.csv for writing');
    end
    fprintf(fidCSV,"article_num,status,titleA,titleB,urlA,urlB\n");

    fidPatch = fopen(fullfile(O,'patch_by_article.txt'),'w');
    if fidPatch == -1
        error('reg:crr_diff_articles:FileOpenFailed', ...
            'Failed to open patch_by_article.txt for writing');
    end

    for k=1:numel(allKeys)
        key = char(allKeys(k));
        inA = isKey(mapA, key); inB = isKey(mapB, key);
        tA = ""; tB = ""; urlA=""; urlB=""; titleA=""; titleB="";
        if inA, tA = string(fileread(mapA(key).txt)); urlA = mapA(key).url; titleA = mapA(key).title; end
        if inB, tB = string(fileread(mapB(key).txt)); urlB = mapB(key).url; titleB = mapB(key).title; end

        if inA && ~inB
            removed = removed + 1;
            fprintf(fidCSV,"%s,REMOVED,\"%s\",\"\",%s,%s\n", key, titleA, urlA, "");
        elseif ~inA && inB
            added = added + 1;
            fprintf(fidCSV,"%s,ADDED,\",\"%s\",%s,%s\n", key, titleB, "", urlB);
        else
            la = splitlines(tA); lb = splitlines(tB);
            if isequal(la, lb)
                same = same + 1;
                fprintf(fidCSV,"%s,SAME,\"%s\",\"%s\",%s,%s\n", key, titleA, titleB, urlA, urlB);
            else
                changed = changed + 1;
                fprintf(fidCSV,"%s,CHANGED,\"%s\",\"%s\",%s,%s\n", key, titleA, titleB, urlA, urlB);
                fprintf(fidPatch, "=== Article %s ===\n%s\n-> %s\n", key, urlA, urlB);
                maxL = max(numel(la), numel(lb));
                cnt = 0;
                for i=1:maxL
                    sa=""; sb="";
                    if i<=numel(la), sa = la(i); end
                    if i<=numel(lb), sb = lb(i); end
                    if sa ~= sb
                        fprintf(fidPatch,"- %s\n+ %s\n", sa, sb);
                        cnt = cnt + 1;
                        if cnt >= p.Results.MaxLines
                            fprintf(fidPatch,"... (truncated) ...\n");
                            break;
                        end
                    end
                end
            end
        end
    end
catch ME
    % Ensure file handles are closed on error
    if fidCSV ~= -1, fclose(fidCSV); end
    if fidPatch ~= -1, fclose(fidPatch); end
    rethrow(ME);
end
% Clean up file handles
if fidCSV ~= -1, fclose(fidCSV); end
if fidPatch ~= -1, fclose(fidPatch); end
R = struct('added',added,'removed',removed,'changed',changed,'same',same,'outdir',O);
fprintf("Article-aware diff: added=%d removed=%d changed=%d same=%d -> %s", added, removed, changed, same, O);
end
