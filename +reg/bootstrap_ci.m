function [ci_lower, ci_upper, boot_stats] = bootstrap_ci(metric_fn, data, varargin)
%BOOTSTRAP_CI Compute bootstrap confidence intervals for a metric.
%   [ci_lower, ci_upper, boot_stats] = BOOTSTRAP_CI(metric_fn, data, ...)
%   computes bootstrap confidence intervals for a metric function applied
%   to data. Uses resampling with replacement to estimate sampling distribution.
%
%   INPUTS:
%       metric_fn - Function handle that computes metric from data
%                   Signature: metric = metric_fn(data_sample)
%       data      - Data to bootstrap (N x D matrix or struct/table)
%
%   NAME-VALUE ARGUMENTS:
%       'Alpha'       - Significance level (default: 0.05 for 95% CI)
%       'NumBootstrap' - Number of bootstrap samples (default: 10000)
%       'Seed'        - Random seed for reproducibility (default: 42)
%       'Method'      - 'percentile' or 'bca' (bias-corrected accelerated)
%                       (default: 'percentile')
%       'Verbose'     - Display progress (default: false)
%
%   OUTPUTS:
%       ci_lower    - Lower bound of confidence interval
%       ci_upper    - Upper bound of confidence interval
%       boot_stats  - Bootstrap statistics (N_bootstrap x 1 vector)
%
%   MOTIVATION:
%       Point estimates alone don't convey uncertainty. Bootstrap CIs allow
%       us to quantify variability in metrics like Recall@10, mAP, nDCG@10
%       without assuming normality.
%
%   EXAMPLE 1: Recall@10 confidence interval
%       % Assume we have a function that computes Recall@10
%       recall_fn = @(sample_idx) compute_recall_at_k(E(sample_idx,:), posSets(sample_idx), 10);
%       data_idx = (1:N)';  % Bootstrap over sample indices
%       metric_fn = @(idx) recall_fn(idx);
%       [ci_low, ci_high] = reg.bootstrap_ci(metric_fn, data_idx);
%       fprintf('Recall@10: %.3f [%.3f, %.3f]\n', mean_recall, ci_low, ci_high);
%
%   EXAMPLE 2: mAP with custom bootstrap function
%       metric_fn = @(sample_idx) reg.eval_retrieval(E(sample_idx,:), posSets(sample_idx), 10);
%       [ci_low, ci_high, boot_stats] = reg.bootstrap_ci(...
%           metric_fn, (1:N)', 'NumBootstrap', 5000, 'Verbose', true);
%
%   EXAMPLE 3: Use with table/struct data
%       % Bootstrap over rows of a table
%       metric_fn = @(T) mean(T.score);  % Example: mean score
%       [ci_low, ci_high] = reg.bootstrap_ci(metric_fn, resultsTable);
%
%   NOTES:
%       - For small samples (N < 50), consider using BCa method for better coverage
%       - NumBootstrap = 10000 is standard; reduce for speed, increase for precision
%       - Metric function should handle resampled data (with duplicates)
%
%   REFERENCES:
%       Efron & Tibshirani 1994 - "An Introduction to the Bootstrap"
%       Davison & Hinkley 1997 - "Bootstrap Methods and their Application"
%
%   SEE ALSO: reg.compare_methods, reg.significance_test

% Parse arguments
p = inputParser;
addParameter(p, 'Alpha', 0.05, @(x) x > 0 && x < 1);
addParameter(p, 'NumBootstrap', 10000, @(x) x > 0);
addParameter(p, 'Seed', 42, @isnumeric);
addParameter(p, 'Method', 'percentile', @(x) ismember(x, {'percentile', 'bca'}));
addParameter(p, 'Verbose', false, @islogical);
parse(p, varargin{:});

alpha = p.Results.Alpha;
B = p.Results.NumBootstrap;
seed = p.Results.Seed;
method = p.Results.Method;
verbose = p.Results.Verbose;

% Set seed for reproducibility
rng(seed);

% Determine sample size
if istable(data) || isstruct(data)
    N = height(data);
elseif ismatrix(data)
    N = size(data, 1);
else
    error('reg:bootstrap_ci:InvalidDataType', ...
        'Data must be matrix, table, or struct.');
end

% Validate metric function
if ~isa(metric_fn, 'function_handle')
    error('reg:bootstrap_ci:InvalidMetricFn', ...
        'metric_fn must be a function handle.');
end

% Initialize bootstrap statistics
boot_stats = zeros(B, 1);

% Compute observed statistic (for BCa method)
if strcmp(method, 'bca')
    try
        theta_hat = metric_fn(data);
    catch ME
        error('reg:bootstrap_ci:MetricFnFailed', ...
            'Failed to compute observed statistic: %s', ME.message);
    end
end

% Perform bootstrap resampling
if verbose
    fprintf('Computing bootstrap confidence interval...\n');
    fprintf('Samples: %d, Bootstrap iterations: %d\n', N, B);
end

for b = 1:B
    % Resample with replacement
    sample_idx = randi(N, N, 1);

    % Get resampled data
    if istable(data)
        data_boot = data(sample_idx, :);
    elseif isstruct(data)
        % For struct arrays
        data_boot = data(sample_idx);
    else
        data_boot = sample_idx;  % Pass indices directly
    end

    % Compute metric on bootstrap sample
    try
        boot_stats(b) = metric_fn(data_boot);
    catch ME
        warning('reg:bootstrap_ci:MetricFnFailedBoot', ...
            'Bootstrap iteration %d failed: %s. Using NaN.', b, ME.message);
        boot_stats(b) = NaN;
    end

    % Progress
    if verbose && mod(b, 1000) == 0
        fprintf('  Progress: %d/%d (%.1f%%)\n', b, B, 100*b/B);
    end
end

% Remove NaN values (from failed iterations)
boot_stats_valid = boot_stats(~isnan(boot_stats));
if numel(boot_stats_valid) < 0.5 * B
    warning('reg:bootstrap_ci:TooManyFailures', ...
        'More than 50%% of bootstrap iterations failed. CI may be unreliable.');
end

% Compute confidence interval
switch method
    case 'percentile'
        % Simple percentile method
        ci_lower = prctile(boot_stats_valid, alpha/2 * 100);
        ci_upper = prctile(boot_stats_valid, (1 - alpha/2) * 100);

    case 'bca'
        % Bias-corrected and accelerated (BCa) method
        % More accurate for skewed distributions or small samples

        % Compute bias correction
        z0 = norminv(mean(boot_stats_valid < theta_hat));

        % Compute acceleration (jackknife)
        jack_stats = zeros(N, 1);
        for i = 1:N
            % Leave-one-out sample
            loo_idx = setdiff(1:N, i);
            if istable(data)
                data_loo = data(loo_idx, :);
            elseif isstruct(data)
                data_loo = data(loo_idx);
            else
                data_loo = loo_idx;
            end

            try
                jack_stats(i) = metric_fn(data_loo);
            catch
                jack_stats(i) = NaN;
            end
        end

        jack_mean = mean(jack_stats(~isnan(jack_stats)));
        a = sum((jack_mean - jack_stats).^3) / (6 * sum((jack_mean - jack_stats).^2)^1.5);

        % Adjusted percentiles
        z_alpha_lower = norminv(alpha/2);
        z_alpha_upper = norminv(1 - alpha/2);

        p_lower = normcdf(z0 + (z0 + z_alpha_lower) / (1 - a * (z0 + z_alpha_lower)));
        p_upper = normcdf(z0 + (z0 + z_alpha_upper) / (1 - a * (z0 + z_alpha_upper)));

        ci_lower = prctile(boot_stats_valid, p_lower * 100);
        ci_upper = prctile(boot_stats_valid, p_upper * 100);

    otherwise
        error('reg:bootstrap_ci:UnknownMethod', 'Unknown method: %s', method);
end

% Display results
if verbose
    fprintf('\nBootstrap CI (%.0f%%):\n', (1-alpha)*100);
    fprintf('  Lower: %.4f\n', ci_lower);
    fprintf('  Upper: %.4f\n', ci_upper);
    fprintf('  Width: %.4f\n', ci_upper - ci_lower);
    fprintf('  Std:   %.4f\n', std(boot_stats_valid));
    fprintf('\n');
end

end
