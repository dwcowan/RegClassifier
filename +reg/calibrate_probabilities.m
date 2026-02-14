function [calibrated_scores, calibrators] = calibrate_probabilities(scores, Y_true, varargin)
%CALIBRATE_PROBABILITIES Calibrate classifier probability estimates.
%   [calibrated_scores, calibrators] = CALIBRATE_PROBABILITIES(scores, Y_true)
%   calibrates uncalibrated probability estimates using Platt scaling or
%   isotonic regression.
%
%   Uncalibrated classifiers (e.g., logistic regression, SVM) may output
%   scores that don't reflect true probabilities. Calibration fixes this.
%
%   INPUTS:
%       scores - Uncalibrated scores/probabilities (N x L)
%       Y_true - True binary labels (N x L)
%
%   NAME-VALUE ARGUMENTS:
%       'Method'  - Calibration method: 'platt', 'isotonic', 'beta' (default: 'platt')
%       'Verbose' - Display calibration statistics (default: true)
%
%   OUTPUTS:
%       calibrated_scores - Calibrated probabilities (N x L)
%       calibrators       - Cell array of calibration models (L x 1)
%                           Use apply_calibration() to calibrate new data
%
%   METHODS:
%       'platt'    - Fit logistic function P = 1/(1+exp(A*s+B))
%                    Fast, parametric, works well for most cases
%       'isotonic' - Isotonic (monotonic) regression
%                    Non-parametric, flexible, needs more data
%       'beta'     - Beta calibration (Kull et al. 2017)
%                    3-parameter extension of Platt scaling
%
%   EXAMPLE 1: Basic Platt scaling
%       % On development set
%       [scores_cal, calibrators] = reg.calibrate_probabilities(...
%           scores_dev, Y_dev, 'Method', 'platt');
%
%       % On test set
%       scores_test_cal = reg.apply_calibration(scores_test, calibrators);
%
%   EXAMPLE 2: Compare calibration methods
%       methods = {'platt', 'isotonic', 'beta'};
%       for i = 1:numel(methods)
%           [scores_cal, ~] = reg.calibrate_probabilities(scores_dev, Y_dev, ...
%               'Method', methods{i}, 'Verbose', false);
%           ece = compute_ece(scores_cal, Y_test);
%           fprintf('%s ECE: %.4f\n', methods{i}, ece);
%       end
%
%   EXAMPLE 3: Calibration diagnostics
%       [scores_cal, calibrators] = reg.calibrate_probabilities(...
%           scores_dev, Y_dev, 'Verbose', true);
%       % Displays: ECE before/after, Brier score, calibration plot
%
%   EVALUATION METRICS:
%       ECE (Expected Calibration Error):
%       - Partition predictions into bins by confidence
%       - For each bin: |avg_confidence - avg_accuracy|
%       - ECE = weighted average across bins
%       - Lower is better (0 = perfect calibration)
%
%       Brier Score:
%       - Mean squared error of probabilities
%       - BS = mean((p - y)^2)
%       - Lower is better
%
%   WHY CALIBRATION MATTERS:
%       - Decision-making: Need true probabilities for cost-sensitive decisions
%       - Thresholding: Choosing optimal threshold requires calibrated probabilities
%       - Ensembling: Averaging uncalibrated probabilities is problematic
%       - Interpretability: Users trust "90% confident" if it's truly 90%
%
%   METHODOLOGICAL ISSUE ADDRESSED:
%       Issue #16 (NEW, MEDIUM): Confidence calibration
%       Original predict_multilabel.m: Uncalibrated scores
%       This fix: Proper probability calibration
%       Expected: More reliable confidence estimates
%
%   REFERENCES:
%       Platt 1999 - "Probabilistic outputs for support vector machines"
%       Zadrozny & Elkan 2002 - "Transforming classifier scores into probabilities"
%       Kull et al. 2017 - "Beta calibration: a well-founded method for calibrating classifiers"
%       Guo et al. 2017 - "On Calibration of Modern Neural Networks" (ICML)
%
%   SEE ALSO: reg.apply_calibration, reg.compute_ece

% Parse arguments
p = inputParser;
addParameter(p, 'Method', 'platt', @(x) ismember(x, {'platt', 'isotonic', 'beta'}));
addParameter(p, 'Verbose', true, @islogical);
parse(p, varargin{:});

method = p.Results.Method;
verbose = p.Results.Verbose;

% Validate inputs
[N, L] = size(scores);
if size(Y_true, 1) ~= N || size(Y_true, 2) ~= L
    error('reg:calibrate_probabilities:SizeMismatch', ...
        'scores and Y_true must have same dimensions');
end

if ~islogical(Y_true)
    Y_true = logical(Y_true);
end

% Clip scores to (0,1) if needed
scores = max(0, min(1, scores));

if verbose
    fprintf('\n=== Probability Calibration ===\n');
    fprintf('Method: %s\n', method);
    fprintf('Labels: %d\n', L);
    fprintf('Examples: %d\n', N);
    fprintf('\n');
end

% Calibrate each label independently
calibrated_scores = zeros(N, L);
calibrators = cell(L, 1);

for label = 1:L
    y = Y_true(:, label);
    s = scores(:, label);

    % Skip if label has insufficient data
    if nnz(y) < 10 || nnz(~y) < 10
        if verbose
            fprintf('Label %d: insufficient data, using identity calibration\n', label);
        end
        calibrated_scores(:, label) = s;
        calibrators{label} = struct('method', 'identity');
        continue;
    end

    % Apply calibration method
    switch method
        case 'platt'
            [s_cal, cal_model] = platt_scaling(s, y);
        case 'isotonic'
            [s_cal, cal_model] = isotonic_calibration(s, y);
        case 'beta'
            [s_cal, cal_model] = beta_calibration(s, y);
    end

    calibrated_scores(:, label) = s_cal;
    calibrators{label} = cal_model;

    if verbose && mod(label, max(1, floor(L/10))) == 0
        fprintf('Calibrated label %d/%d\n', label, L);
    end
end

% Compute calibration metrics
if verbose
    fprintf('\n=== Calibration Quality ===\n');

    % ECE before calibration
    ece_before = compute_ece(scores, Y_true);
    ece_after = compute_ece(calibrated_scores, Y_true);

    % Brier score
    brier_before = mean((scores - double(Y_true)).^2, 'all');
    brier_after = mean((calibrated_scores - double(Y_true)).^2, 'all');

    fprintf('ECE:         %.4f → %.4f (%.1f%% improvement)\n', ...
        ece_before, ece_after, 100 * (ece_before - ece_after) / ece_before);
    fprintf('Brier Score: %.4f → %.4f (%.1f%% improvement)\n', ...
        brier_before, brier_after, 100 * (brier_before - brier_after) / brier_before);
end

end

% =========================================================================
% PLATT SCALING
% =========================================================================
function [s_cal, model] = platt_scaling(s, y)
%PLATT_SCALING Fit logistic function to calibrate scores.

% Fit logistic regression: P = 1 / (1 + exp(A*s + B))
mdl = fitglm(s, double(y), 'Distribution', 'binomial', 'Link', 'logit');

% Apply calibration
s_cal = predict(mdl, s);

% Store model
model = struct();
model.method = 'platt';
model.glm_model = mdl;
model.A = mdl.Coefficients.Estimate(2);  % Slope
model.B = mdl.Coefficients.Estimate(1);  % Intercept

end

% =========================================================================
% ISOTONIC REGRESSION
% =========================================================================
function [s_cal, model] = isotonic_calibration(s, y)
%ISOTONIC_CALIBRATION Monotonic transformation for calibration.

% Sort by scores
[s_sorted, sort_idx] = sort(s);
y_sorted = y(sort_idx);

% Pool adjacent violators algorithm (PAV)
n = numel(s_sorted);
s_iso = zeros(n, 1);
y_vals = double(y_sorted);

% Simplified PAV
i = 1;
while i <= n
    % Find region where monotonicity is violated
    j = i;
    sum_y = y_vals(i);
    count = 1;

    while j < n && sum_y / count > y_vals(j+1)
        j = j + 1;
        sum_y = sum_y + y_vals(j);
        count = count + 1;
    end

    % Average over region
    avg = sum_y / count;
    s_iso(i:j) = avg;

    i = j + 1;
end

% Unsort
s_cal = zeros(size(s));
s_cal(sort_idx) = s_iso;

% Clip to [0, 1]
s_cal = max(0, min(1, s_cal));

% Store model (interpolation function)
model = struct();
model.method = 'isotonic';
model.s_train = s_sorted;
model.s_cal_train = s_iso;

end

% =========================================================================
% BETA CALIBRATION
% =========================================================================
function [s_cal, model] = beta_calibration(s, y)
%BETA_CALIBRATION 3-parameter extension of Platt scaling.

% Beta calibration: P = 1 / (1 + exp(a + b*logit(s) + c*logit(s)^2))
% Where logit(s) = log(s / (1-s))

% Compute logit
epsilon = 1e-15;
s_clipped = max(epsilon, min(1-epsilon, s));
logit_s = log(s_clipped ./ (1 - s_clipped));

% Fit with quadratic term
X = [ones(size(logit_s)), logit_s, logit_s.^2];
mdl = fitglm(X, double(y), 'Distribution', 'binomial', 'Link', 'logit');

% Apply calibration
s_cal = predict(mdl, X);

% Store model
model = struct();
model.method = 'beta';
model.glm_model = mdl;
model.a = mdl.Coefficients.Estimate(1);
model.b = mdl.Coefficients.Estimate(2);
model.c = mdl.Coefficients.Estimate(3);

end

% =========================================================================
% HELPER: Compute ECE
% =========================================================================
function ece = compute_ece(scores, Y_true)
%COMPUTE_ECE Expected calibration error.

num_bins = 10;
ece = 0;
total_weight = 0;

for bin = 1:num_bins
    % Define bin boundaries
    bin_lower = (bin - 1) / num_bins;
    bin_upper = bin / num_bins;

    % Find predictions in this bin
    in_bin = scores >= bin_lower & scores < bin_upper;

    if ~any(in_bin(:))
        continue;
    end

    % Average confidence in bin
    avg_confidence = mean(scores(in_bin));

    % Average accuracy in bin
    avg_accuracy = mean(double(Y_true(in_bin)));

    % Weight by number of examples
    weight = nnz(in_bin);

    % Accumulate ECE
    ece = ece + weight * abs(avg_confidence - avg_accuracy);
    total_weight = total_weight + weight;
end

if total_weight > 0
    ece = ece / total_weight;
end

end
