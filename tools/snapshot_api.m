function snapshot_api(outputFile)
%SNAPSHOT_API Write a snapshot of the public API to JSON (api_manifest.json).
% Captures function/class names and input argument names from signatures.
% Usage:
%   matlab -batch "tools.snapshot_api"
%
% Note: Heuristic parser; intended as a guard against accidental API drift.

    if nargin < 1
        outputFile = fullfile(fileparts(mfilename('fullpath')), '..', 'api_manifest.json');
    end

    repoRoot = fileparts(mfilename('fullpath'));
    repoRoot = fileparts(repoRoot);
    targets = { fullfile(repoRoot,'reg'), fullfile(repoRoot,'+reg') };

    entries = struct('path',{},'symbol',{},'kind',{},'inputs',{});

    files = collectMfiles(targets);
    for i = 1:numel(files)
        f = files{i};
        txt = fileread(f);
        rel = erase(f, repoRoot);
        rel = rel(find(rel~='/',1):end); %#ok<*FNDSB>

        % Class?
        if contains(txt, "classdef")
            % record class symbol
            cls = regexp(txt, 'classdef\s+([A-Za-z]\w*)', 'tokens','once');
            if ~isempty(cls)
                entries(end+1) = struct('path', rel, 'symbol', cls{1}, 'kind', 'class', 'inputs', { { } }); %#ok<AGROW>
            end
            % Methods signatures (public)
            meths = regexp(txt, 'function\s+(?:\[.*?\]\s*=\s*)?([A-Za-z]\w*)\s*\((.*?)\)', 'tokens');
            for k = 1:numel(meths)
                name = meths{k}{0+1};
                args = strtrim(meths[k]{1+1}); %#ok<PFBNS>
                inps = splitArgs(args);
                entries(end+1) = struct('path', rel, 'symbol', name, 'kind', 'method', 'inputs', {inps}); %#ok<AGROW>
            end
            continue
        end

        % Function?
        sig = regexp(txt, 'function\s+(?:\[.*?\]\s*=\s*)?([A-Za-z]\w*)\s*\((.*?)\)', 'tokens','once');
        if ~isempty(sig)
            name = sig{1};
            inps = splitArgs(sig{2});
            entries(end+1) = struct('path', rel, 'symbol', name, 'kind', 'function', 'inputs', {inps}); %#ok<AGROW>
        end
    end

    % Write JSON
    try
        jsonTxt = jsonencode(entries, 'PrettyPrint', true);
    catch
        jsonTxt = jsonencode(entries); % fallback
    end
    fid = fopen(outputFile,'w'); fwrite(fid, jsonTxt); fclose(fid);
    fprintf('[snapshot_api] Wrote %s (%d entries)\n', outputFile, numel(entries));
end

function files = collectMfiles(targets)
    files = {};
    for t = targets
        if ~isfolder(t{1}), continue; end
        d = dir(fullfile(t{1}, '**', '*.m'));
    % Skip examples directory
    d = d(~contains(fullfile({d.folder},{d.name}),[filesep 'examples' filesep]));
        files = [files, fullfile({d.folder},{d.name})]; %#ok<AGROW>
    end
end

function inps = splitArgs(argstr)
    if isempty(argstr), inps = {}; return; end
    parts = regexp(argstr, '\s*,\s*', 'split');
    inps = {};
    for p = parts
        token = strtrim(p{1});
        if token == "", continue; end
        % Drop attributes like (1,1) type
        token = regexprep(token, '\(.*?\)', '');
        token = regexprep(token, '\s+.*$', ''); % keep first word only
        inps{end+1} = token; %#ok<AGROW>
    end
end
