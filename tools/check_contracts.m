function check_contracts()
%CHECK_CONTRACTS Basic contract checks for MATLAB code under /reg or +reg.
% Encourages arguments blocks and explicit error identifiers, plus MonkeyProof-aligned heuristics.

    fprintf('[check_contracts] Starting contract checks...\n');
    repoRoot = fileparts(mfilename('fullpath'));
    repoRoot = fileparts(repoRoot);

    % --- Mode-aware enforcement (clean-room vs build) ---
    % Read mode from /contexts/mode.json (default: clean-room)
    modeFile = fullfile(repoRoot, 'contexts', 'mode.json');
    mode = 'clean-room';
    try
        if isfile(modeFile)
            raw = fileread(modeFile);
            data = jsondecode(raw);
            if isfield(data,'mode')
                mode = string(data.mode);
            end
        end
    catch
        % If jsondecode is unavailable or fails, default remains 'clean-room'
    end

    targets = { fullfile(repoRoot,'reg'), fullfile(repoRoot,'+reg') };
    files = collectMfiles(targets);

    violations = string.empty(1,0);
    for i = 1:numel(files)
        f = files{i};
        txt = fileread(f);
        lines = splitlines(txt);
        firstNonEmpty = lines(find(strlength(strtrim(lines))>0,1));
        isFunction = ~isempty(firstNonEmpty) && startsWith(strtrim(firstNonEmpty), "function");

        % 1) arguments block recommended for public functions
        if isFunction && ~contains(txt, "arguments")
            violations(end+1) = sprintf('%s: missing arguments block', f); %#ok<AGROW>
        end

        % 2) error identifiers should be namespaced
        errCalls = regexp(txt, 'error\(([^)]*)\)', 'tokens');
        for k = 1:numel(errCalls)
            args = strtrim(errCalls{k}{1});
            id = regexp(args, '^(["'']).*?\1', 'match', 'once');
            if isempty(id)
                violations(end+1) = sprintf('%s: error call should start with an identifier string', f); %#ok<AGROW>
            else
                if ~contains(id, "reg:")
                    violations(end+1) = sprintf('%s: error id should be namespaced "reg:...": %s', f, id); %#ok<AGROW>
                end
            end
        end

        % 3) Avoid top-level assignments suggesting scripts
        if ~isempty(regexp(txt, '^\s*[A-Za-z]\w*\s*=\s*[^=].*$', 'once'))
            violations(end+1) = sprintf('%s: top-level assignment detected; prefer functions', f); %#ok<AGROW>
        end

        % --- MonkeyProof-aligned heuristics ---

        % 4) Boolean naming (avoid negated boolean identifiers)
        badBool = regexp(txt, '\b(not|no)[A-Z]\w*', 'match');
        if ~isempty(badBool)
            violations(end+1) = sprintf('%s: negated boolean name(s): %s', f, strjoin(unique(badBool), ', ')); %#ok<AGROW>
        end

        % 5) Counts n-prefix preference
        badCounts = regexp(txt, '\b(num|count|total)[A-Z]\w*', 'match');
        if ~isempty(badCounts)
            violations(end+1) = sprintf('%s: prefer n* prefix for counts instead of: %s', f, strjoin(unique(badCounts), ', ')); %#ok<AGROW>
        end

        % 6) Magic numbers (same literal multiple times)
        nums = regexp(txt, '(?<!=)\b(\d+(\.\d+)?)(e[+-]?\d+)?\b', 'match');
        if numel(nums) >= 3
            violations(end+1) = sprintf('%s: possible magic numbers; hoist repeated numerics to named constants', f); %#ok<AGROW>
        end

        % 7) Ban globals and dynamic eval
        if ~isempty(regexp(txt, '\bglobal\b|\beval(in)?\b|\bassignin\b|(^|\n)\s*!', 'once'))
            violations(end+1) = sprintf('%s: use of global/eval/assignin/! is disallowed', f); %#ok<AGROW>
        end

        
        % 9) In clean-room mode, require NotImplemented path
        if mode == "clean-room"
            if isempty(regexp(txt, 'error\s*\(\s*([''"])reg:[a-zA-Z]+:NotImplemented\1', 'once'))
                violations(end+1) = sprintf('%s: clean-room mode requires NotImplemented error path (e.g., error(\"reg:<layer>:NotImplemented\", ...))', f); %#ok<AGROW>
            end
        end

        % 8) Simple nesting/branching depth proxy
        nestCount = numel(regexp(txt, '\b(if|for|while|switch|try)\b', 'match'));
        if nestCount >= 8
            violations(end+1) = sprintf('%s: high branching/nesting; consider refactor (count=%d)', f, nestCount); %#ok<AGROW>
        end
    end

    if isempty(violations)
        fprintf('[check_contracts] OK\n');
    else
        fprintf(2, '[check_contracts] FAIL (%d violations)\n', numel(violations));
        for v = violations, fprintf(2, '  - %s\n', v); end
        error('check_contracts:Failed', 'Contract violations found.');
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
