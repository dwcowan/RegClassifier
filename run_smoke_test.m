% RUN_SMOKE_TEST  Quick environment verification
fprintf("\n=== Smoke Test Start ===\n");

% 1) GPU check - graceful handling for CI environments
if exist('gpuDevice', 'file') == 2  % Check if function exists
    try
        g = gpuDevice;
        fprintf("GPU: %s, %g GB VRAM\n", g.Name, g.TotalMemory/1e9);
    catch ME
        fprintf("GPU check: No GPU available (%s)\n", ME.message);
    end
else
    fprintf("GPU check: gpuDevice function not available (Parallel Computing Toolbox not installed)\n");
end

% 2) Critical tests - convert to cell array of char vectors for MATLAB compatibility
crit_tests = {
    char("tests/TestPDFIngest.m"), ...
    char("tests/TestProjectionAutoloadPipeline.m"), ...
    char("tests/TestMetricsExpectedJSON.m"), ...
    char("tests/TestReportArtifact.m")
};
results = runtests(crit_tests);
disp(results);

% 3) Pipeline on simulated data
try
    run reg_pipeline
    run reg_eval_and_report
    fprintf("Pipeline & report completed.\n");
catch ME
    warning("Pipeline run failed: %s", ME.message);
end

fprintf("=== Smoke Test End ===\n");
