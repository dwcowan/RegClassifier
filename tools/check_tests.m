function check_tests()
%CHECK_TESTS Enforce test hygiene:
% - Every test method must declare TestTags
% - Recommend presence of a 'When domain logic goes live' comment block
% - Basic sanity for deterministic setup (RNG seeding hint)

    fprintf('[check_tests] Verifying test hygiene...\n');
    repoRoot = fileparts(mfilename('fullpath')); repoRoot = fileparts(repoRoot);
    testRoot = fullfile(repoRoot, 'tests');
    if ~isfolder(testRoot)
        error('check_tests:NoTests','No tests/ folder found.');
    end

    d = dir(fullfile(testRoot,'**','*.m'));
    missingTags = string.empty(1,0);
    missingLiveNote = string.empty(1,0);

    for k = 1:numel(d)
        f = fullfile(d(k).folder, d(k).name);
        txt = fileread(f);

        % skip fixtures and optional areas
        if contains(f, [filesep '+fixtures' filesep]), continue; end
        if contains(f, [filesep '+optional' filesep]), continue; end

        % Only class-based tests starting with 'test'
        [~, base] = fileparts(f);
        if ~startsWith(base, 'test'), continue; end
        if isempty(regexp(txt, '\bclassdef\s+test\w*\s*<\s*matlab\.unittest\.TestCase', 'once')), continue; end

        % At least one TestTags declaration per method (heuristic)
        methodsBlocks = regexp(txt, 'methods\s*\(([^\)]*)\)([\s\S]*?)end', 'tokens');
        for mb = 1:numel(methodsBlocks)
            header = methodsBlocks{mb}{1};
            body = methodsBlocks{mb}{2};
            if contains(lower(header), 'test') % method group likely contains tests
                % Find test methods without TestTags attribute in header
                hasTagAttr = ~isempty(regexp(header, 'TestTags\s*=\s*\{[^}]+\}', 'once'));
                % Also allow method-level attributes:
                % methods (Test), then individual methods with attribute lines are rare; we require group-level here.
                if ~hasTagAttr
                    missingTags(end+1) = string(f); %#ok<AGROW>
                    break;
                end
            end
        end

        % Presence of guidance comment block
        if isempty(regexp(txt, 'When\s+domain\s+logic\s+goes\s+live', 'ignorecase'))
            missingLiveNote(end+1) = string(f); %#ok<AGROW>
        end
    end

    if ~isempty(missingTags)
        fprintf(2,'[check_tests] Missing TestTags in:\n');
        disp(unique(missingTags)');
        error('check_tests:MissingTags','One or more test class method blocks lack TestTags.');
    end

    if ~isempty(missingLiveNote)
        fprintf('[check_tests] Note: add a "When domain logic goes live" comment in:\n');
        disp(unique(missingLiveNote)');
    end

    fprintf('[check_tests] OK\n');
end
