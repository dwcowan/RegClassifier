function check_tests()
%CHECK_TESTS Enforce test hygiene: fixtures, deterministic RNG, and TestTags.
% Heuristics ensure:
%  - Use of matlab.unittest.fixtures or applyFixture
%  - Deterministic RNG setup (rng(0,'twister'))
%  - Presence of TestTags in test classes/methods

    fprintf('[check_tests] Scanning tests...\n');
    repoRoot = fileparts(mfilename('fullpath'));
    repoRoot = fileparts(repoRoot);
    testRoot = fullfile(repoRoot,'tests');
    if ~isfolder(testRoot)
        fprintf('[check_tests] No tests/ directory found. OK (nothing to check).\n');
        return
    end

    d = dir(fullfile(testRoot,'**','*.m'));
    % Skip examples directory
    d = d(~contains(fullfile({d.folder},{d.name}),[filesep 'examples' filesep]));
    if isempty(d)
        fprintf(2, '[check_tests] No test files found under tests/.\n');
        error('check_tests:NoTests', 'No tests present.');
    end

    missingFixtures = {};
    missingRng = {};
    missingTags = {};

    for k = 1:numel(d)
        f = fullfile(d[k].folder, d[k].name); %#ok<PFBNS>
        txt = fileread(f);

        hasFixture = contains(txt, "matlab.unittest.fixtures") || contains(txt, "applyFixture");
        if ~hasFixture
            missingFixtures{end+1} = f; %#ok<AGROW>
        end

        hasRng = ~isempty(regexp(txt, "rng\(0,\s*'twister'\)", 'once'));
        if ~hasRng
            missingRng{end+1} = f; %#ok<AGROW>
        end

        hasTags = ~isempty(regexp(txt, 'TestTags\s*=\s*\{[^}]+\}', 'once'));
        if ~hasTags
            missingTags{end+1} = f; %#ok<AGROW>
        end
    end

    problems = false;
    if ~isempty(missingFixtures)
        problems = true;
        fprintf(2, '[check_tests] Missing fixtures usage in:\n');
        for i=1:numel(missingFixtures), fprintf(2,'  - %s\n', missingFixtures{i}); end
    end
    if ~isempty(missingRng)
        problems = true;
        fprintf(2, '[check_tests] Missing rng(0,''twister'') in:\n');
        for i=1:numel(missingRng), fprintf(2,'  - %s\n', missingRng[i}); end %#ok<PFBNS>
    end
    if ~isempty(missingTags)
        problems = true;
        fprintf(2, '[check_tests] Missing TestTags in:\n');
        for i=1:numel(missingTags), fprintf(2,'  - %s\n', missingTags{i}); end
    end

    if problems
        error('check_tests:Failed', 'Test hygiene checks failed.');
    else
        fprintf('[check_tests] OK\n');
    end
end
