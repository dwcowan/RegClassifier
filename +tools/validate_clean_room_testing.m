function validate_clean_room_testing
%VALIDATE_CLEAN_ROOM_TESTING Static validator for clean-room test suite.
%   Generates machine-readable and human-readable reports and errors on
%   any failure.

% Determine repo roots
thisFile = mfilename('fullpath');
packageDir = fileparts(thisFile); % path to +tools
repoRoot = fileparts(packageDir);
regRoot = fullfile(repoRoot,'+reg');
testsRoot = fullfile(repoRoot,'+tests');

failures = struct('code',{},'file',{},'detail',{});
warnings = struct('code',{},'file',{},'detail',{});
status = struct('A',true,'B',true,'C',true,'D',true,'E',true,'F',true,'G',true,'H',true);

    function rel = relpath(p)
        rel = strrep(p, [repoRoot filesep], '');
    end
    function addFail(code,p,detail,section)
        failures(end+1) = struct('code',code,'file',relpath(p),'detail',detail); %#ok<AGROW>
        status.(section) = false;
    end
    function addWarn(code,p,detail,section)
        warnings(end+1) = struct('code',code,'file',relpath(p),'detail',detail); %#ok<AGROW>
        status.(section) = status.(section) & true;
    end

%% A. Repo policy presence
if ~exist(fullfile(repoRoot,'AGENT.md'),'file')
    addFail('A1', repoRoot, 'AGENT.md missing', 'A');
end

%% B. Tree & naming
regFiles = dir(fullfile(regRoot,'**','*.m'));
for k = 1:numel(regFiles)
    src = regFiles(k);
    [~,className] = fileparts(src.name);
    relDir = strrep(src.folder, regRoot, '');
    testFile = fullfile(testsRoot, relDir, ['test' className '.m']);
    if ~exist(testFile,'file')
        addFail('B1', testFile, 'Missing mirrored test class', 'B');
        continue;
    end
    txt = fileread(testFile);
    if ~contains(txt, ['classdef test' className])
        addFail('B1', testFile, 'Test class name mismatch', 'B');
    end
end
% B2 shims wrappers
if exist(fullfile(testsRoot,'+shims'),'dir')
    addFail('B2', fullfile(testsRoot,'+shims'), 'Shims directory present', 'B');
end
shimFiles = dir(fullfile(testsRoot,'**','*'));
for k=1:numel(shimFiles)
    f = shimFiles(k);
    if f.isdir, continue; end
    lname = lower(f.name);
    if contains(lname,'safe_call') || contains(lname,'assume_notimplemented') || contains(lname,'shim')
        addFail('B2', fullfile(f.folder,f.name), 'Shim or safe_call detected', 'B');
    end
end

%% C. Layer-specific NotImplemented assertions
layerMap = containers.Map({'controller','model','view','io','db'}, ...
    {'reg:controller:NotImplemented','reg:model:NotImplemented', ...
     'reg:view:NotImplemented','reg:io:NotImplemented','reg:db:NotImplemented'});
for k = 1:numel(regFiles)
    src = regFiles(k);
    relDir = strrep(src.folder, regRoot, '');
    tokens = regexp(relDir, '\+(\w+)', 'tokens');
    if isempty(tokens), continue; end
    pkg = tokens{1}{1};
    if ~isKey(layerMap, pkg), continue; end
    [~,className] = fileparts(src.name);
    testFile = fullfile(testsRoot, relDir, ['test' className '.m']);
    if ~exist(testFile,'file'), continue; end
    txt = fileread(testFile);
    expected = layerMap(pkg);
    expr = 'testCase\.verifyError\(@\(\)';
    if ~contains(txt, expected) || ~contains(txt, 'testCase.verifyError')
        addFail('C2', testFile, ['Missing verifyError for ' expected], 'C');
    end
end

%% D. Test method tagging & structure
allTestFiles = dir(fullfile(testsRoot,'**','*.m'));
for k=1:numel(allTestFiles)
    f = allTestFiles(k);
    fp = fullfile(f.folder,f.name);
    if contains(fp, [filesep '+fixtures']) || contains(fp, [filesep '+optional'])
        continue;
    end
    if ismember(f.name, {'runAllTests.m','coverage_thresholds_check.m','update_baselines.m'})
        continue;
    end
    txt = fileread(fp);
    if ~contains(txt,'classdef')
        addFail('D1', fp, 'Procedural test script found', 'D');
    end
    mblocks = regexp(txt, 'methods\s*\(([^)]*)\)', 'tokens');
    for b = 1:numel(mblocks)
        block = mblocks{b}{1};
        if contains(block,'Test') && ~contains(block,'TestTags')
            addFail('D2', fp, 'Test method without TestTags', 'D');
        end
    end
    tags = regexp(txt, 'TestTags\s*=\s*\{([^}]+)\}', 'tokens');
    found = unique(strtrim(strrep([tags{:}], '''', '')));
    requiredTags = {'Unit','Integration','Smoke','Regression'};
    for rt = 1:numel(requiredTags)
        if ~any(contains(found, requiredTags{rt}))
            addFail('D3', fp, ['Missing tag ' requiredTags{rt}], 'D');
        end
    end
end

%% E. Determinism & isolation
testClasses = dir(fullfile(testsRoot,'**','test*.m'));
for k=1:numel(testClasses)
    fp = fullfile(testClasses(k).folder, testClasses(k).name);
    txt = fileread(fp);
    if ~contains(txt, 'rng(0,''twister'')')
        addFail('E1', fp, 'Missing RNG seeding', 'E');
    end
    if ~(contains(txt,'TemporaryFolderFixture') && contains(txt,'WorkingFolderFixture'))
        addFail('E2', fp, 'Missing folder fixtures', 'E');
    end
end
% E3 disk writes
writePatterns = { 'writetable', 'writematrix', 'fopen', 'save', 'diary'};
for k=1:numel(allTestFiles)
    f = allTestFiles(k);
    fp = fullfile(f.folder,f.name);
    if contains(fp,'update_baselines.m'), continue; end
    txt = fileread(fp);
    for p = 1:numel(writePatterns)
        pat = writePatterns{p};
        if contains(txt, pat)
            if strcmp(pat,'fopen') && ~(contains(txt,''''w''') || contains(txt,''''a'''))
                continue;
            elseif strcmp(pat,'save') && ~contains(txt,''''-append''')
                continue;
            elseif strcmp(pat,'diary') && ~contains(lower(txt),'diary on')
                continue;
            end
            addFail('E3', fp, ['Disk write via ' pat], 'E');
        end
    end
end

%% F. Regression fixtures
genDir = fullfile(testsRoot,'+fixtures','+gen');
if ~exist(genDir,'dir')
    addFail('F1', genDir, 'Generator dir missing', 'F');
else
    genFiles = dir(fullfile(genDir,'*.m'));
    if isempty(genFiles)
        addFail('F1', genDir, 'No generator files', 'F');
    else
        hasRng = false;
        for k=1:numel(genFiles)
            txt = fileread(fullfile(genDir,genFiles(k).name));
            if contains(txt, 'rng(0,''twister'')')
                hasRng = true; break;
            end
        end
        if ~hasRng
            addFail('F1', genDir, 'Generators lack rng seed', 'F');
        end
    end
end
baselineDir = fullfile(testsRoot,'+fixtures','baselines');
if ~exist(baselineDir,'dir')
    addFail('F2', baselineDir, 'Baseline dir missing', 'F');
else
    if ~exist(fullfile(baselineDir,'manifest.json'),'file')
        addFail('F2', baselineDir, 'manifest.json missing', 'F');
    end
    if ~exist(fullfile(baselineDir,'SCHEMA.md'),'file')
        addFail('F2', baselineDir, 'SCHEMA.md missing', 'F');
    end
    baselineFiles = dir(fullfile(baselineDir,'**','*.m'));
    for k=1:numel(baselineFiles)
        txt = fileread(fullfile(baselineFiles(k).folder,baselineFiles(k).name));
        for p=1:numel(writePatterns)
            pat = writePatterns{p};
            if contains(txt, pat)
                addFail('F3', fullfile(baselineFiles(k).folder,baselineFiles(k).name), 'Write in baselines', 'F');
            end
        end
    end
end

%% G. Runner & coverage configuration
runAll = fullfile(testsRoot,'runAllTests.m');
if ~exist(runAll,'file')
    addFail('G1', runAll, 'runAllTests.m missing', 'G');
else
    txt = fileread(runAll);
    if ~(contains(txt,"CodeCoveragePlugin.forFolder('+reg'") && ...
            contains(txt, "'ExcludeFolder',{'+tests'"))
        addFail('G2', runAll, 'Coverage config incomplete', 'G');
    end
    if ~(contains(txt, "exist('matlab.unittest.plugins.TestReportPlugin','class')") && ...
            contains(txt, "license(''test'',''Distrib_Computing_Toolbox'')") && ...
            contains(txt, "exist(''matlab.perftest.TestCase'',''class'')"))
        addFail('G3', runAll, 'Toolbox guards missing', 'G');
    end
end

%% H. Contracts (warnings)
addpath(repoRoot);
regClasses = dir(fullfile(regRoot,'**','*.m'));
for k=1:numel(regClasses)
    fp = fullfile(regClasses(k).folder,regClasses(k).name);
    txt = fileread(fp);
    if ~contains(txt,'arguments')
        if ~contains(txt,'% input:') && ~contains(txt,'% Inputs:')
            addWarn('H1', fp, 'Missing arguments block and input docs', 'H');
        end
    end
end

%% Finalize report
report = struct();
report.passed = isempty(failures);
report.failures = failures;
report.warnings = warnings;
report.stats = struct('nFailures',numel(failures),'nWarnings',numel(warnings));

artifacts = fullfile(testsRoot,'artifacts');
if ~exist(artifacts,'dir'), mkdir(artifacts); end
jsonPath = fullfile(artifacts,'validation_report.json');
fid = fopen(jsonPath,'w'); fwrite(fid,jsonencode(report),'char'); fclose(fid);

mdPath = fullfile(artifacts,'validation_report.md');
fid = fopen(mdPath,'w');
fprintf(fid,'# Validation Report\n\n');
checks = fieldnames(status);
for k=1:numel(checks)
    mark = '\u2714';
    if ~status.(checks{k})
        mark = '\u2718';
    end
    fprintf(fid,'- %s Check %s\n', mark, checks{k});
end
if ~isempty(failures)
    fprintf(fid,'\n## Failures\n');
    fprintf(fid,'| File | Rule | Detail |\n|---|---|---|\n');
    for k=1:numel(failures)
        f = failures(k);
        fprintf(fid,'| %s | %s | %s |\n',f.file,f.code,f.detail);
    end
end
if ~isempty(warnings)
    fprintf(fid,'\n## Warnings\n');
    fprintf(fid,'| File | Rule | Detail |\n|---|---|---|\n');
    for k=1:numel(warnings)
        w = warnings(k);
        fprintf(fid,'| %s | %s | %s |\n',w.file,w.code,w.detail);
    end
end
fclose(fid);

if report.passed
    disp('VALIDATION PASSED');
else
    disp('VALIDATION FAILED');
    error('tools:validate:Failed','Clean-room validation failed');
end
end
