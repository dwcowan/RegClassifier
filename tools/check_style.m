function check_style()
%CHECK_STYLE Lightweight repository style guard for MATLAB.
% Fails (nonzero exit) on style violations defined here.

    fprintf('[check_style] Starting style checks...\n');
    repoRoot = fileparts(mfilename('fullpath'));
    repoRoot = fileparts(repoRoot); % up from /tools to repo root

    targets = { fullfile(repoRoot,'reg'), fullfile(repoRoot,'+reg') };
    files = collectMfiles(targets);

    violations = string.empty(1,0);
    for i = 1:numel(files)
        f = files{i};
        txt = fileread(f);
        lines = splitlines(txt);

        % 1) No tabs
        if contains(txt, sprintf('\t'))
            violations(end+1) = sprintf('%s: contains TAB characters', f); %#ok<AGROW>
        end

        % 2) Line length <= 100
        longIdx = find(strlength(lines) > 100, 1);
        if ~isempty(longIdx)
            violations(end+1) = sprintf('%s: line %d exceeds 100 chars', f, longIdx); %#ok<AGROW>
        end

        % 3) Must start with function or classdef (no scripts)
        firstNonEmpty = lines(find(strlength(strtrim(lines))>0,1));
        if isempty(firstNonEmpty) || ...
           (~startsWith(strtrim(firstNonEmpty), "function") && ~startsWith(strtrim(firstNonEmpty), "classdef"))
            violations(end+1) = sprintf('%s: file must start with function or classdef', f); %#ok<AGROW>
        end

        % 4) Function/class name must match file name (best-effort)
        [~, base, ~] = fileparts(f);
        if ~isempty(firstNonEmpty) && startsWith(strtrim(firstNonEmpty), "function")
            sig = strtrim(firstNonEmpty);
            name = regexp(sig, 'function\s+(?:\[.*?\]\s*=\s*)?([A-Za-z]\w*)\s*\(', 'tokens','once');
            if ~isempty(name) && ~strcmp(name{1}, base)
                violations(end+1) = sprintf('%s: function name "%s" != file name "%s"', f, name{1}, base); %#ok<AGROW>
            end
        elseif ~isempty(firstNonEmpty) && startsWith(strtrim(firstNonEmpty), "classdef")
            pieces = regexp(firstNonEmpty, 'classdef\s+([A-Za-z]\w*)', 'tokens', 'once');
            if ~isempty(pieces) && ~strcmp(pieces{1}, base)
                violations(end+1) = sprintf('%s: class name "%s" != file name "%s"', f, pieces{1}, base); %#ok<AGROW>
            end
        end

        % 5) Encourage help text
        if numel(lines) < 2 || ~startsWith(strtrim(lines{2}), '%')
            violations(end+1) = sprintf('%s: missing help text after signature', f); %#ok<AGROW>
        end

        % --- MonkeyProof-aligned heuristics ---

        % 6) One statement per line: flag lines with 2+ semicolons
        for li = 1:numel(lines)
            ln = lines{li};
            if count(ln, ';') >= 2 && ~startsWith(strtrim(ln), '%')
                violations(end+1) = sprintf('%s: multiple statements on one line (line %d)', f, li); %#ok<AGROW>
                break
            end
        end

        % 7) Parentheses for composite logical expressions (line-based heuristic)
        for li = 1:numel(lines)
            ln = lines{li};
            if contains(ln, '&&') || contains(ln, '||')
                if ~contains(ln, '(') || ~contains(ln, ')')
                    violations(end+1) = sprintf('%s: composite logical expression without parentheses (line %d)', f, li); %#ok<AGROW>
                    break
                end
            end
        end

        % 8) Properties before methods in classdef (coarse)
        if contains(txt, "classdef")
            pIdx = regexp(txt, '\n\s*properties(\(.*?\))?\s*', 'once');
            mIdx = regexp(txt, '\n\s*methods(\(.*?\))?\s*', 'once');
            if ~isempty(mIdx) && ~isempty(pIdx) && mIdx < pIdx
                violations(end+1) = sprintf('%s: methods block appears before properties', f); %#ok<AGROW>
            end
        end
    end

    if isempty(violations)
        fprintf('[check_style] OK\n');
    else
        fprintf(2, '[check_style] FAIL (%d violations)\n', numel(violations));
        for v = violations, fprintf(2, '  - %s\n', v); end
        error('check_style:Failed', 'Style violations found.');
    end
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
