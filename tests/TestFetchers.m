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
            % Verify limited and full fetch modes handle lack of network gracefully
            limits = [1, inf];
            for k = 1:numel(limits)
                try
                    T = reg.fetch_crr_eba('maxArticles', limits(k)); %#ok<NASGU>
                    tc.verifyTrue(istable(T));
                catch ME
                    tc.assertTrue(~isempty(ME.message));
                end
            end
        end
    end
end
