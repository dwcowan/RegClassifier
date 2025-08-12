function run_mlint
% RUN_MLINT  Lint MATLAB .m files and emit artifacts for CI.
%
% Outputs:
%   lint/mlint.txt
%   lint/mlint-summary.md
%   lint/mlint.sarif
%
% Env:
%   MLINT_FAIL_ON = 'none' | 'any' | 'error'  (default 'any')
%   MLINT_EXCLUDE = ".git/**,node_modules/**" (comma-separated globs)
%   MLINT_INCLUDE = "src,tests,a/file.m"      (comma-separated; empty = whole repo)

    repoRoot = string(pwd);
    outDir = fullfile(repoRoot, "lint");
    if ~isfolder(outDir), mkdir(outDir); end
    txtPath   = fullfile(outDir, "mlint.txt");
    sumPath   = fullfile(outDir, "mlint-summary.md");
    sarifPath = fullfile(outDir, "mlint.sarif");

    includes = getenvList("MLINT_INCLUDE");
    excludes = getenvList("MLINT_EXCLUDE");

    % -------- Discover files (string-safe, newline-safe) --------
    if isempty(includes)
        files = findMFiles(repoRoot, excludes);
    else
        files = string.empty(0,1);
        for p = includes(:).'
            if p == "", continue; end
            % Split any accidental multi-line entries into separate paths
            parts = splitlines(p);
            parts(parts=="") = [];
            for q = parts(:).'
                q = strtrim(q); %#ok<FXSET>
                if q == "", continue; end
                fullp = fullfile(repoRoot, q);     % all string
                if isfolder(fullp)
                    files = [files; findMFiles(fullp, excludes)]; %#ok<AGROW>
                else
                    if isfile(fullp) && endsWith(lower(fullp), ".m")
                        files(end+1,1) = fullp; %#ok<AGROW>
                    end
                end
            end
        end
        files = unique(files);
    end

    % -------- Sanitize file list --------
    files = string(files(:));
    if ~isempty(files)
        files = files(~ismissing(files) & files ~= "");
        if ~isempty(files), files = files(arrayfun(@isfile, files)); end
        if ~isempty(files), files = files(endsWith(lower(files), ".m")); end
    end

    if isempty(files)
        writeEmptyArtifacts(txtPath, sumPath);
        fprintf("[mlint] no MATLAB files to scan (after include/exclude filtering)\n");
        return
    end

    fprintf("Scanning %d MATLAB files...\n", numel(files));

    % -------- Run Code Analyzer --------
    allMsgs = table([], [], [], [], [], [], 'VariableNames', ...
        {'file','line','column','id','message','level'});

    for f = files.'
        filePath = f;                      % string
        fprintf("Linting %s\n", filePath);
        try
            issues = checkcode(filePath, "-id", "-fullpath");
        catch ME
            warning(ME.identifier, "checkcode error on %s: %s", filePath, ME.message);
            issues = [];
        end
        if ~isempty(issues)
            T = struct2table(normalizeMsgs(filePath, issues), 'AsArray', true);
            allMsgs = [allMsgs; T]; %#ok<AGROW>
        end
    end

    % -------- Write artifacts --------
    writeTextReport(txtPath, allMsgs, files);
    writeSummary(sumPath, allMsgs, files, repoRoot);
    writeSarif(sarifPath, allMsgs, repoRoot);  % safe even if empty

    % -------- Failure policy --------
    failOn = lower(string(getenvDefault("MLINT_FAIL_ON","any")));
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
                exitCode = 1;
        end
    end

    fprintf("[mlint] scanned %d files, found %d issues (failOn=%s)\n", ...
        numel(files), height(allMsgs), failOn);

    if exitCode ~= 0
        error("Lint issues found (MLINT_FAIL_ON=%s). See artifacts (lint/*).", failOn);
    end
end

% ================= helpers =================

function L = getenvDefault(name, defaultVal)
    val = getenv(name);
    if isempty(val), L = defaultVal; else, L = val; end
end

function xs = getenvList(name)
    % Robust split of comma/semicolon/pipe/newline into a string column
    val = strtrim(string(getenv(name)));
    if val == "" || strcmpi(val,"''") || strcmpi(val,'""')
        xs = string.empty(0,1); return
    end
    xs = split(val, {',',';','|',newline});
    xs = strtrim(xs);
    xs(xs=="") = [];
end

function files = findMFiles(root, excludes)
    d = dir(fullfile(root, "**", "*.m"));
    files = unique(string(fullfile({d.folder}, {d.name}))');
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
    for g = globs(:).'
        if globMatch(rel, g), yes = true; return; end
    end
end

function tf = globMatch(rel, pat)
    rel = string(rel); pat = string(pat);
    % Convert simple glob to regex (forward slashes)
    pat = replace(pat, ".", "\.");
    pat = replace(pat, "**", "<<<GLOBSTAR>>>");
    pat = replace(pat, "*",  "[^/]*");
    pat = replace(pat, "<<<GLOBSTAR>>>", ".*");
    pat = replace(pat, "?",  ".");
    expr = "^" + pat + "$";
    tf = ~isempty(regexp(rel, expr, 'once'));
end

function r = relPath(root, p)
    root = string(root); p = string(p);
    if startsWith(p, root + filesep)
        r = extractAfter(p, strlength(root) + 1);
    else
        r = p;
    end
    r = replace(r, filesep, "/");
end

function S = normalizeMsgs(file, msgs)
    S = struct('file',[],'line',[],'column',[],'id',[],'message',[],'level',[]);
    S = S([]);  % empty
    for k = 1:numel(msgs)
        m = msgs(k);
        line = int32(getfield_default(m,'line',1));
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
    sarif.version = "2.1.0";
    sarif.runs = {struct()};
    run.tool.driver.name = "MATLAB Code Analyzer (checkcode)";
    run.tool.driver.rules = uniqueRules(T);
    run.results = table2results(T, repoRoot);
    sarif.runs{1} = run;
    txt = jsonencode(sarif);
    txt = replace(txt, filesep, '/');
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
        rel = relPath(repoRoot, T.file(i));
        res.ruleId = char(T.id(i));
        res.level  = char(T.level(i));
        res.message.text = char(T.message(i));
        res.locations = {struct( ...
            'physicalLocation', struct( ...
                'artifactLocation', struct('uri', char(rel)), ...
                'region', struct( ...
                    'startLine', double(T.line(i)), ...
                    'startColumn', double(T.column(i)))))};
        results{i} = res;
    end
end

function writeEmptyArtifacts(txtPath, sumPath)
    fid = fopen(txtPath, 'w'); c = onCleanup(@() fclose(fid)); 
    fprintf(fid, "No MATLAB files to lint.\n");
    fid2 = fopen(sumPath, 'w'); c2 = onCleanup(@() fclose(fid2)); 
    fprintf(fid2, "## MATLAB Lint Summary\n\n_No MATLAB files to lint._\n");
end
