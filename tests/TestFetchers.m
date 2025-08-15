classdef TestFetchers < matlab.unittest.TestCase
    %TESTFETCHERS Ensure CRR fetcher model stubs raise NotImplemented.
    methods (Test)
        function fetchEbaNotImplemented(tc)
            model = reg.model.CrrFetchModel();
            tc.verifyError(@() model.fetchEba(), 'reg:model:NotImplemented');
        end
        function fetchEbaParsedNotImplemented(tc)
            model = reg.model.CrrFetchModel();
            tc.verifyError(@() model.fetchEbaParsed(), 'reg:model:NotImplemented');
        end
        function fetchEurlexNotImplemented(tc)
            model = reg.model.CrrFetchModel();
            tc.verifyError(@() model.fetchEurlex(), 'reg:model:NotImplemented');
        end
    end
end
