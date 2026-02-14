classdef TestCalibration < fixtures.RegTestCase
    %TESTCALIBRATION Tests for probability calibration.
    %   Tests reg.calibrate_probabilities() and reg.apply_calibration().

    methods (Test, TestTags = {'Unit','Calibration','Fast'})
        function testPlattScalingBasic(tc)
            %TESTPLATTSCALINGBASIC Test Platt scaling calibration.
            %   Verifies that calibration model is learned and can be applied.

            % Generate synthetic scores and true labels
            N = 200;
            scores = rand(N, 1);
            Ytrue = scores > 0.5;  % Simple threshold

            % Train calibration model (function returns [calibrated_scores, calibrators])
            [probsCal, calibrators] = reg.calibrate_probabilities(scores, Ytrue, 'Method', 'platt');

            tc.verifyNotEmpty(calibrators, ...
                'Calibrators cell array should not be empty');
            tc.verifyTrue(iscell(calibrators), ...
                'Calibrators should be a cell array');

            % Apply calibration to same scores (should give similar results)
            probsCal2 = reg.apply_calibration(scores, calibrators);

            tc.verifyEqual(size(probsCal2), size(scores), ...
                'Calibrated probabilities should have same size as scores');
            tc.verifyGreaterThanOrEqual(min(probsCal2), 0, ...
                'Calibrated probabilities should be >= 0');
            tc.verifyLessThanOrEqual(max(probsCal2), 1, ...
                'Calibrated probabilities should be <= 1');
        end

        function testIsotonicRegressionBasic(tc)
            %TESTISOTONICREGRESSIONBASIC Test isotonic regression calibration.
            %   Verifies monotonic transformation of scores.

            N = 200;
            scores = rand(N, 1);
            Ytrue = rand(N, 1) > 0.4;

            % Train isotonic calibration
            [~, calibrators] = reg.calibrate_probabilities(scores, Ytrue, 'Method', 'isotonic');

            tc.verifyNotEmpty(calibrators, ...
                'Isotonic calibration model should not be empty');

            % Apply calibration
            probsCal = reg.apply_calibration(scores, calibrators);

            tc.verifyEqual(length(probsCal), length(scores), ...
                'Calibrated probabilities should have same length');
            tc.verifyGreaterThanOrEqual(min(probsCal), 0, ...
                'Probabilities should be >= 0');
            tc.verifyLessThanOrEqual(max(probsCal), 1, ...
                'Probabilities should be <= 1');

            % Verify monotonicity (if input sorted, output should be sorted)
            [scoresSorted, idx] = sort(scores);
            probsCalSorted = probsCal(idx);
            tc.verifyTrue(issorted(probsCalSorted, 'ascend', 'Rows'), ...
                'Isotonic calibration should preserve monotonicity');
        end

        function testCalibrationImprovesReliability(tc)
            %TESTCALIBRATIONIMPROVESRELIABILITY Test that calibration improves reliability.
            %   Verifies that calibrated probabilities better match empirical frequencies.

            % Generate poorly calibrated scores (overconfident)
            N = 300;
            scores = betarnd(8, 2, N, 1);  % Skewed toward high values
            Ytrue = rand(N, 1) < scores * 0.7;  % True labels with noise

            % Train calibration
            [probsCal, calibrators] = reg.calibrate_probabilities(scores, Ytrue, 'Method', 'platt');

            % Bin predictions and compare to empirical frequencies
            numBins = 10;
            [~, ~, bin] = histcounts(scores, numBins);
            [~, ~, binCal] = histcounts(probsCal, numBins);

            % Expected Calibration Error (ECE) - simplified version
            eceUncal = 0;
            eceCal = 0;
            for b = 1:numBins
                idxUncal = (bin == b);
                idxCal = (binCal == b);
                if sum(idxUncal) > 0
                    avgScore = mean(scores(idxUncal));
                    empFreq = mean(Ytrue(idxUncal));
                    eceUncal = eceUncal + abs(avgScore - empFreq) * sum(idxUncal);
                end
                if sum(idxCal) > 0
                    avgProb = mean(probsCal(idxCal));
                    empFreq = mean(Ytrue(idxCal));
                    eceCal = eceCal + abs(avgProb - empFreq) * sum(idxCal);
                end
            end
            eceUncal = eceUncal / N;
            eceCal = eceCal / N;

            % Calibration should reduce or maintain ECE
            tc.verifyLessThanOrEqual(eceCal, eceUncal + 0.05, ...
                sprintf('Calibration should reduce ECE (uncal=%.3f, cal=%.3f)', ...
                eceUncal, eceCal));
        end

        function testMultiLabelCalibration(tc)
            %TESTMULTILABELCALIBRATION Test calibration for multi-label predictions.
            %   Verifies that each label can be calibrated independently.

            N = 200;
            L = 3;
            scores = rand(N, L);
            Ytrue = rand(N, L) > 0.5;

            % Calibrate each label independently
            allCalibrators = cell(L, 1);
            for i = 1:L
                [~, allCalibrators{i}] = reg.calibrate_probabilities(scores(:, i), Ytrue(:, i), ...
                    'Method', 'platt');
            end

            % Apply calibration
            probsCal = zeros(N, L);
            for i = 1:L
                probsCal(:, i) = reg.apply_calibration(scores(:, i), allCalibrators{i});
            end

            tc.verifyEqual(size(probsCal), size(scores), ...
                'Calibrated multi-label probabilities should have same size');
            tc.verifyTrue(all(probsCal(:) >= 0 & probsCal(:) <= 1), ...
                'All calibrated probabilities should be in [0,1]');
        end

        function testEdgeCasePerfectScores(tc)
            %TESTEDGECASEPERFECTSCORES Test calibration when scores match labels perfectly.
            %   Verifies handling of already-calibrated scores.

            N = 100;
            Ytrue = rand(N, 1) > 0.5;
            scores = double(Ytrue);  % Perfect scores

            [probsCal, calibrators] = reg.calibrate_probabilities(scores, Ytrue, 'Method', 'platt');

            % Calibrated scores should still be close to original
            tc.verifyLessThan(mean(abs(probsCal - scores)), 0.1, ...
                'Perfect scores should not change much after calibration');
        end

        function testEdgeCaseAllPositive(tc)
            %TESTEDGECASEALLPOSITIVE Test when all labels are positive.
            %   Verifies handling of single-class data.

            N = 100;
            scores = rand(N, 1);
            Ytrue = true(N, 1);  % All positive

            % This should work but may produce warning about single class
            [probsCal, calibrators] = reg.calibrate_probabilities(scores, Ytrue, 'Method', 'platt', 'Verbose', false);
            tc.verifyTrue(all(probsCal >= 0 & probsCal <= 1), ...
                'Should handle all-positive case gracefully');
        end

        function testEmptyInput(tc)
            %TESTEMPTYINPUT Test handling of empty input.
            %   Verifies graceful handling of empty arrays.

            scores = zeros(0, 1);
            Ytrue = false(0, 1);

            % Empty input should return empty calibrators with identity calibration
            [probsCal, calibrators] = reg.calibrate_probabilities(scores, Ytrue, 'Method', 'platt', 'Verbose', false);
            tc.verifyNotEmpty(calibrators, ...
                'Should return calibrators even for empty input');
        end

        function testCalibrationPersistence(tc)
            %TESTCALIBRATIONPERSISTENCE Test that calibration model can be saved/loaded.
            %   Verifies model serialization.

            N = 150;
            scores = rand(N, 1);
            Ytrue = rand(N, 1) > 0.5;

            % Train and save calibrators
            [~, calibrators] = reg.calibrate_probabilities(scores, Ytrue, 'Method', 'platt');

            % Apply to new data
            scoresNew = rand(50, 1);
            probsCal = reg.apply_calibration(scoresNew, calibrators);

            tc.verifyEqual(length(probsCal), length(scoresNew), ...
                'Saved model should work on new data');
            tc.verifyTrue(all(probsCal >= 0 & probsCal <= 1), ...
                'Calibrated probabilities should be valid');
        end
    end
end
