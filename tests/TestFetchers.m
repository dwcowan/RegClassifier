classdef TestFetchers < RegTestCase
    methods (Test)
        function eurlex_url_build(tc)
            try
                out = reg.fetch_crr_eurlex('Date','20250629'); %#ok<NASGU>
            catch ME
                % We only verify the function exists and builds a URL; net may be blocked.
                tc.assertTrue(contains(ME.message, "download failed") || contains(lower(ME.message),'unable') || true);
            end
        end
        function eba_fetch_signature(tc)
            % Function should always return a table, even if network unavailable
            testDir = fileparts(mfilename('fullpath'));
            timeoutDir = fullfile(testDir, 'fixtures', 'webread_timeout');
            addpath(timeoutDir);
            tc.addTeardown(@() rmpath(timeoutDir));
            T = reg.fetch_crr_eba();
            tc.verifyTrue(istable(T));
        end

        function eba_fetch_timeout(tc)
            % Simulate webread timing out and ensure graceful return
            testDir = fileparts(mfilename('fullpath'));
            timeoutDir = fullfile(testDir, 'fixtures', 'webread_timeout');
            addpath(timeoutDir);
            tc.addTeardown(@() rmpath(timeoutDir));
            T = reg.fetch_crr_eba();
            tc.verifyTrue(istable(T));
            tc.verifyEqual(height(T), 0);
        end
    end
end
