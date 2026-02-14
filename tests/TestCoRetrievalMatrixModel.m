classdef TestCoRetrievalMatrixModel < fixtures.RegTestCase
    methods (Test)
        function matchesLegacy(tc)
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr(); %#ok<ASGLU>
            model = reg.model.CoRetrievalMatrixModel();
            [Y, orderLoad] = model.load(chunksT, Ytrue);
            tc.verifyEqual(Y, logical(Ytrue));
            tc.verifyEqual(orderLoad, 1:size(Ytrue,2));

            rng(0);
            E = randn(height(chunksT), 4);
            E = E ./ vecnorm(E,2,2);
            K = 3;
            [Mmodel, orderModel] = model.process(E, K);
            [Mlegacy, orderLegacy] = reg.label_coretrieval_matrix(E, Ytrue, K);
            tc.verifyEqual(Mmodel, Mlegacy, 'AbsTol', 1e-12);
            tc.verifyEqual(orderModel, orderLegacy);
        end

        function errorWithoutLoad(tc)
            model = reg.model.CoRetrievalMatrixModel();
            tc.verifyError(@() model.process(zeros(1),1), ...
                'reg:model:CoRetrievalMatrixModel:NoLabels');
        end
    end
end
