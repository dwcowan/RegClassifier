% RUN_SMOKE_TEST  Quick environment verification
fprintf("\n=== Smoke Test Start ===\n");

% 1) GPU check
try
    g = gpuDevice;
    fprintf("GPU: %s, %g GB VRAM\n", g.Name, g.TotalMemory/1e9);
catch ME
    warning("GPU check failed: %s", ME.message);
end

% 2) Critical tests
crit_tests = {
    "tests/TestPDFIngest.m", ...
    "tests/TestProjectionAutoloadPipeline.m", ...
    "tests/TestMetricsExpectedJSON.m", ...
    "tests/TestReportArtifact.m"
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
