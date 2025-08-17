function results = runAllTests(varargin)
%RUNALLTESTS Discover and run tests with tags, reports, coverage, optional parallel.
% Env:
%   TEST_TAGS          comma-separated list (default: unit,synthetic,regression,io-free)
%   ENABLE_PARPOOL     1 to enable parallel if toolbox licensed
% Outputs:
%   results            TestResult array

import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.XMLPlugin
import matlab.unittest.plugins.DiagnosticsOutputPlugin

repo = fileparts(mfilename('fullpath')); repo = fileparts(repo);
addpath(fullfile(repo,'tools')); %#ok<*MCAP>

% Hygiene first
tools.check_tests;

% Tag filter
tagsEnv = getenv('TEST_TAGS');
if isempty(tagsEnv)
    allow = ["unit","synthetic","regression","io-free"];
else
    allow = string(strtrim(strsplit(tagsEnv,',')));
end

% Build suite then filter by tags
suite = TestSuite.fromFolder(fullfile(repo,'tests'),'IncludingSubfolders',true);
keep = arrayfun(@(t) any(ismember(string(t.Tags), allow)), suite);
suite = suite(keep);

runner = TestRunner.withTextOutput('OutputDetail','Concise');
% JUnit XML
xmlFile = fullfile(repo,'tests','artifacts','junit.xml');
if ~isfolder(fileparts(xmlFile)), mkdir(fileparts(xmlFile)); end
runner.addPlugin(XMLPlugin.producingJUnitFormat(xmlFile));
% Diagnostics capture
runner.addPlugin(DiagnosticsOutputPlugin.producingOutput);

% Optional HTML report (if available)
if exist('matlab.unittest.plugins.TestReportPlugin','class')
    rpt = fullfile(repo,'tests','artifacts','report.html');
    runner.addPlugin(matlab.unittest.plugins.TestReportPlugin.producingHTML(rpt));
end

% Code coverage: include all top-level +namespaces except tests/examples
covFolders = {};
d = dir(repo);
for k = 1:numel(d)
    if d(k).isdir && startsWith(d(k).name, '+') && ~strcmp(d(k).name,'+tests') && ~strcmp(d(k).name,'+examples')
        covFolders{end+1} = fullfile(repo, d(k).name); %#ok<AGROW>
    end
end
if ~isempty(covFolders)
    try
        runner.addPlugin(matlab.unittest.plugins.CodeCoveragePlugin.forFolder(covFolders));
    catch ME
        fprintf(2,'[runAllTests] Coverage plugin not available: %s\n', ME.message);
    end
end

% Optional parallel
enablePar = strcmp(getenv('ENABLE_PARPOOL'),'1');
if enablePar && license('test','Distrib_Computing_Toolbox')
    try
        import matlab.unittest.parallel.ParallelRunner
        runner = ParallelRunner.withTextOutput;
        fprintf('[runAllTests] Using ParallelRunner.\n');
    catch
        fprintf('[runAllTests] Parallel unavailable; running serially.\n');
    end
end

results = runner.run(suite);
assertSuccess(results);
end
