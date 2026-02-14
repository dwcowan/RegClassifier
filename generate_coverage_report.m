function generate_coverage_report()
    %GENERATE_COVERAGE_REPORT Generate HTML code coverage report.
    %   Runs the test suite and produces an HTML coverage report
    %   showing line-by-line coverage for all +reg package functions.
    %
    %   Output:
    %       coverage_report/index.html - HTML coverage report
    %
    %   Example:
    %       generate_coverage_report();
    %       web('coverage_report/index.html');

    import matlab.unittest.TestRunner;
    import matlab.unittest.TestSuite;
    import matlab.unittest.plugins.CodeCoveragePlugin;
    import matlab.unittest.plugins.codecoverage.CoverageReport;

    fprintf('========================================\n');
    fprintf('RegClassifier Code Coverage Report\n');
    fprintf('========================================\n\n');

    % Create test suite
    fprintf('Discovering tests...\n');
    suite = TestSuite.fromFolder('tests', 'IncludingSubfolders', true);
    fprintf('Found %d test methods\n\n', numel(suite));

    % Create runner with text output
    runner = TestRunner.withTextOutput;

    % Add coverage plugin with HTML report
    reportFolder = 'coverage_report';
    fprintf('Configuring coverage report: %s/\n', reportFolder);

    plugin = CodeCoveragePlugin.forFolder('+reg', ...
        'IncludingSubfolders', true, ...
        'Producing', CoverageReport(reportFolder));
    runner.addPlugin(plugin);

    fprintf('\n========================================\n');
    fprintf('Running tests with coverage analysis...\n');
    fprintf('========================================\n\n');

    % Run tests
    tic;
    results = runner.run(suite);
    elapsed = toc;

    % Display summary
    fprintf('\n========================================\n');
    fprintf('Results\n');
    fprintf('========================================\n');
    fprintf('Tests run:    %d\n', numel(results));
    fprintf('Passed:       %d\n', sum([results.Passed]));
    fprintf('Failed:       %d\n', sum([results.Failed]));
    fprintf('Incomplete:   %d\n', sum([results.Incomplete]));
    fprintf('Duration:     %.2f seconds\n', elapsed);
    fprintf('========================================\n\n');

    % Open report in browser
    reportPath = fullfile(reportFolder, 'index.html');
    if isfile(reportPath)
        fprintf('Coverage report generated successfully!\n');
        fprintf('Report location: %s\n', reportPath);
        fprintf('\nOpening coverage report in browser...\n');
        web(reportPath, '-browser');
    else
        fprintf('Warning: Coverage report file not found at %s\n', reportPath);
    end

    fprintf('========================================\n');
end
