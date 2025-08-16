classdef test_APIDiscoverability < matlab.unittest.TestCase
    properties (Constant)
        TestTags = {'meta','io-free'};
    end
    methods (Test)
        function symbols_in_manifest_exist(testCase)
            repoRoot = fileparts(mfilename('fullpath')); repoRoot = fileparts(repoRoot);
            manifest = fullfile(repoRoot, 'api_manifest.json');
            if ~isfile(manifest)
                testCase.assertIncomplete('Manifest missing; run tools.snapshot_api');
                return
            end
            data = jsondecode(fileread(manifest));
            for i=1:numel(data)
                sym = string(data(i).symbol);
                kind = string(data(i).kind);
                if kind == "class"
                    testCase.verifyTrue(exist(sym,'class')==8, sprintf('Missing class: %s', sym));
                else
                    % For methods/functions, we just check non-empty symbol strings here
                    testCase.verifyNotEqual(sym,"", "Empty symbol in manifest");
                end
            end
        end
    end
end
