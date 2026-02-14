function [Y_pred, scores, info] = predict_multilabel_chains(models, X_test, varargin)
%PREDICT_MULTILABEL_CHAINS Predict using ensemble of classifier chains.
%   [Y_pred, scores] = PREDICT_MULTILABEL_CHAINS(models, X_test) predicts
%   multi-label assignments using classifier chains trained by
%   train_multilabel_chains.m.
%
%   Predictions are made by averaging scores across multiple chains with
%   different label orderings, reducing order dependence.
%
%   ALGORITHM:
%       For each chain in ensemble:
%       1. For each label j in chain order:
%          a. Augment features: [X_test, pred_1, ..., pred_{j-1}]
%          b. Predict label j using augmented features
%          c. Use prediction for next label in chain
%       2. Average scores across all chains
%       3. Threshold averaged scores to get binary predictions
%
%   INPUTS:
%       models - Struct from train_multilabel_chains.m
%       X_test - Test feature matrix (N_test x D)
%
%   NAME-VALUE ARGUMENTS:
%       'Threshold'      - Decision threshold (default: 0.5)
%                          Can be scalar or vector (L x 1) for per-label thresholds
%       'Verbose'        - Display prediction progress (default: false)
%       'UseKFoldPredict'- Use kfoldPredict if models have CV (default: true)
%
%   OUTPUTS:
%       Y_pred - Predicted binary labels (N_test x L)
%       scores - Prediction scores [0,1] (N_test x L)
%                Average across ensemble chains
%       info   - Struct with additional information:
%                .scores_per_chain    - Scores from each chain (N_test x L x NumEnsemble)
%                .std_across_chains   - Std dev of scores across chains (N_test x L)
%                .agreement           - Fraction of chains agreeing on prediction (N_test x L)
%
%   EXAMPLE 1: Basic prediction
%       models = reg.train_multilabel_chains(X_train, Y_train, 5);
%       [Y_pred, scores] = reg.predict_multilabel_chains(models, X_test);
%
%   EXAMPLE 2: Custom threshold per label
%       thresholds = [0.4, 0.5, 0.6, ...];  % L thresholds
%       [Y_pred, scores] = reg.predict_multilabel_chains(models, X_test, ...
%           'Threshold', thresholds);
%
%   EXAMPLE 3: Analyze prediction uncertainty
%       [Y_pred, scores, info] = reg.predict_multilabel_chains(models, X_test);
%       % High std_across_chains indicates order-dependent predictions
%       uncertain_idx = find(max(info.std_across_chains, [], 2) > 0.2);
%       fprintf('%d examples with high prediction uncertainty\n', numel(uncertain_idx));
%
%   EXAMPLE 4: Ensemble agreement analysis
%       [Y_pred, scores, info] = reg.predict_multilabel_chains(models, X_test);
%       % agreement = 1.0 means all chains agree
%       % agreement = 0.5 means only half the chains agree
%       low_agreement = find(min(info.agreement, [], 2) < 0.7);
%       fprintf('%d examples with low ensemble agreement\n', numel(low_agreement));
%
%   CHAIN ORDER DEPENDENCE:
%       Single chain predictions depend on label order:
%       - Order [IRB, CreditRisk]: P(CreditRisk | X, IRB)
%       - Order [CreditRisk, IRB]: P(IRB | X, CreditRisk)
%
%       Ensemble averaging reduces this dependence:
%       - Multiple random orderings
%       - Average predictions across orderings
%       - More robust final predictions
%
%   PREDICTION UNCERTAINTY:
%       info.std_across_chains indicates uncertainty due to order:
%       - Low std (< 0.1): Robust prediction, order doesn't matter
%       - High std (> 0.2): Order-dependent, prediction uncertain
%
%   COMPUTATIONAL COST:
%       Time complexity: O(NumEnsemble × L × (D + L))
%       - NumEnsemble chains to evaluate
%       - For each chain, L classifiers
%       - Each classifier uses D features + previous labels
%
%   METHODOLOGICAL ISSUE ADDRESSED:
%       Issue #3 (CRITICAL): Multi-label dependencies
%       This function uses chained predictions to capture label co-occurrence.
%
%   SEE ALSO: reg.train_multilabel_chains, reg.predict_multilabel

% Parse arguments
p = inputParser;
addParameter(p, 'Threshold', 0.5, @(x) isnumeric(x) && all(x >= 0) && all(x <= 1));
addParameter(p, 'Verbose', false, @islogical);
addParameter(p, 'UseKFoldPredict', true, @islogical);
parse(p, varargin{:});

threshold = p.Results.Threshold;
verbose = p.Results.Verbose;
use_kfold = p.Results.UseKFoldPredict;

% Validate inputs
if ~isstruct(models) || ~isfield(models, 'chains')
    error('reg:predict_multilabel_chains:InvalidModels', ...
        'models must be a struct from train_multilabel_chains');
end

if ~strcmp(models.type, 'classifier_chains')
    error('reg:predict_multilabel_chains:WrongModelType', ...
        'Expected classifier_chains, got: %s', models.type);
end

N_test = size(X_test, 1);
num_ensemble = models.num_ensemble;
labelsK = models.num_labels;

if size(X_test, 2) ~= models.num_features
    error('reg:predict_multilabel_chains:FeatureMismatch', ...
        'X_test has %d features, expected %d', size(X_test, 2), models.num_features);
end

% Handle threshold
if isscalar(threshold)
    threshold = repmat(threshold, 1, labelsK);
elseif numel(threshold) ~= labelsK
    error('reg:predict_multilabel_chains:InvalidThreshold', ...
        'Threshold must be scalar or vector of length L=%d', labelsK);
end

if verbose
    fprintf('\n=== Predicting with Classifier Chains ===\n');
    fprintf('Test examples: %d\n', N_test);
    fprintf('Ensemble size: %d\n', num_ensemble);
    fprintf('Labels:        %d\n', labelsK);
    fprintf('\n');
end

% Initialize storage for ensemble predictions
scores_all_chains = zeros(N_test, labelsK, num_ensemble);

% === Predict with each chain ===
for e = 1:num_ensemble
    if verbose && mod(e, max(1, floor(num_ensemble/10))) == 0
        fprintf('  Processing chain %d/%d...\n', e, num_ensemble);
    end

    chain = models.chains{e};
    label_order = models.label_orders(e, :);

    % Initialize predictions for this chain
    Y_pred_chain = zeros(N_test, labelsK);
    scores_chain = zeros(N_test, labelsK);

    % Predict labels in chain order
    for j_idx = 1:labelsK
        j = label_order(j_idx);

        % Skip if no model for this label
        if isempty(chain{j})
            scores_chain(:, j) = 0;
            Y_pred_chain(:, j) = 0;
            continue;
        end

        % === Augment features with previous predictions ===
        if j_idx == 1
            % First label: use original features only
            X_aug = X_test;
        else
            % Add previous predicted labels as features
            prev_labels = label_order(1:(j_idx-1));
            X_aug = [X_test, Y_pred_chain(:, prev_labels)];
        end

        % === Predict label j ===
        mdl = chain{j};

        if use_kfold && isa(mdl, 'ClassificationPartitionedLinear')
            % Cross-validated model: use kfoldPredict
            % This averages predictions across folds
            [~, score_full] = kfoldPredict(mdl);

            % Extract positive class scores
            if size(score_full, 2) == 2
                scores_chain(:, j) = score_full(:, 2);  % Probability of positive class
            else
                scores_chain(:, j) = score_full;
            end
        else
            % Regular model or no CV: use predict
            [~, score_full] = predict(mdl, X_aug);

            if size(score_full, 2) == 2
                scores_chain(:, j) = score_full(:, 2);
            else
                scores_chain(:, j) = score_full;
            end
        end

        % === Binarize for next label in chain ===
        Y_pred_chain(:, j) = scores_chain(:, j) > threshold(j);
    end

    % Store scores from this chain
    scores_all_chains(:, :, e) = scores_chain;
end

% === Ensemble averaging ===
% Average scores across all chains
scores = mean(scores_all_chains, 3);

% Threshold averaged scores
Y_pred = scores > repmat(threshold, N_test, 1);

% === Compute additional info ===
info = struct();

% Store per-chain scores
info.scores_per_chain = scores_all_chains;

% Compute std dev across chains (indicates prediction uncertainty)
info.std_across_chains = std(scores_all_chains, 0, 3);

% Compute agreement (fraction of chains agreeing with final prediction)
info.agreement = zeros(N_test, labelsK);
for e = 1:num_ensemble
    chain_pred = scores_all_chains(:, :, e) > repmat(threshold, N_test, 1);
    info.agreement = info.agreement + double(chain_pred == Y_pred);
end
info.agreement = info.agreement / num_ensemble;

% Summary statistics
info.mean_std = mean(info.std_across_chains(:));
info.mean_agreement = mean(info.agreement(:));
info.num_ensemble = num_ensemble;

if verbose
    fprintf('\nPrediction complete!\n');
    fprintf('  Mean std across chains:   %.4f\n', info.mean_std);
    fprintf('  Mean ensemble agreement:  %.2f%%\n', 100 * info.mean_agreement);

    % Identify uncertain predictions
    high_std_count = nnz(max(info.std_across_chains, [], 2) > 0.2);
    fprintf('  High uncertainty examples: %d / %d (%.1f%%)\n', ...
        high_std_count, N_test, 100 * high_std_count / N_test);

    % Identify low agreement examples
    low_agreement_count = nnz(min(info.agreement, [], 2) < 0.7);
    fprintf('  Low agreement examples:    %d / %d (%.1f%%)\n', ...
        low_agreement_count, N_test, 100 * low_agreement_count / N_test);
end

end
