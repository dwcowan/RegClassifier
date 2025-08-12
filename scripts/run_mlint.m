function run_mlint
% RUN_MLINT  Lint MATLAB .m files and emit artifacts for CI.
%
% Outputs (created in repo root):
%   lint/mlint.txt         - text report
%   lint/mlint-summary.md  - summary for GitHub Actions UI
%   lint/mlint.sarif       - SARIF 2.1.0 (only if you still want it)
%
% Env:
%   MLINT_FAIL_ON = 'none' | 'any' | 'error'  (default 'any')
%   MLINT_EXCLUDE = ".git/**,node_modules/**" (comma-separated globs)
%   MLINT_INCLUDE = "src,tests,a/file.m"      (comma-separated; empty = whole repo)

    repoRoot = pwd;
    outDir = fullfile(repoRoot, 'lint');
    if ~exist(outDir, 'dir'), mkdir(outDir); end
    txtPath   = fullfile(outDir, 'mlint.txt');
    sumPath   = fullfile(outDir, 'mlint-summary.md');
    sarifPath = fullfile(outDir, 'mlint.sarif');

    includes = getenvList('MLINT_INCLUDE');
    excludes = getenvList('MLINT_EXCLUDE');

    % ---- discover files (scalar-safe includes) ----
    if isempty(includes)
        files = findMFiles(repoRoot, excludes);
    else
        files = string.empty(1,0);
        for p = includes
            p = strtrim(string(p));
            if p == "", continue; end

            % Build a single full path (force scalar)
            fullp = string(fullfile(repoRoot, char(p)));
            if numel(fullp) > 1, fullp = fullp(1); end
            fullpChar = char(fullp);

            if isfolder(fullpChar)
                files = [files; findMFiles(fullpChar, excludes)]; %#ok<AGROW>
            else
                isAFile = isfile(fullpChar);
                isMFile = endsWith(string(fullpChar), ".m");
                if isAFile && isMFile
                    files(end+1,1) = string(fullpChar); %#ok<AGROW>
                end
            end
        end
        files = unique(files);
    end

    if isempty(files)
        % Create empty artifacts so CI steps can proceed gracefully
        writeEmptyArtifacts(txtPath, sumPath);
        fprintf('[mlint] no MATLAB files to scan (after include/exclude filtering)\n');
        return
    end

    fprintf('Scanning %d MATLAB files...\n', numel(files));

    % ---- run Code Analyzer ----
    allMsgs = table([], [], [], [], [], [], 'VariableNames', ...
        {'file','line','column','id','message','level'});

    for f = files.'
        filePath = char(f);
        fprintf('Linting %s\n', filePath);
        try
            issues = checkcode(filePath, '-id', '-fullpath'); %#ok<*CHCKOK>
        catch ME
            warning('checkcode error on %s: %s', filePath, ME.message);
            issues = [];
        end

        if ~isempty(issues)
            T = struct2table(normalizeMsgs(f, issues), 'AsArray', true);
            allMsgs = [allMsgs; T]; %#ok<AGROW>
        end
    end

    % ---- write artifacts ----
    writeTextReport(txtPath, allMsgs, files);
    writeSummary(sumPath, allMsgs, files, repoRoot);
    writeSarif(sarifPath, allMsgs, repoRoot);  % safe even if empty

    % ---- decide failure policy ----
    failOn = lower(string(getenvDefault('MLINT_FAIL_ON','any')));
    exitCode = 0;
    if ~isempty(allMsgs)
        switch failOn
            case "any"
                exitCode = 1;
            case "error"
                if any(allMsgs.level == "error"), exitCode = 1; end
            case "none"
                % always succeed
            otherwise
                % unknown value → be safe and fail on any
                exitCode = 1;
        end
    end

    fprintf('[mlint] scanned %d files, found %d issues (failOn=%s)\n', ...
        numel(files), height(allMsgs), failOn);

    if exitCode ~= 0
        error('Lint issues found (MLINT_FAIL_ON=%s). See artifacts (lint/*).', failOn);
    end
end

% ========= helpers =========

function L = getenvDefault(name, defaultVal)
    val = getenv(name);
    if isempty(val), L = defaultVal; else, L = val; end
end

function xs = getenvList(name)
    val = strtrim(string(getenv(name)));
    if val == "" || strcmpi(val, "''") || strcmpi(val, '""')
        xs = string.empty(1,0); return
    end
    parts = split(val, {',',';','|',newline});
    xs = strtrim(string(parts));
    xs(xs=="") = [];
end

function files = findMFiles(root, excludes)
    all = dir(fullfile(root, "**", "*.m"));
    files = unique(string(fullfile({all.folder}, {all.name}))');
    if isempty(excludes), return; end
    keep = true(size(files));
    for i = 1:numel(files)
        r = relPath(root, files(i));
        if any(matchesAnyGlob(r, excludes)), keep(i) = false; end
    end
    files = files(keep);
end

function yes = matchesAnyGlob(rel, globs)
    yes = false;
    for g = globs.'
        if globMatch(rel, g), yes = true; return; end
    end
end

function tf = globMatch(rel, pat)
    rel = char(rel); pat = char(pat);
    pat = strrep(pat, '.', '\.');
    pat = strrep(pat, '**', '<<<GLOBSTAR>>>');
    pat = strrep(pat, '*', '[^/]*');
    pat = strrep(pat, '<<<GLOBSTAR>>>', '.*');
    pat = strrep(pat, '?', '.');
    expr = ['^', pat, '$'];
    tf = ~isempty(regexp(rel, expr, 'once'));
end

function r = relPath(root, p)
    root = char(root); p = char(p);
    if startsWith(p, [root filesep])
        r = string(p(numel(root)+2:end));
    else
        r = string(p);
    end
    r = strrep(r, filesep, '/');
end

function S = normalizeMsgs(file, msgs)
    S = struct('file',[],'line',[],'column',[],'id',[],'message',[],'level',[]);
    S = S([]);  % empty
    for k = 1:numel(msgs)
        m = msgs(k);
        line = int32(getfield_default(m,'line',1)); %#ok<GFLD>
        col  = int32(getfield_default(m,'column',1));
        id   = string(getfield_fallback(m,["identifier","id"],"MLINT"));
        msg  = string(getfield_default(m,'message',"Code Analyzer issue"));
        level = classifySeverity(id, msg);
        S(end+1) = struct('file',string(file),'line',line,'column',col, ...
                          'id',id,'message',msg,'level',level); %#ok<AGROW>
    end
end

function v = getfield_default(s, name, def)
    if isfield(s, name), v = s.(name); else, v = def; end
end
function v = getfield_fallback(s, names, def)
    v = def;
    for n = names
        if isfield(s, n), v = s.(n); return; end
    end
end

function lvl = classifySeverity(id, msg)
    idLower = lower(strtrim(id));
    msgLower = lower(strtrim(msg));
    if contains(idLower, "syntax") || contains(msgLower, "parse error")
        lvl = "error"; return
    end
    % Everything else treated as 'warning' by default
    lvl = "warning";
end

function writeTextReport(path, T, files)
    fid = fopen(path, 'w'); c = onCleanup(@() fclose(fid));
    fprintf(fid, "MATLAB Code Analyzer Report\n");
    fprintf(fid, "Scanned files: %d\n", numel(files));
    fprintf(fid, "Issues: %d\n\n", height(T));
    if isempty(T), return; end
    [uFiles, ~, idx] = unique(T.file);
    for i = 1:numel(uFiles)
        f = uFiles(i); rows = T(idx==i, :);
        rows = sortrows(rows, {'line','column'});
        fprintf(fid, "File: %s\n", f);
        for r = 1:height(rows)
            fprintf(fid, "  L%-5d C%-4d %-6s %-20s %s\n", ...
                rows.line(r), rows.column(r), upper(rows.level(r)), rows.id(r), rows.message(r));
        end
        fprintf(fid, "\n");
    end
end

function writeSummary(path, T, files, repoRoot)
    fid = fopen(path, 'w'); c = onCleanup(@() fclose(fid));
    fprintf(fid, "## MATLAB Lint Summary\n\n");
    fprintf(fid, "- Scanned files: **%d**\n", numel(files));
    fprintf(fid, "- Issues found: **%d**\n\n", height(T));
    if isempty(T)
        fprintf(fid, "_No issues found._\n"); return;
    end
    [ids,~,k] = unique(T.id); counts = accumarray(k, 1);
    [counts, order] = sort(counts, 'descend'); ids = ids(order);
    fprintf(fid, "### Top findings by rule\n");
    for i = 1:min(10,numel(ids))
        fprintf(fid, "- `%s`: %d\n", ids(i), counts(i));
    end
    fprintf(fid, "\n### Sample (first 10)\n");
    S = T(1:min(10,height(T)), :);
    for i = 1:height(S)
        fprintf(fid, "- `%s:%d` **%s** %s — %s\n", ...
            relPath(repoRoot, S.file(i)), S.line(i), upper(string(S.level(i))), S.id(i), S.message(i));
    end
end

function writeSarif(path, T, repoRoot)
    % Minimal SARIF v2.1.0 (safe to generate even if you don't upload it)
    sarif.version = "2.1.0";
    sarif.runs = {struct()};
    run.tool.driver.name = "MATLAB Code Analyzer (checkcode)";
    run.tool.driver.rules = uniqueRules(T);
    run.results = table2results(T, repoRoot);
    sarif.runs{1} = run;
    txt = jsonencode(sarif);
    txt = strrep(txt, filesep, '/');
    fid = fopen(path, 'w'); c = onCleanup(@() fclose(fid));
    fwrite(fid, txt, 'char');
end

function rules = uniqueRules(T)
    if isempty(T), rules = {}; return; end
    ids = unique(T.id, 'stable');
    rules = cell(numel(ids),1);
    for i = 1:numel(ids)
        rule.id = char(ids(i));
        rule.shortDescription.text = char(ids(i));
        rule.fullDescription.text = "Reported by MATLAB Code Analyzer";
        rule.helpUri = "";
        rules{i} = rule;
    end
end

function results = table2results(T, repoRoot)
    if isempty(T), results = {}; return; end
    results = cell(height(T),1);
    for i = 1:height(T)
        rel = char(relPath(repoRoot, T.file(i)));
        res.ruleId = char(T.id(i));
        res.level  = char(T.level(i)); % "warning" | "error"
        res.message.text = char(T.message(i));
        res.locations = {struct( ...
            'physicalLocation', struct( ...
                'artifactLocation', struct('uri', rel), ...
                'region', struct( ...
                    'startLine', double(T.line(i)), ...
                    'startColumn', double(T.column(i)))))};
        results{i} = res;
    end
end

function writeEmptyArtifacts(txtPath, sumPath)
    fid = fopen(txtPath, 'w'); c = onCleanup(@() fclose(fid)); %#ok<NASGU>
    fprintf(fid, "No MATLAB files to lint.\n");
    fid2 = fopen(sumPath, 'w'); c2 = onCleanup(@() fclose(fid2)); %#ok<NASGU>
    fprintf(fid2, "## MATLAB Lint Summary\n\n_No MATLAB files to lint._\n");
end
