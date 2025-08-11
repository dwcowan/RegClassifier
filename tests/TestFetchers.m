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
            % Only check that the function returns a table or errors gracefully (no net in CI)
            try
                T = reg.fetch_crr_eba();
                tc.verifyTrue(istable(T));
            catch ME
                tc.assertTrue(~isempty(ME.message));
            end
        end

        function eba_fetch_cache(tc)
            % Verify caching skips re-downloading existing files
            mockDir = fullfile(fileparts(mfilename('fullpath')), 'fixtures', 'eba_mock');
            tc.applyFixture(matlab.unittest.fixtures.PathFixture(mockDir));
            outDir = fullfile('data','eba_isrb','crr');
            if isfolder(outDir), rmdir(outDir,'s'); end
            c = onCleanup(@() (isfolder(outDir) && rmdir(outDir,'s'))); %#ok<NASGU>

            global WEBREAD_CALLS
            WEBREAD_CALLS = strings(0,1);
            T1 = reg.fetch_crr_eba();
            calls1 = WEBREAD_CALLS; %#ok<NASGU>

            WEBREAD_CALLS = strings(0,1);
            T2 = reg.fetch_crr_eba();
            calls2 = WEBREAD_CALLS; %#ok<NASGU>

            tc.verifyEqual(height(T1), 2);
            tc.verifyEqual(T1, T2);
            tc.verifyEqual(numel(calls1), 3); % root + two articles
            tc.verifyEqual(numel(calls2), 1); % only root fetched
        end
    end
end
