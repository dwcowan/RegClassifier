function check_cc4m()
%CHECK_CC4M Heuristic CC4M-style compliance checks for MATLAB code.
% Focus: complexity, nesting, forbidden/interactive APIs, docblocks, headless portability.

    fprintf('[check_cc4m] Starting CC4M compliance checks...\n');
    repoRoot = fileparts(mfilename('fullpath')); repoRoot = fileparts(repoRoot);
    cfgFile = fullfile(repoRoot, 'cc4m_config.json');
    cfg = struct('maxCyclomatic',10,'maxNesting',3, ...
                 'forbiddenAPIs',{{'eval','evalin','assignin','global'}}, ...
                 'headlessAPIs',{{'figure','uifigure','uigetfile','uiputfile','uigetdir','uiwait','waitbar','input','pause'}}, ...
                 'discouragedAPIs',{{'str2num'}}, 'warnOnDeprecated', true);

    if isfile(cfgFile)
        try
            c = jsondecode(fileread(cfgFile));
            fn = fieldnames(c);
            for i=1:numel(fn), cfg.(fn{i}) = c.(fn{i}); end
        catch
            fprintf(2,'[check_cc4m] Warning: failed to parse cc4m_config.json; using defaults.\n');
        end
    end

    targets = { fullfile(repoRoot,'reg'), fullfile(repoRoot,'+reg') };
    files = collectMfiles(targets);

    errors = string.empty(1,0);
    warnings = string.empty(1,0);

    for i = 1:numel(files)
        f = files{i};
        txt = fileread(f);
        lines = splitlines(txt);

        % 1) Docblock presence right after signature
        if startsWith(strtrim(lines{1}), "function") || startsWith(strtrim(lines{1}), "classdef")
            if numel(lines) < 2 || ~startsWith(strtrim(lines{2}), "%")
                warnings(end+1) = sprintf('%s: missing docblock after signature (recommend doc completeness)', f);
            end
        end

        % 2) Complexity (cyclomatic approximation): 1 + count of branch/loop tokens
        cyclo = 1 + numel(regexp(txt, '\b(if|elseif|for|while|switch|case|catch)\b', 'match')) ...
                  + numel(regexp(txt, '&&|\|\|', 'match'));
        if cyclo > cfg.maxCyclomatic
            errors(end+1) = sprintf('%s: cyclomatic complexity %d > %d', f, cyclo, cfg.maxCyclomatic);
        end

        % 3) Nesting depth approximation
        tokens = regexp(txt, '\b(if|for|while|switch|try|classdef|function)\b|\bend\b', 'match');
        depth = 0; maxDepth = 0;
        for t = 1:numel(tokens)
            tk = tokens{t};
            if any(strcmp(tk, {'if','for','while','switch','try','classdef','function'}))
                depth = depth + 1;
                if depth > maxDepth, maxDepth = depth; end
            elseif strcmp(tk, 'end')
                depth = max(depth - 1, 0);
            end
        end
        if maxDepth > cfg.maxNesting
            errors(end+1) = sprintf('%s: nesting depth %d > %d', f, maxDepth, cfg.maxNesting);
        end

        % 4) Forbidden APIs
        for j = 1:numel(cfg.forbiddenAPIs)
            ap = cfg.forbiddenAPIs{j};
            if ~isempty(regexp(txt, ['\b' ap '\s*\('], 'once')) || contains(txt, [' ' ap ' ']) || contains(txt, [ap ';'])
                errors(end+1) = sprintf('%s: forbidden API used: %s', f, ap);
            end
        end

        % 5) Headless portability: flag interactive/GUI calls
        for j = 1:numel(cfg.headlessAPIs)
            ap = cfg.headlessAPIs{j};
            if ~isempty(regexp(txt, ['\b' ap '\s*\('], 'once'))
                warnings(end+1) = sprintf('%s: headless portability risk: %s', f, ap);
            end
        end

        % 6) Discouraged APIs
        for j = 1:numel(cfg.discouragedAPIs)
            ap = cfg.discouragedAPIs{j};
            if ~isempty(regexp(txt, ['\b' ap '\s*\('], 'once'))
                warnings(end+1) = sprintf('%s: discouraged API: %s (prefer safer alternative)', f, ap);
            end
        end
    end

    if ~isempty(warnings)
        fprintf('[check_cc4m] Warnings:\n');
        for w = warnings, fprintf('  - %s\n', w); end
    end

    if isempty(errors)
        fprintf('[check_cc4m] OK\n');
    else
        fprintf(2, '[check_cc4m] FAIL (%d errors)\n', numel(errors));
        for e = errors, fprintf(2, '  - %s\n', e); end
        error('check_cc4m:Failed', 'CC4M compliance errors found.');
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
