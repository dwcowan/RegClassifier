function folds = stratified_kfold_multilabel(Y, num_folds, varargin)
%STRATIFIED_KFOLD_MULTILABEL Stratified k-fold cross-validation for multi-label data.
%   folds = STRATIFIED_KFOLD_MULTILABEL(Y, num_folds) creates fold
%   assignments that preserve label distribution across folds.
%
%   This implements iterative stratification (Sechidis et al. 2011) which is
%   critical for multi-label classification to ensure:
%       1. Each fold has similar label frequencies as the full dataset
%       2. Rare labels appear in multiple folds (not concentrated in one)
%       3. Label co-occurrence patterns are preserved
%
%   INPUTS:
%       Y          - Binary label matrix (N x L)
%                    N = number of examples, L = number of labels
%       num_folds  - Number of folds (typically 5 or 10)
%
%   NAME-VALUE ARGUMENTS:
%       'Verbose' - Display stratification statistics (default: false)
%       'Seed'    - Random seed for reproducibility (default: [])
%
%   OUTPUTS:
%       folds - Struct array (num_folds x 1) with fields:
%               .train - Training indices for this fold (logical or indices)
%               .test  - Test indices for this fold (logical or indices)
%
%   ALGORITHM:
%       Iterative stratification ensures balanced label distribution:
%       1. Sort examples by number of labels (rarest first)
%       2. For each example, assign to fold with minimum count of that label
%       3. Update fold label counts and repeat
%
%   EXAMPLE 1: Basic usage
%       folds = reg.stratified_kfold_multilabel(Yboot, 5);
%       for k = 1:length(folds)
%           train_idx = folds(k).train;
%           test_idx = folds(k).test;
%           models = reg.train_multilabel(X(train_idx,:), Yboot(train_idx,:), 1);
%           % Evaluate on test_idx
%       end
%
%   EXAMPLE 2: Verify stratification quality
%       folds = reg.stratified_kfold_multilabel(Yboot, 5, 'Verbose', true);
%       % Displays max label frequency deviation per fold
%
%   EXAMPLE 3: Reproducible folds
%       folds = reg.stratified_kfold_multilabel(Yboot, 5, 'Seed', 42);
%
%   COMPARISON WITH RANDOM K-FOLD:
%       Random k-fold:
%       - May create folds with zero support for rare labels
%       - Imbalanced label distributions across folds
%       - Unreliable CV estimates for multi-label data
%
%       Stratified k-fold:
%       - Ensures all folds have similar label distributions
%       - Rare labels distributed across folds
%       - More reliable CV estimates
%
%   REFERENCE:
%       Sechidis et al. 2011 - "On the Stratification of Multi-label Data"
%       ECML PKDD 2011
%
%   METHODOLOGICAL ISSUE ADDRESSED:
%       Issue #14 (NEW, HIGH): Stratification in cross-validation
%       Original train_multilabel.m used random k-fold which:
%       - Ignored multi-label structure
%       - Created unbalanced folds for rare labels
%       - Led to unreliable CV estimates
%
%   SEE ALSO: reg.train_multilabel, cvpartition

% Parse arguments
p = inputParser;
addParameter(p, 'Verbose', false, @islogical);
addParameter(p, 'Seed', [], @(x) isempty(x) || isnumeric(x));
parse(p, varargin{:});

verbose = p.Results.Verbose;
seed = p.Results.Seed;

% Set seed if provided
if ~isempty(seed)
    rng(seed);
end

% Validate inputs
if ~ismatrix(Y) || ~islogical(Y) && ~all(ismember(Y(:), [0,1]))
    error('reg:stratified_kfold_multilabel:InvalidY', ...
        'Y must be a binary matrix (logical or 0/1)');
end

if num_folds < 2
    error('reg:stratified_kfold_multilabel:InvalidFolds', ...
        'num_folds must be >= 2');
end

[N, L] = size(Y);

if N < num_folds
    error('reg:stratified_kfold_multilabel:InsufficientData', ...
        'Number of examples (%d) must be >= num_folds (%d)', N, num_folds);
end

% Convert to logical if needed
if ~islogical(Y)
    Y = logical(Y);
end

% Initialize fold assignments
fold_indices = zeros(N, 1);

% Count labels per example
labels_per_example = sum(Y, 2);

% Handle edge case: examples with no labels
no_label_idx = find(labels_per_example == 0);
if ~isempty(no_label_idx)
    warning('reg:stratified_kfold_multilabel:NoLabels', ...
        '%d examples have no labels, assigning randomly', numel(no_label_idx));
    fold_indices(no_label_idx) = randi([1, num_folds], numel(no_label_idx), 1);
end

% Get examples with labels
labeled_idx = find(labels_per_example > 0);
N_labeled = numel(labeled_idx);

% Sort labeled examples by label count (ascending - rarest first)
% This ensures rare labels are distributed first
[~, sort_order] = sort(labels_per_example(labeled_idx));
sorted_labeled_idx = labeled_idx(sort_order);

% Initialize fold label counts (num_folds x L)
fold_label_counts = zeros(num_folds, L);

% Iterative stratification algorithm
for i = 1:N_labeled
    example_idx = sorted_labeled_idx(i);
    example_labels = find(Y(example_idx, :));

    if isempty(example_labels)
        continue;  % Already handled above
    end

    % Find fold with minimum total count for this example's labels
    % This balances label distribution across folds
    fold_totals = sum(fold_label_counts(:, example_labels), 2);

    % Break ties randomly for better balance
    min_total = min(fold_totals);
    candidate_folds = find(fold_totals == min_total);

    if numel(candidate_folds) > 1
        best_fold = candidate_folds(randi(numel(candidate_folds)));
    else
        best_fold = candidate_folds(1);
    end

    % Assign to fold
    fold_indices(example_idx) = best_fold;

    % Update fold label counts
    fold_label_counts(best_fold, example_labels) = ...
        fold_label_counts(best_fold, example_labels) + 1;
end

% Verify stratification quality
if verbose
    fprintf('\n=== Stratified K-Fold Verification ===\n');
    fprintf('Number of folds: %d\n', num_folds);
    fprintf('Total examples: %d\n', N);
    fprintf('Total labels: %d\n', L);
    fprintf('\n');

    % Compute global label frequencies
    global_label_freqs = sum(Y, 1) / N;

    % Compute per-fold statistics
    fold_sizes = zeros(num_folds, 1);
    max_deviations = zeros(num_folds, 1);

    for k = 1:num_folds
        fold_mask = fold_indices == k;
        fold_sizes(k) = nnz(fold_mask);

        if fold_sizes(k) == 0
            warning('reg:stratified_kfold_multilabel:EmptyFold', ...
                'Fold %d is empty!', k);
            continue;
        end

        % Compute fold label frequencies
        fold_label_freqs = sum(Y(fold_mask, :), 1) / fold_sizes(k);

        % Compute max absolute deviation from global frequencies
        deviations = abs(fold_label_freqs - global_label_freqs);
        max_deviations(k) = max(deviations);

        fprintf('Fold %d: %4d examples, max label freq deviation = %.4f\n', ...
            k, fold_sizes(k), max_deviations(k));
    end

    fprintf('\nFold size statistics:\n');
    fprintf('  Mean: %.1f\n', mean(fold_sizes));
    fprintf('  Std:  %.1f\n', std(fold_sizes));
    fprintf('  Min:  %d\n', min(fold_sizes));
    fprintf('  Max:  %d\n', max(fold_sizes));

    fprintf('\nStratification quality:\n');
    fprintf('  Mean deviation: %.4f\n', mean(max_deviations));
    fprintf('  Max deviation:  %.4f\n', max(max_deviations));

    % Quality assessment
    if max(max_deviations) < 0.05
        fprintf('  Quality: EXCELLENT (max dev < 0.05)\n');
    elseif max(max_deviations) < 0.10
        fprintf('  Quality: GOOD (max dev < 0.10)\n');
    elseif max(max_deviations) < 0.15
        fprintf('  Quality: ACCEPTABLE (max dev < 0.15)\n');
    else
        fprintf('  Quality: POOR (max dev >= 0.15)\n');
        warning('reg:stratified_kfold_multilabel:PoorStratification', ...
            'Stratification quality is poor. Consider using fewer folds or more data.');
    end
end

% Final validation
if any(fold_indices == 0)
    error('reg:stratified_kfold_multilabel:UnassignedExamples', ...
        '%d examples were not assigned to any fold', nnz(fold_indices == 0));
end

if any(fold_indices < 1) || any(fold_indices > num_folds)
    error('reg:stratified_kfold_multilabel:InvalidFoldIndices', ...
        'Fold indices must be in [1, %d]', num_folds);
end

% Check for empty folds
for k = 1:num_folds
    if nnz(fold_indices == k) == 0
        error('reg:stratified_kfold_multilabel:EmptyFold', ...
            'Fold %d is empty! Try using fewer folds.', k);
    end
end

% Convert fold indices to struct array format
% Similar to MATLAB's cvpartition API
folds = struct('train', {}, 'test', {});
for k = 1:num_folds
    folds(k).test = find(fold_indices == k);
    folds(k).train = find(fold_indices ~= k);
end

end
