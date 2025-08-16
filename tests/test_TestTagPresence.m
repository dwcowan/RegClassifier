classdef test_TestTagPresence < matlab.unittest.TestCase
    properties (Constant)
        TestTags = {'meta','io-free'};
    end
    methods (Test)
        function every_test_has_tags(testCase)
            % Heuristic: scan tests for TestTags property
            repoRoot = fileparts(mfilename('fullpath')); repoRoot = fileparts(repoRoot);
            testRoot = fullfile(repoRoot,'tests');
            d = dir(fullfile(testRoot,'**','*.m'));
            missing = {};
            for k=1:numel(d)
                f = fullfile(d(k).folder, d(k).name);
                txt = fileread(f);
                if isempty(regexp(txt, 'TestTags\s*=\s*\{[^}]+\}', 'once'))
                    missing{end+1} = f; %#ok<AGROW>
                end
            end
            if ~isempty(missing)
                testCase.assertIncomplete(sprintf('Add TestTags to: \n  - %s', strjoin(missing, '\n  - ')));
            end
        end
    end
end
