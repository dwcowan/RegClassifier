function R = crr_diff_versions(dirA, dirB, varargin)
%CRR_DIFF_VERSIONS Diff two CRR corpora (A vs B) gathered via EBA fetcher or processed text.
% Compares per-file plaintext by filename alignment and computes simple line-level diffs.
% Returns struct with added/removed/changed counts and writes a CSV summary and a txt patch file.
p = inputParser;
addParameter(p,'OutDir','runs/crr_diff',@ischar);
parse(p,varargin{:});
O = p.Results.OutDir; if ~isfolder(O), mkdir(O); end

A = dir(fullfile(dirA, '*.txt'));
B = dir(fullfile(dirB, '*.txt'));
mapA = containers.Map();
for i = 1:numel(A)
    mapA(A(i).name) = fullfile(A(i).folder, A(i).name);
end
mapB = containers.Map();
for i = 1:numel(B)
    mapB(B(i).name) = fullfile(B(i).folder, B(i).name);
end
keys = unique([string({A.name})'; string({B.name})'], 'stable');

added=0; removed=0; changed=0; same=0;
% Write CSV header
fidCSV = fopen(fullfile(O,'summary.csv'),'w');
fprintf(fidCSV, "file,status\n");
fidPatch = fopen(fullfile(O,'patch.txt'),'w');

for k = 1:numel(keys)
    f = char(keys(k));
    inA = isKey(mapA, f); inB = isKey(mapB, f);
    if inA && ~inB
        removed = removed + 1;
        fprintf(fidCSV,"%s,REMOVED\n", f);
    elseif ~inA && inB
        added = added + 1;
        fprintf(fidCSV,"%s,ADDED\n", f);
    else
        ta = splitlines(string(fileread(mapA(f))));
        tb = splitlines(string(fileread(mapB(f))));
        if isequal(ta, tb)
            same = same + 1;
            fprintf(fidCSV,"%s,SAME\n", f);
        else
            changed = changed + 1;
            fprintf(fidCSV,"%s,CHANGED\n", f);
            % naive unified-like diff
            fprintf(fidPatch, "=== %s ===\n", f);
            maxL = max(numel(ta), numel(tb));
            for i=1:maxL
                sa = ""; sb = "";
                if i<=numel(ta), sa = ta(i); end
                if i<=numel(tb), sb = tb(i); end
                if sa ~= sb
                    fprintf(fidPatch, "- %s\n", sa);
                    fprintf(fidPatch, "+ %s\n", sb);
                end
            end
        end
    end
end

fclose(fidCSV); fclose(fidPatch);
R = struct('added',added,'removed',removed,'changed',changed,'same',same,'outdir',O);
fprintf("Diff summary: added=%d removed=%d changed=%d same=%d -> %s\n", added, removed, changed, same, O);
end

