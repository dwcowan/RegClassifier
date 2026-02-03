function [p_value, h, stats] = significance_test(scores1, scores2, varargin)
%SIGNIFICANCE_TEST Test if two methods have significantly different performance.
%   [p_value, h, stats] = SIGNIFICANCE_TEST(scores1, scores2, ...)
%   performs statistical significance testing to determine if two methods
%   (e.g., baseline vs. fine-tuned) have significantly different performance.
%
%   INPUTS:
%       scores1 - Performance scores for method 1 (N x 1 vector)
%       scores2 - Performance scores for method 2 (N x 1 vector)
%                 Must be paired (same queries/samples)
%
%   NAME-VALUE ARGUMENTS:
%       'Test'    - Statistical test to use:
%                   'paired-t' (default) - Paired t-test (assumes normality)
%                   'wilcoxon' - Wilcoxon signed-rank (non-parametric)
%                   'mcnemar' - McNemar's test (for binary outcomes)
%                   'bootstrap' - Bootstrap resampling test
%       'Alpha'   - Significance level (default: 0.05)
%       'Tail'    - 'both' (default), 'right' (method 2 > method 1), 'left'
%       'Correction' - Multiple comparison correction:
%                      'none' (default), 'bonferroni', 'holm', 'fdr'
%       'NumComparisons' - Number of comparisons for correction (default: 1)
%       'Verbose' - Display detailed results (default: true)
%
%   OUTPUTS:
%       p_value - P-value of the test
%       h       - Hypothesis test result (1 = reject null, 0 = fail to reject)
%       stats   - Struct with test statistics:
%                 .test_name    - Name of test used
%                 .statistic    - Test statistic value
%                 .df           - Degrees of freedom (if applicable)
%                 .effect_size  - Cohen's d or rank-biserial correlation
%                 .mean_diff    - Mean difference (method2 - method1)
%                 .ci           - Confidence interval for difference
%
%   WHICH TEST TO USE:
%
%   Paired T-Test:
%       - Assumes: Differences are normally distributed
%       - Use when: N > 30 or differences are approximately normal
%       - Most powerful if assumptions hold
%
%   Wilcoxon Signed-Rank:
%       - Non-parametric (no normality assumption)
%       - Use when: Small sample or non-normal differences
%       - More robust, slightly less powerful
%
%   McNemar's Test:
%       - For binary outcomes (correct/incorrect, hit/miss)
%       - Use when: Comparing classification accuracy
%       - scores1 and scores2 should be 0/1 vectors
%
%   Bootstrap:
%       - Non-parametric resampling
%       - Use when: Very small sample or unknown distribution
%       - Most general, computationally expensive
%
%   EXAMPLE 1: Compare baseline vs. fine-tuned Recall@10
%       recall_baseline = [0.8, 0.75, 0.82, 0.78, 0.81];  % 5-fold CV
%       recall_finetuned = [0.85, 0.82, 0.87, 0.83, 0.86];
%       [p, h, stats] = reg.significance_test(recall_baseline, recall_finetuned, ...
%           'Test', 'paired-t', 'Verbose', true);
%       if h
%           fprintf('Fine-tuning significantly improves Recall@10 (p=%.4f)\n', p);
%       end
%
%   EXAMPLE 2: Multiple comparisons with Bonferroni correction
%       % Comparing 3 methods: baseline, projection, fine-tuned
%       % Total 3 pairwise comparisons
%       [p1, h1] = reg.significance_test(baseline, projection, ...
%           'Correction', 'bonferroni', 'NumComparisons', 3);
%       [p2, h2] = reg.significance_test(baseline, finetuned, ...
%           'Correction', 'bonferroni', 'NumComparisons', 3);
%       [p3, h3] = reg.significance_test(projection, finetuned, ...
%           'Correction', 'bonferroni', 'NumComparisons', 3);
%
%   EXAMPLE 3: Non-parametric test for small sample
%       [p, h, stats] = reg.significance_test(scores1, scores2, ...
%           'Test', 'wilcoxon', 'Alpha', 0.05);
%
%   REFERENCES:
%       Dror et al. 2018 - "The Hitchhiker's Guide to Testing Statistical
%                           Significance in Natural Language Processing"
%       Dietterich 1998 - "Approximate Statistical Tests for Comparing
%                          Supervised Classification Learning Algorithms"
%
%   SEE ALSO: reg.bootstrap_ci, reg.compare_methods

% Parse arguments
p = inputParser;
addParameter(p, 'Test', 'paired-t', @(x) ismember(x, {'paired-t', 'wilcoxon', 'mcnemar', 'bootstrap'}));
addParameter(p, 'Alpha', 0.05, @(x) x > 0 && x < 1);
addParameter(p, 'Tail', 'both', @(x) ismember(x, {'both', 'right', 'left'}));
addParameter(p, 'Correction', 'none', @(x) ismember(x, {'none', 'bonferroni', 'holm', 'fdr'}));
addParameter(p, 'NumComparisons', 1, @(x) x >= 1);
addParameter(p, 'Verbose', true, @islogical);
parse(p, varargin{:});

test_type = p.Results.Test;
alpha = p.Results.Alpha;
tail = p.Results.Tail;
correction = p.Results.Correction;
num_comparisons = p.Results.NumComparisons;
verbose = p.Results.Verbose;

% Validate inputs
if numel(scores1) ~= numel(scores2)
    error('reg:significance_test:SizeMismatch', ...
        'scores1 and scores2 must have the same length (paired samples).');
end

scores1 = scores1(:);  % Column vector
scores2 = scores2(:);
N = numel(scores1);

% Remove NaN pairs
valid = ~isnan(scores1) & ~isnan(scores2);
if sum(~valid) > 0
    warning('reg:significance_test:NaNRemoved', ...
        'Removed %d pairs with NaN values.', sum(~valid));
    scores1 = scores1(valid);
    scores2 = scores2(valid);
    N = numel(scores1);
end

% Compute difference
diff = scores2 - scores1;

% Initialize stats struct
stats = struct();
stats.test_name = test_type;
stats.mean_diff = mean(diff);
stats.n = N;

% Perform test
switch test_type
    case 'paired-t'
        % Paired t-test
        [h, p_value, ci, tstats] = ttest(diff, 0, 'Alpha', alpha, 'Tail', tail);
        stats.statistic = tstats.tstat;
        stats.df = tstats.df;
        stats.ci = ci;

        % Effect size: Cohen's d for paired samples
        stats.effect_size = mean(diff) / std(diff);  % Cohen's d_z

    case 'wilcoxon'
        % Wilcoxon signed-rank test
        [p_value, h, wilcox_stats] = signrank(scores1, scores2, ...
            'alpha', alpha, 'tail', tail);
        stats.statistic = wilcox_stats.signedrank;

        % Effect size: rank-biserial correlation
        stats.effect_size = stats.statistic / (N * (N+1) / 2);

        % CI via bootstrap (Wilcoxon doesn't provide CI directly)
        try
            [ci_low, ci_high] = reg.bootstrap_ci(@(idx) median(diff(idx)), (1:N)', ...
                'Alpha', alpha, 'NumBootstrap', 5000, 'Verbose', false);
            stats.ci = [ci_low, ci_high];
        catch
            stats.ci = [NaN, NaN];
        end

    case 'mcnemar'
        % McNemar's test for binary outcomes
        % Validate binary
        if ~all(ismember(scores1, [0,1])) || ~all(ismember(scores2, [0,1]))
            error('reg:significance_test:NotBinary', ...
                'McNemar test requires binary (0/1) scores.');
        end

        % Build contingency table
        % b = method1 correct, method2 incorrect
        % c = method1 incorrect, method2 correct
        b = sum(scores1 == 1 & scores2 == 0);
        c = sum(scores1 == 0 & scores2 == 1);

        % McNemar's test statistic
        if b + c == 0
            % No discordant pairs
            p_value = 1.0;
            h = 0;
            stats.statistic = 0;
        else
            stats.statistic = (abs(b - c) - 1)^2 / (b + c);  % Continuity correction
            p_value = 1 - chi2cdf(stats.statistic, 1);
            h = (p_value < alpha);
        end

        stats.b = b;
        stats.c = c;
        stats.effect_size = (c - b) / (c + b);  % Proportion of discordant pairs favoring method 2
        stats.ci = [NaN, NaN];  % Not applicable

    case 'bootstrap'
        % Bootstrap resampling test
        % H0: mean(diff) = 0
        % Compute p-value by resampling under null

        B = 10000;  % Bootstrap samples
        boot_diffs = zeros(B, 1);

        observed_mean_diff = mean(diff);

        for b = 1:B
            % Resample with replacement
            sample_idx = randi(N, N, 1);
            boot_diffs(b) = mean(diff(sample_idx));
        end

        % P-value: proportion of bootstrap samples as extreme as observed
        if strcmp(tail, 'both')
            p_value = mean(abs(boot_diffs) >= abs(observed_mean_diff));
        elseif strcmp(tail, 'right')
            p_value = mean(boot_diffs >= observed_mean_diff);
        else  % 'left'
            p_value = mean(boot_diffs <= observed_mean_diff);
        end

        h = (p_value < alpha);
        stats.statistic = observed_mean_diff;
        stats.ci = prctile(boot_diffs, [alpha/2*100, (1-alpha/2)*100]);
        stats.effect_size = observed_mean_diff / std(diff);  % Standardized effect

    otherwise
        error('reg:significance_test:UnknownTest', 'Unknown test: %s', test_type);
end

% Apply multiple comparison correction
p_value_original = p_value;
if num_comparisons > 1 && ~strcmp(correction, 'none')
    switch correction
        case 'bonferroni'
            p_value = min(1.0, p_value * num_comparisons);

        case 'holm'
            % Note: Holm requires all p-values at once
            % Here we approximate by adjusting single p-value
            warning('reg:significance_test:HolmApproximate', ...
                'Holm correction requires all p-values. Using Bonferroni approximation.');
            p_value = min(1.0, p_value * num_comparisons);

        case 'fdr'
            % Benjamini-Hochberg FDR control
            % Requires all p-values at once
            warning('reg:significance_test:FDRApproximate', ...
                'FDR correction requires all p-values. Using Bonferroni approximation.');
            p_value = min(1.0, p_value * num_comparisons);
    end

    % Recompute hypothesis test with corrected p-value
    h = (p_value < alpha);

    stats.p_value_uncorrected = p_value_original;
    stats.correction = correction;
    stats.num_comparisons = num_comparisons;
end

% Display results
if verbose
    fprintf('\n=== Significance Test Results ===\n');
    fprintf('Test:              %s\n', test_type);
    fprintf('Sample size:       %d\n', N);
    fprintf('Mean difference:   %.4f\n', stats.mean_diff);
    fprintf('Effect size:       %.4f\n', stats.effect_size);
    if isfield(stats, 'df')
        fprintf('Test statistic:    %.4f (df=%d)\n', stats.statistic, stats.df);
    else
        fprintf('Test statistic:    %.4f\n', stats.statistic);
    end
    fprintf('P-value:           %.4f', p_value);
    if num_comparisons > 1 && ~strcmp(correction, 'none')
        fprintf(' (corrected: %s, k=%d, uncorrected=%.4f)', ...
            correction, num_comparisons, p_value_original);
    end
    fprintf('\n');
    fprintf('Significance:      %s (alpha=%.2f)\n', ...
        ternary(h, '***SIGNIFICANT***', 'not significant'), alpha);
    if ~isnan(stats.ci(1))
        fprintf('%.0f%% CI:            [%.4f, %.4f]\n', ...
            (1-alpha)*100, stats.ci(1), stats.ci(2));
    end
    fprintf('================================\n\n');
end

end

function result = ternary(condition, true_val, false_val)
    % Helper function for ternary operator
    if condition
        result = true_val;
    else
        result = false_val;
    end
end
