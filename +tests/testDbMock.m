classdef testDbMock < matlab.unittest.TestCase
    % Minimal database mock example
    % When domain logic goes live:
    %   - Replace mock with sandbox database interactions.

    methods (Test, TestTags={'Database'})
        function createAndUseMock(testCase)
            import matlab.mock.TestCase as MockTestCase
            [mc, ~] = MockTestCase.forInteractiveUse;
            proxy = createMock(mc, 'AddedMethods', {'query'});
            testCase.verifyTrue(isprop(proxy, 'query'));
        end
    end
end
