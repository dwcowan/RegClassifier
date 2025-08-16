function check_api_drift()
%CHECK_API_DRIFT Compare current API snapshot with api_manifest.json.
% Fails if symbols or input lists differ (prevents accidental refactor drift).
%
% Usage:
%   matlab -batch "tools.snapshot_api; tools.check_api_drift"

    repoRoot = fileparts(mfilename('fullpath'));
    repoRoot = fileparts(repoRoot);
    manifest = fullfile(repoRoot, 'api_manifest.json');
    if ~isfile(manifest)
        fprintf(2, '[check_api_drift] No api_manifest.json found. Run tools.snapshot_api first.\n');
        return
    end

    currFile = tempname + "_api.json";
    tools.snapshot_api(currFile);

    prev = jsondecode(fileread(manifest));
    curr = jsondecode(fileread(currFile));

    diffs = compareEntries(prev, curr);
    if isempty(diffs)
        fprintf('[check_api_drift] OK (no API drift)\n');
    else
        fprintf(2, '[check_api_drift] FAIL — API drift detected:\n');
        for i = 1:numel(diffs)
            fprintf(2, '  - %s\n', diffs{i});
        end
        error('check_api_drift:Failed', 'API drift detected.');
    end
end

function msgs = compareEntries(prev, curr)
    msgs = {};
    key = @(e) string(e.kind) + ":" + string(e.symbol);
    % build maps
    mapPrev = containers.Map('KeyType','char','ValueType','any');
    for i = 1:numel(prev)
        mapPrev(char(key(prev(i)))) = prev(i);
    end
    mapCurr = containers.Map('KeyType','char','ValueType','any');
    for i = 1:numel(curr)
        mapCurr(char(key(curr(i)))) = curr(i);
    end

    % Check removed / changed
    ksPrev = keys(mapPrev);
    for i = 1:numel(ksPrev)
        k = ksPrev{i};
        if ~isKey(mapCurr, k)
            msgs{end+1} = sprintf('Removed symbol: %s', k); %#ok<AGROW>
            continue
        end
        a = mapPrev(k); b = mapCurr(k);
        if ~isequal(string(a.inputs), string(b.inputs))
            msgs{end+1} = sprintf('Changed inputs for %s: [%s] -> [%s]', k, ...
                strjoin(string(a.inputs), ', '), strjoin(string(b.inputs), ', ')); %#ok<AGROW>
        end
    end

    % Check added
    ksCurr = keys(mapCurr);
    for i = 1:numel(ksCurr)
        k = ksCurr{i};
        if ~isKey(mapPrev, k)
            msgs{end+1} = sprintf('Added symbol: %s', k); %#ok<AGROW>
        end
    end
end
