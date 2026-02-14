function scores_calibrated = apply_calibration(scores, calibrators)
%APPLY_CALIBRATION Apply calibration models to new scores.
%   scores_calibrated = APPLY_CALIBRATION(scores, calibrators) applies
%   pre-trained calibration models to uncalibrated scores.
%
%   INPUTS:
%       scores      - Uncalibrated scores (N x L)
%       calibrators - Cell array of calibration models from calibrate_probabilities
%
%   OUTPUT:
%       scores_calibrated - Calibrated probabilities (N x L)
%
%   EXAMPLE:
%       % Train calibration on dev set
%       [~, calibrators] = reg.calibrate_probabilities(scores_dev, Y_dev);
%
%       % Apply to test set
%       scores_test_cal = reg.apply_calibration(scores_test, calibrators);
%
%   SEE ALSO: reg.calibrate_probabilities

[N, L] = size(scores);

if numel(calibrators) ~= L
    error('reg:apply_calibration:SizeMismatch', ...
        'calibrators must have same length as number of labels');
end

scores_calibrated = zeros(N, L);

for label = 1:L
    s = scores(:, label);
    cal_model = calibrators{label};

    % Clip to (0, 1)
    s = max(0, min(1, s));

    switch cal_model.method
        case 'identity'
            % No calibration
            scores_calibrated(:, label) = s;

        case 'platt'
            % Apply GLM
            scores_calibrated(:, label) = predict(cal_model.glm_model, s);

        case 'isotonic'
            % Interpolate
            scores_calibrated(:, label) = interp1(cal_model.s_train, ...
                cal_model.s_cal_train, s, 'linear', 'extrap');

            % Clip again after interpolation
            scores_calibrated(:, label) = max(0, min(1, scores_calibrated(:, label)));

        case 'beta'
            % Apply beta calibration
            epsilon = 1e-15;
            s_clipped = max(epsilon, min(1-epsilon, s));
            logit_s = log(s_clipped ./ (1 - s_clipped));
            X = [ones(size(logit_s)), logit_s, logit_s.^2];
            scores_calibrated(:, label) = predict(cal_model.glm_model, X);

        otherwise
            warning('Unknown calibration method: %s', cal_model.method);
            scores_calibrated(:, label) = s;
    end
end

% Final clip
scores_calibrated = max(0, min(1, scores_calibrated));

end
