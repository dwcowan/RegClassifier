function results = runAllTests
%RUNALLTESTS Discover and run all tests with plugins and coverage.
%   Respects TEST_TAGS and ENABLE_PARPOOL environment variables.

root = fileparts(mfilename('fullpath'));
try
    tests.check_tags();
catch ME
    warning(ME.message);
end

import matlab.unittest.TestSuite
suite = TestSuite.fromFolder(root, 'IncludeSubfolders', true);

% Optional perftest
if exist('matlab.perftest.TestCase','class') && exist(fullfile(root,'+optional','perf'),'dir')
    perfSuite = TestSuite.fromFolder(fullfile(root,'+optional','perf'), 'IncludeSubfolders', true);
    suite = [suite perfSuite];
end

% Tag filtering
tags = getenv('TEST_TAGS');
if ~isempty(tags)
    tagList = strsplit(tags, ',');
    suite = suite.selectIf(@(t) any(ismember(tagList, t.Tags)));
end

import matlab.unittest.TestRunner
import matlab.unittest.plugins.XMLPlugin
import matlab.unittest.plugins.DiagnosticsRecordingPlugin
import matlab.unittest.plugins.CodeCoveragePlugin

runner = TestRunner.withTextOutput('Verbosity',3);
artifacts = fullfile(root, 'artifacts');
if ~exist(artifacts,'dir'), mkdir(artifacts); end
runner.addPlugin(XMLPlugin.producingJUnitFormat(fullfile(artifacts,'junit.xml')));
runner.addPlugin(DiagnosticsRecordingPlugin(1));
if exist('matlab.unittest.plugins.TestReportPlugin','class')
    runner.addPlugin(matlab.unittest.plugins.TestReportPlugin.producingHTML(artifacts));
end
covFolder = fullfile(artifacts,'coverage');
if ~exist(covFolder,'dir'), mkdir(covFolder); end
runner.addPlugin(CodeCoveragePlugin.forFolder('+reg','IncludingSubfolders',true,'ExcludeFolder',{'+tests'}));

if license('test','Distrib_Computing_Toolbox') && getenv('ENABLE_PARPOOL') == "1"
    runner.useParallel true;
else
    runner.useParallel false;
end

results = runner.run(suite);
end
