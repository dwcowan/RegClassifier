function status = run_ci_tests()
    %RUN_CI_TESTS Execute test suite for CI/CD pipeline.
    %   Returns 0 on success, 1 on failure.
    %
    %   This script runs the full test suite with XML and code coverage output
    %   for integration with CI/CD systems (GitHub Actions, Jenkins, etc.).
    %
    %   Outputs:
    %       test_results.xml - JUnit format test results
    %       coverage.xml     - Cobertura format code coverage
    %
    %   Example:
    %       status = run_ci_tests();
    %       if status == 0
    %           disp('All tests passed!');
    %       else
    %           disp('Some tests failed.');
    %       end

    import matlab.unittest.TestRunner;
    import matlab.unittest.TestSuite;
    import matlab.unittest.plugins.XMLPlugin;
    import matlab.unittest.plugins.CodeCoveragePlugin;
    import matlab.unittest.plugins.codecoverage.CoberturaFormat;

    fprintf('========================================\n');
    fprintf('RegClassifier CI Test Suite\n');
    fprintf('========================================\n\n');

    % Create test suite from tests folder
    fprintf('Discovering tests in tests/ folder...\n');
    suite = TestSuite.fromFolder('tests', 'IncludingSubfolders', true);
    fprintf('Found %d test methods\n\n', numel(suite));

    % Create runner with text output
    runner = TestRunner.withTextOutput;

    % Add XML plugin for CI integration (JUnit format)
    fprintf('Configuring XML output (test_results.xml)...\n');
    runner.addPlugin(XMLPlugin.producingJUnitFormat('test_results.xml'));

    % Add code coverage plugin (Cobertura format for CI dashboards)
    fprintf('Configuring code coverage (coverage.xml)...\n');
    runner.addPlugin(CodeCoveragePlugin.forFolder('+reg', ...
        'IncludingSubfolders', true, ...
        'Producing', CoberturaFormat('coverage.xml')));

    fprintf('\n========================================\n');
    fprintf('Running tests...\n');
    fprintf('========================================\n\n');

    % Run tests
    tic;
    results = runner.run(suite);
    elapsed = toc;

    % Display summary
    fprintf('\n========================================\n');
    fprintf('Test Summary\n');
    fprintf('========================================\n');
    fprintf('Tests run:    %d\n', numel(results));
    fprintf('Passed:       %d\n', sum([results.Passed]));
    fprintf('Failed:       %d\n', sum([results.Failed]));
    fprintf('Incomplete:   %d\n', sum([results.Incomplete]));
    fprintf('Duration:     %.2f seconds\n', elapsed);
    fprintf('========================================\n');

    % Display failed tests
    numFailed = sum([results.Failed]);
    if numFailed > 0
        fprintf('\nFailed Tests:\n');
        for i = 1:numel(results)
            if results(i).Failed
                fprintf('  - %s\n', results(i).Name);
            end
        end
    end

    % Display incomplete tests
    numIncomplete = sum([results.Incomplete]);
    if numIncomplete > 0
        fprintf('\nIncomplete Tests:\n');
        for i = 1:numel(results)
            if results(i).Incomplete
                fprintf('  - %s (%s)\n', results(i).Name, results(i).Details.DiagnosticRecord.Report);
            end
        end
    end

    fprintf('\nOutputs generated:\n');
    fprintf('  - test_results.xml (JUnit format)\n');
    fprintf('  - coverage.xml (Cobertura format)\n\n');

    % Return exit code
    if numFailed > 0 || numIncomplete > 0
        status = 1;
        fprintf('❌ CI FAILED: %d failed, %d incomplete\n', numFailed, numIncomplete);
    else
        status = 0;
        fprintf('✓ CI PASSED: All tests successful!\n');
    end

    fprintf('========================================\n');
end
