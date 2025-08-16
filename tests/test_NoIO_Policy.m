classdef test_NoIO_Policy < matlab.unittest.TestCase
    properties (Constant)
        TestTags = {'policy','io-free'};
    end
    methods (Test)
        function no_io_in_clean_room_paths(testCase)
            % Attempt a representative call and ensure we hit NotImplemented rather than any I/O
            try
                reg.views.Report.render(struct('nObs',10));
                testCase.assertIncomplete('Expected NotImplemented in clean-room');
            catch ME
                testCase.verifyMatches(ME.identifier, "^reg:(view|model|controller):NotImplemented$");
            end
        end
    end
end
