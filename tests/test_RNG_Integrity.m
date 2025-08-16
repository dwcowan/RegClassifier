classdef test_RNG_Integrity < matlab.unittest.TestCase
    properties (Constant)
        TestTags = {'unit','io-free'};
    end
    methods (Test)
        function no_rng_leak(testCase)
            s = rng; cleanup = onCleanup(@() rng(s));
            rng(1,'twister'); % change state intentionally
            % Call into code (clean-room paths will early-exit)
            try
                obj = reg.Example();
            catch, end
            % State should be restorable; verify no surprise changes here
            testCase.verifyNotEmpty(s); % existence check
            testCase.assertIncomplete("Clean-room: full RNG leak checks after implementation.");
        end
    end
end
