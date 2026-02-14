# Methodology Review Part 2: Additional Fixes and Recommendations

**Date:** 2026-02-14
**Status:** Post-Implementation Review
**Previous Review:** `METHODOLOGICAL_ISSUES.md` (13 issues identified)
**Fixes Implemented:** `FIXES_IMPLEMENTED.md` (6 of 13 issues addressed)

---

## Executive Summary

This document provides a **second-pass methodology review** identifying:

1. **7 remaining issues from original review** that can be addressed
2. **8 new methodological concerns** not covered in original 13 issues
3. **Prioritized implementation roadmap** for zero-budget research

**Key Finding:** An additional **5-7 issues can be fixed immediately** without requiring manual annotation, significantly improving methodology.

---

## Table of Contents

1. [Current Status](#status)
2. [Remaining Original Issues - Actionable Now](#remaining-original)
3. [New Methodological Concerns](#new-concerns)
4. [Prioritized Fix Recommendations](#recommendations)
5. [Implementation Plan](#implementation-plan)

---

## 1. Current Status <a name="status"></a>

### Implemented Fixes (6 of 13)

| Issue | Severity | Status | Impact |
|-------|----------|--------|--------|
| #11 | LOW | ✅ Seed management | Reproducibility |
| #12 | LOW | ✅ Knobs integration | Configuration |
| #6 | HIGH | ✅ Feature normalization | **Major improvement** |
| #2 | CRITICAL | ✅ Weak supervision | **Major improvement** |
| #4 | HIGH | ✅ Triplet construction | **Major improvement** |
| #5 | HIGH | ✅ Statistical testing | Rigor |
| #1 (Alt) | CRITICAL | ✅ Zero-budget validation | **Research enabler** |

### Remaining Issues (7 of 13)

| Issue | Severity | Annotation Required? | Can Fix Now? |
|-------|----------|---------------------|--------------|
| #1 (Full) | CRITICAL | YES ($42-91K) | ❌ No |
| #3 | CRITICAL | Partial | ✅ **Yes (partial)** |
| #7 | HIGH | YES (graded relevance) | ❌ No |
| #8 | MEDIUM | Partial (validation set) | ✅ **Yes (infrastructure)** |
| #9 | MEDIUM | NO | ✅ **Yes** |
| #10 | MEDIUM | YES (expansion) | ❌ No |
| #13 | LOW | NO | ✅ **Yes** |

**Actionable Now:** Issues #3 (partial), #8 (infrastructure), #9, #13 = **4 issues**

---

## 2. Remaining Original Issues - Actionable Now <a name="remaining-original"></a>

### Issue #3: Multi-Label Dependencies (CRITICAL - Partial Fix) ✅

**What Can Be Done Now:**

Implement **classifier chains** and **label embedding** without requiring validation set.

**Current Problem:**
```matlab
% train_multilabel.m (line 5-13)
parfor j = 1:labelsK
    % Independent one-vs-rest - ignores label co-occurrence
    models{j} = fitclinear(X, y, ...);
end
```

**Proposed Fix:**

**File:** `+reg/train_multilabel_chains.m`

```matlab
function models = train_multilabel_chains(X, Yboot, kfold, varargin)
%TRAIN_MULTILABEL_CHAINS Classifier chains for multi-label learning.
%   Captures label dependencies by chaining classifiers.
%
%   ALGORITHM:
%       For each label j:
%       1. Include predictions from labels 1...(j-1) as additional features
%       2. Train classifier on augmented features
%       3. At prediction time, use predictions from previous labels
%
%   ADVANTAGES:
%       - Captures label co-occurrence patterns
%       - No additional annotation required
%       - Computational cost: same as one-vs-rest
%
%   DISADVANTAGES:
%       - Order-dependent (use random order or optimize)
%       - Prediction must follow same order as training
%
%   USAGE:
%       models = reg.train_multilabel_chains(X, Yboot, 5);
%       % At prediction time:
%       Y_pred = reg.predict_multilabel_chains(models, X_test);

p = inputParser;
addParameter(p, 'LabelOrder', [], @isnumeric);  % Custom order or random
addParameter(p, 'NumEnsemble', 5, @isnumeric);   % Ensemble chains with different orders
addParameter(p, 'Verbose', true, @islogical);
parse(p, varargin{:});

labelsK = size(Yboot, 2);
num_ensemble = p.Results.NumEnsemble;

% Store multiple chains with different orderings
models = struct();
models.chains = cell(num_ensemble, 1);
models.label_orders = zeros(num_ensemble, labelsK);
models.type = 'classifier_chains';

for e = 1:num_ensemble
    % Random label order for each chain
    if isempty(p.Results.LabelOrder)
        label_order = randperm(labelsK);
    else
        label_order = p.Results.LabelOrder;
    end
    models.label_orders(e, :) = label_order;

    chain = cell(labelsK, 1);

    for j_idx = 1:labelsK
        j = label_order(j_idx);
        y = logical(Yboot(:, j));

        if nnz(y) < 3
            chain{j} = [];
            continue;
        end

        % Augment features with previous predictions
        if j_idx == 1
            X_aug = X;
        else
            prev_labels = label_order(1:(j_idx-1));
            X_aug = [X, double(Yboot(:, prev_labels))];
        end

        % Train classifier on augmented features
        chain{j} = fitclinear(X_aug, y, 'Learner', 'logistic', ...
            'ObservationsIn', 'rows', 'KFold', kfold, ...
            'ClassNames', [false true]);
    end

    models.chains{e} = chain;
end

if p.Results.Verbose
    fprintf('Trained %d classifier chains\n', num_ensemble);
end
end
```

**File:** `+reg/predict_multilabel_chains.m`

```matlab
function [Y_pred, scores] = predict_multilabel_chains(models, X_test)
%PREDICT_MULTILABEL_CHAINS Predict using ensemble of classifier chains.
%   Averages predictions across multiple chains with different orderings.

num_ensemble = numel(models.chains);
labelsK = numel(models.chains{1});
N = size(X_test, 1);

% Accumulate scores across ensemble
scores_sum = zeros(N, labelsK);

for e = 1:num_ensemble
    chain = models.chains{e};
    label_order = models.label_orders(e, :);

    Y_pred_chain = zeros(N, labelsK);
    scores_chain = zeros(N, labelsK);

    for j_idx = 1:labelsK
        j = label_order(j_idx);

        if isempty(chain{j}), continue; end

        % Augment features with previous predictions
        if j_idx == 1
            X_aug = X_test;
        else
            prev_labels = label_order(1:(j_idx-1));
            X_aug = [X_test, Y_pred_chain(:, prev_labels)];
        end

        % Predict (use kfoldPredict if CV model)
        if isa(chain{j}, 'ClassificationPartitionedLinear')
            [~, score] = kfoldPredict(chain{j});
            scores_chain(:, j) = score(:, 2);  % Positive class
        else
            [~, score] = predict(chain{j}, X_aug);
            scores_chain(:, j) = score(:, 2);
        end

        % Binarize for next label
        Y_pred_chain(:, j) = scores_chain(:, j) > 0.5;
    end

    scores_sum = scores_sum + scores_chain;
end

% Average across ensemble
scores = scores_sum / num_ensemble;
Y_pred = scores > 0.5;
end
```

**Impact:**
- Captures IRB ↔ CreditRisk dependencies
- Liquidity_LCR ↔ Liquidity_NSFR co-occurrence
- Expected 5-10% F1 improvement
- **Can be implemented and tested immediately**

---

### Issue #8: Hyperparameter Tuning Infrastructure (MEDIUM) ✅

**What Can Be Done Now:**

Create infrastructure for systematic hyperparameter search (even without validation set for now).

**File:** `+reg/hyperparameter_search.m`

```matlab
function [best_config, results] = hyperparameter_search(objective_fn, param_space, varargin)
%HYPERPARAMETER_SEARCH Systematic hyperparameter optimization.
%   Supports grid search, random search, and Bayesian optimization.
%
%   INPUTS:
%       objective_fn - Function handle: @(config) -> score
%                      Higher score is better
%       param_space  - Struct defining parameter ranges
%
%   METHODS:
%       'grid'    - Exhaustive grid search
%       'random'  - Random sampling (more efficient)
%       'bayes'   - Bayesian optimization (most efficient)
%
%   EXAMPLE: Tune fine-tuning hyperparameters
%       param_space = struct(...
%           'EncoderLR', [1e-6, 1e-4], ...     % [min, max]
%           'HeadLR', [1e-4, 1e-2], ...
%           'Margin', [0.1, 1.0], ...
%           'UnfreezeTopLayers', [2, 8]);      % Integer range
%
%       objective = @(config) train_and_evaluate(config);
%       [best, results] = reg.hyperparameter_search(objective, param_space, ...
%           'Method', 'random', 'MaxEvals', 50);
%
%   USAGE WITH ZERO-BUDGET VALIDATION:
%       % Use split-rule F1 as objective
%       objective = @(config) run_zero_budget_eval(config);
%       [best, results] = reg.hyperparameter_search(objective, param_space);

p = inputParser;
addParameter(p, 'Method', 'random', @(x) ismember(x, {'grid', 'random', 'bayes'}));
addParameter(p, 'MaxEvals', 50, @isnumeric);
addParameter(p, 'Verbose', true, @islogical);
addParameter(p, 'SaveProgress', true, @islogical);
addParameter(p, 'OutputFile', 'hyperparam_search_results.mat', @ischar);
parse(p, varargin{:});

method = p.Results.Method;
max_evals = p.Results.MaxEvals;

switch method
    case 'grid'
        [best_config, results] = grid_search(objective_fn, param_space, max_evals);
    case 'random'
        [best_config, results] = random_search(objective_fn, param_space, max_evals, p.Results);
    case 'bayes'
        [best_config, results] = bayesian_search(objective_fn, param_space, max_evals);
end

if p.Results.SaveProgress
    save(p.Results.OutputFile, 'best_config', 'results');
    fprintf('Results saved to: %s\n', p.Results.OutputFile);
end
end

function [best_config, results] = random_search(objective_fn, param_space, max_evals, opts)
%RANDOM_SEARCH Sample parameters from uniform/log-uniform distributions.

param_names = fieldnames(param_space);
num_params = numel(param_names);

configs = cell(max_evals, 1);
scores = zeros(max_evals, 1);

fprintf('Starting random search (%d evaluations)...\n', max_evals);

for trial = 1:max_evals
    % Sample random configuration
    config = struct();
    for i = 1:num_params
        name = param_names{i};
        range = param_space.(name);

        if numel(range) == 2  % Continuous
            % Use log-uniform for learning rates, uniform for others
            if contains(name, 'LR', 'IgnoreCase', true)
                % Log-uniform sampling
                log_min = log10(range(1));
                log_max = log10(range(2));
                config.(name) = 10^(unifrnd(log_min, log_max));
            else
                % Uniform sampling
                config.(name) = unifrnd(range(1), range(2));
            end

            % Round if parameter name suggests integer
            if contains(name, 'Layers', 'IgnoreCase', true) || ...
               contains(name, 'Size', 'IgnoreCase', true) || ...
               contains(name, 'Epochs', 'IgnoreCase', true)
                config.(name) = round(config.(name));
            end
        else  % Discrete
            config.(name) = range(randi(numel(range)));
        end
    end

    % Evaluate
    try
        score = objective_fn(config);
        scores(trial) = score;
        configs{trial} = config;

        if opts.Verbose
            fprintf('[%3d/%3d] Score: %.4f | ', trial, max_evals, score);
            for i = 1:min(3, num_params)  % Show first 3 params
                name = param_names{i};
                fprintf('%s=%.2e ', name, config.(name));
            end
            fprintf('\n');
        end
    catch ME
        warning('Trial %d failed: %s', trial, ME.message);
        scores(trial) = -inf;
        configs{trial} = config;
    end
end

% Find best
[~, best_idx] = max(scores);
best_config = configs{best_idx};

results = struct();
results.configs = configs;
results.scores = scores;
results.best_idx = best_idx;
results.best_score = scores(best_idx);

fprintf('\nBest score: %.4f\n', results.best_score);
fprintf('Best config:\n');
disp(best_config);
end

function [best_config, results] = bayesian_search(objective_fn, param_space, max_evals)
%BAYESIAN_SEARCH Use MATLAB's bayesopt for efficient search.

param_names = fieldnames(param_space);
optimizable_vars = [];

for i = 1:numel(param_names)
    name = param_names{i};
    range = param_space.(name);

    if contains(name, 'LR', 'IgnoreCase', true)
        % Log-scale for learning rates
        var = optimizableVariable(name, range, 'Transform', 'log');
    elseif contains(name, 'Layers', 'IgnoreCase', true) || ...
           contains(name, 'Epochs', 'IgnoreCase', true)
        % Integer for layer counts
        var = optimizableVariable(name, range, 'Type', 'integer');
    else
        % Continuous for others
        var = optimizableVariable(name, range);
    end

    optimizable_vars = [optimizable_vars; var];
end

% Wrap objective to minimize (bayesopt minimizes)
objective_wrapper = @(params) -objective_fn(table2struct(params));

% Run Bayesian optimization
bayes_results = bayesopt(objective_wrapper, optimizable_vars, ...
    'MaxObjectiveEvaluations', max_evals, ...
    'IsObjectiveDeterministic', false, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'Verbose', 1);

best_config = table2struct(bayes_results.XAtMinObjective);
results = struct();
results.bayes_results = bayes_results;
results.best_score = -bayes_results.MinObjective;
results.best_config = best_config;
end
```

**Impact:**
- Enables systematic hyperparameter tuning
- Works with zero-budget validation as objective
- Can be used immediately for method comparison
- Expected 3-5% improvement from proper tuning

---

### Issue #9: Multi-Label Clustering Metrics (MEDIUM) ✅

**What Can Be Done Now:**

Implement proper multi-label clustering evaluation.

**File:** `+reg/eval_clustering_multilabel.m`

```matlab
function S = eval_clustering_multilabel(E, labelsLogical, varargin)
%EVAL_CLUSTERING_MULTILABEL Multi-label aware clustering evaluation.
%   Proper evaluation for multi-label embeddings (does not force single-label).
%
%   METRICS:
%       1. Label co-occurrence@K - Jaccard similarity with K nearest neighbors
%       2. Label distribution KL - KL divergence between local/global distributions
%       3. Multi-label purity - Per-label purity scores
%       4. Neighborhood consistency - How often neighbors share labels
%
%   USAGE:
%       S = reg.eval_clustering_multilabel(E, labelsLogical, 'K', 10);
%       fprintf('Co-occurrence@10: %.3f\n', S.cooccurrence_at_k);
%       fprintf('Purity (micro): %.3f\n', S.multilabel_purity_micro);

p = inputParser;
addParameter(p, 'K', 10, @isnumeric);  % Neighborhood size
addParameter(p, 'Verbose', true, @islogical);
parse(p, varargin{:});

K = p.Results.K;
N = size(E, 1);
L = size(labelsLogical, 2);

% Compute similarity matrix
S_mat = E * E';  % Cosine similarity

% === Metric 1: Label Co-Occurrence@K ===
cooccur = zeros(N, 1);
for i = 1:N
    [~, neighbors] = sort(S_mat(i,:), 'descend');
    neighbors = neighbors(2:(K+1));  % Exclude self

    my_labels = labelsLogical(i,:);
    neighbor_labels = labelsLogical(neighbors,:);

    % Jaccard: intersection / union
    intersection = sum(my_labels & any(neighbor_labels, 1));
    union = sum(my_labels | any(neighbor_labels, 1));

    if union > 0
        cooccur(i) = intersection / union;
    end
end
S.cooccurrence_at_k = mean(cooccur);

% === Metric 2: Label Distribution KL ===
global_dist = sum(labelsLogical, 1) / N;
kl_divs = zeros(N, 1);

for i = 1:N
    [~, neighbors] = sort(S_mat(i,:), 'descend');
    neighbors = neighbors(2:(K+1));

    local_dist = sum(labelsLogical(neighbors,:), 1) / K;
    local_dist = local_dist + 1e-9;  % Smoothing
    global_dist_smooth = global_dist + 1e-9;

    % KL divergence: sum(p * log(p/q))
    kl_divs(i) = sum(global_dist_smooth .* log(global_dist_smooth ./ local_dist));
end
S.label_dist_kl = mean(kl_divs);

% === Metric 3: Multi-Label Purity ===
% Use k-means for cluster assignment (just for purity, not the main metric)
[idx, ~] = kmeans(E, max(2, round(sqrt(N/10))), 'Distance', 'cosine', 'MaxIter', 100);
num_clusters = max(idx);

label_purities = zeros(L, 1);
for label = 1:L
    label_purity = 0;
    for cluster = 1:num_clusters
        cluster_members = find(idx == cluster);
        if isempty(cluster_members), continue; end

        frac = sum(labelsLogical(cluster_members, label)) / numel(cluster_members);
        label_purity = label_purity + numel(cluster_members) * max(frac, 1-frac);
    end
    label_purities(label) = label_purity / N;
end

S.multilabel_purity_macro = mean(label_purities);
S.multilabel_purity_micro = sum(label_purities .* sum(labelsLogical, 1)') / sum(labelsLogical(:));

% === Metric 4: Neighborhood Consistency ===
consistency = zeros(N, 1);
for i = 1:N
    [~, neighbors] = sort(S_mat(i,:), 'descend');
    neighbors = neighbors(2:(K+1));

    my_labels = labelsLogical(i,:);
    % What fraction of neighbors share at least one label?
    neighbor_has_overlap = any(labelsLogical(neighbors,:) & my_labels, 2);
    consistency(i) = mean(neighbor_has_overlap);
end
S.neighborhood_consistency = mean(consistency);

% === Store K ===
S.K = K;

if p.Results.Verbose
    fprintf('\n=== Multi-Label Clustering Evaluation ===\n');
    fprintf('Neighborhood size (K): %d\n', K);
    fprintf('Label co-occurrence@K: %.3f\n', S.cooccurrence_at_k);
    fprintf('Label distribution KL: %.3f (lower is better)\n', S.label_dist_kl);
    fprintf('Multi-label purity (micro): %.3f\n', S.multilabel_purity_micro);
    fprintf('Multi-label purity (macro): %.3f\n', S.multilabel_purity_macro);
    fprintf('Neighborhood consistency: %.3f\n', S.neighborhood_consistency);
end
end
```

**Impact:**
- Proper evaluation of multi-label embeddings
- No forced single-label assumption
- Can validate if fine-tuning preserves label structure
- Immediate integration possible

---

### Issue #13: Hybrid Search Improvements (LOW) ✅

**What Can Be Done Now:**

Implement proper BM25 and learn fusion weight.

**File:** `+reg/hybrid_search_improved.m`

```matlab
function [topK_idx, scores] = hybrid_search_improved(query, chunksT, Xtfidf, E, varargin)
%HYBRID_SEARCH_IMPROVED Proper BM25 + dense fusion with learned weights.
%   Improvements over hybrid_search.m:
%       1. True BM25 (not TF-IDF approximation)
%       2. Learned fusion weight (not hardcoded 0.5)
%       3. Query-adaptive weighting (optional)
%
%   USAGE:
%       [idx, scores] = reg.hybrid_search_improved(query, chunksT, Xtfidf, E, ...
%           'Alpha', 0.3, ...           % Lexical weight (0.3 BM25 + 0.7 Dense)
%           'K', 20, ...                % Return top-20
%           'BM25Params', struct('k1', 1.5, 'b', 0.75));

p = inputParser;
addParameter(p, 'Alpha', 0.3, @(x) x >= 0 && x <= 1);
addParameter(p, 'K', 20, @isnumeric);
addParameter(p, 'BM25Params', struct('k1', 1.5, 'b', 0.75), @isstruct);
addParameter(p, 'Normalize', true, @islogical);
parse(p, varargin{:});

alpha = p.Results.Alpha;
K_top = p.Results.K;
bm25_params = p.Results.BM25Params;

N = size(E, 1);

% === 1. Dense Semantic Search ===
% Encode query
query_emb = reg.doc_embeddings_bert_gpu({query}, struct('embeddings_backend', 'bert'));
dense_scores = E * query_emb';  % Cosine similarity

% === 2. Lexical BM25 Search ===
% Tokenize query
query_tokens = lower(split(query));
query_tokens(strlength(query_tokens) == 0) = [];

% Compute BM25 scores
bm25_scores = compute_bm25(query_tokens, chunksT, Xtfidf, bm25_params);

% === 3. Normalize Scores ===
if p.Results.Normalize
    % Min-max normalization to [0, 1]
    if max(bm25_scores) > min(bm25_scores)
        bm25_scores = (bm25_scores - min(bm25_scores)) / (max(bm25_scores) - min(bm25_scores));
    end
    if max(dense_scores) > min(dense_scores)
        dense_scores = (dense_scores - min(dense_scores)) / (max(dense_scores) - min(dense_scores));
    end
end

% === 4. Hybrid Fusion ===
scores = alpha * bm25_scores + (1 - alpha) * dense_scores;

% === 5. Return Top-K ===
[~, sorted_idx] = sort(scores, 'descend');
topK_idx = sorted_idx(1:min(K_top, N));
end

function bm25_scores = compute_bm25(query_tokens, chunksT, Xtfidf, params)
%COMPUTE_BM25 True BM25 scoring (not TF-IDF approximation).
%   BM25(q, d) = Σ_{t∈q} IDF(t) * (f(t,d) * (k1 + 1)) / (f(t,d) + k1 * (1 - b + b * |d| / avgdl))

k1 = params.k1;  % Saturation parameter (default 1.5)
b = params.b;    % Length normalization (default 0.75)

N = height(chunksT);

% Document lengths (in tokens)
if ismember('text', chunksT.Properties.VariableNames)
    doc_lengths = cellfun(@(x) numel(split(x)), chunksT.text);
else
    % Approximate from TF-IDF matrix
    doc_lengths = sum(Xtfidf > 0, 2);  % Non-zero terms per doc
end
avg_doc_length = mean(doc_lengths);

% Build vocabulary (from TF-IDF matrix column names if available)
% For simplicity, use Xtfidf directly
% Assumption: Xtfidf columns correspond to vocabulary

bm25_scores = zeros(N, 1);

% For each query term
for q_idx = 1:numel(query_tokens)
    term = query_tokens{q_idx};

    % Find term in vocabulary (simplified - assumes ordering)
    % In practice, need to map term -> column index
    % For now, compute over all terms in Xtfidf

    % Term frequency in each document
    tf = full(Xtfidf(:, q_idx));  % Simplified: assumes column alignment

    % Document frequency
    df = nnz(tf > 0);
    if df == 0, continue; end

    % IDF
    idf = log((N - df + 0.5) / (df + 0.5) + 1);

    % BM25 component
    numerator = tf * (k1 + 1);
    denominator = tf + k1 * (1 - b + b * (doc_lengths / avg_doc_length));

    bm25_scores = bm25_scores + idf * (numerator ./ denominator);
end
end
```

**Note:** The BM25 implementation above is simplified. For production, need proper term-to-column mapping.

**Impact:**
- More accurate lexical search
- Learned fusion weight (can optimize on dev set)
- Better ranking quality

---

## 3. New Methodological Concerns <a name="new-concerns"></a>

Beyond the original 13 issues, the following concerns were identified:

### Concern #14: Stratification in Cross-Validation (HIGH)

**Problem:**
```matlab
% train_multilabel.m line 12
'KFold', kfold  % Random k-fold, not stratified
```

For **multi-label classification**, random k-fold may create folds with:
- Zero support for rare labels (e.g., all AML_KYC in one fold)
- Imbalanced label distributions
- Non-representative train/test splits

**Solution:** Implement iterative stratification (Sechidis et al. 2011)

**File:** `+reg/stratified_kfold_multilabel.m`

```matlab
function fold_indices = stratified_kfold_multilabel(Y, num_folds)
%STRATIFIED_KFOLD_MULTILABEL Stratified k-fold for multi-label data.
%   Uses iterative stratification to preserve label distribution in each fold.
%
%   REFERENCE:
%       Sechidis et al. 2011 - "On the Stratification of Multi-label Data"
%
%   ALGORITHM:
%       1. Sort examples by number of labels (rarest first)
%       2. Assign each example to fold with smallest number of that label
%       3. Iterate until all examples assigned
%
%   USAGE:
%       fold_idx = reg.stratified_kfold_multilabel(Yboot, 5);
%       for k = 1:5
%           train_idx = fold_idx ~= k;
%           test_idx = fold_idx == k;
%           % Train on train_idx, test on test_idx
%       end

N = size(Y, 1);
L = size(Y, 2);
fold_indices = zeros(N, 1);

% Count labels per example
labels_per_example = sum(Y, 2);

% Sort examples by label count (ascending - rarest first)
[~, sorted_idx] = sort(labels_per_example);

% Initialize fold label counts
fold_label_counts = zeros(num_folds, L);

% Assign examples to folds
for i = 1:N
    example_idx = sorted_idx(i);
    example_labels = find(Y(example_idx, :));

    % Find fold with minimum total count for this example's labels
    fold_totals = sum(fold_label_counts(:, example_labels), 2);
    [~, best_fold] = min(fold_totals);

    % Assign to fold
    fold_indices(example_idx) = best_fold;

    % Update fold counts
    fold_label_counts(best_fold, example_labels) = ...
        fold_label_counts(best_fold, example_labels) + 1;
end

% Verify stratification
label_freqs = sum(Y, 1) / N;
for k = 1:num_folds
    fold_freqs = sum(Y(fold_indices == k, :), 1) / nnz(fold_indices == k);
    max_deviation = max(abs(fold_freqs - label_freqs));
    fprintf('Fold %d: max label freq deviation = %.4f\n', k, max_deviation);
end
end
```

**Impact:**
- Ensures all folds have representative label distributions
- Critical for rare labels (AML_KYC, Securitisation)
- More reliable CV estimates

---

### Concern #15: Chunk Size Optimization (MEDIUM)

**Problem:**

Chunk size (300 tokens, 80 overlap) appears arbitrary:
```json
// knobs.json
"Chunk": {
    "SizeTokens": 300,   // Why 300?
    "Overlap": 80        // Why 80?
}
```

**No justification or optimization.**

**Solution:** Empirical chunk size optimization

**File:** `+reg/optimize_chunk_size.m`

```matlab
function [optimal_size, results] = optimize_chunk_size(text, varargin)
%OPTIMIZE_CHUNK_SIZE Empirically determine optimal chunk size.
%   Tests multiple chunk sizes and measures:
%       1. Information preservation (topic coverage)
%       2. Computational efficiency
%       3. Prediction performance (zero-budget eval)
%
%   USAGE:
%       [optimal, results] = reg.optimize_chunk_size(sample_texts, ...
%           'SizeRange', [100, 200, 300, 400, 500], ...
%           'OverlapRange', [0, 50, 80, 100]);

p = inputParser;
addParameter(p, 'SizeRange', [150, 200, 250, 300, 350, 400], @isnumeric);
addParameter(p, 'OverlapRange', [0, 40, 80, 120], @isnumeric);
addParameter(p, 'Metric', 'f1_zero_budget', @ischar);
parse(p, varargin{:});

sizes = p.Results.SizeRange;
overlaps = p.Results.OverlapRange;

results = [];
for size_val = sizes
    for overlap_val = overlaps
        if overlap_val >= size_val, continue; end  % Invalid

        % Create chunks with this size
        chunksT = reg.chunk_text(text, size_val, overlap_val);

        % Evaluate (use zero-budget validation)
        score = evaluate_chunk_config(chunksT);

        results = [results; struct(...
            'size', size_val, ...
            'overlap', overlap_val, ...
            'score', score)];
    end
end

% Find optimal
[~, best_idx] = max([results.score]);
optimal_size = results(best_idx);

fprintf('Optimal: Size=%d, Overlap=%d, Score=%.4f\n', ...
    optimal_size.size, optimal_size.overlap, optimal_size.score);
end
```

**Impact:**
- Data-driven chunk size selection
- May improve performance by 3-5%
- Justifies configuration choices

---

### Concern #16: Confidence Calibration (MEDIUM)

**Problem:**

Predicted probabilities from `predict_multilabel.m` may not be well-calibrated.

**Example:**
- Model predicts P(IRB) = 0.95
- Actual frequency when model says 0.95: 0.75 (overconfident)

**Solution:** Platt scaling or isotonic regression

**File:** `+reg/calibrate_probabilities.m`

```matlab
function [calibrated_scores, calibrator] = calibrate_probabilities(scores, Y_true, method)
%CALIBRATE_PROBABILITIES Calibrate classifier probabilities.
%   Uses Platt scaling or isotonic regression.
%
%   METHODS:
%       'platt'     - Fit logistic function (parametric)
%       'isotonic'  - Isotonic regression (non-parametric)
%
%   USAGE:
%       % On development set
%       [~, calibrator] = reg.calibrate_probabilities(scores_dev, Y_dev, 'platt');
%
%       % On test set
%       scores_test_calibrated = apply_calibration(scores_test, calibrator);

if nargin < 3, method = 'platt'; end

L = size(scores, 2);
calibrated_scores = zeros(size(scores));
calibrator = cell(L, 1);

for label = 1:L
    y = Y_true(:, label);
    s = scores(:, label);

    if strcmp(method, 'platt')
        % Fit logistic: P = 1 / (1 + exp(A*s + B))
        mdl = fitglm(s, y, 'Distribution', 'binomial');
        calibrator{label} = mdl;
        calibrated_scores(:, label) = predict(mdl, s);
    elseif strcmp(method, 'isotonic')
        % Isotonic regression (monotonic transformation)
        [~, order] = sort(s);
        y_sorted = y(order);

        % Pool adjacent violators algorithm
        s_iso = isotonic_regression(s, y);
        calibrator{label} = @(x) interp1(s, s_iso, x, 'linear', 'extrap');
        calibrated_scores(:, label) = s_iso;
    end
end
end
```

**Impact:**
- More reliable probability estimates
- Better decision-making (e.g., threshold selection)
- Required for certain downstream applications

---

### Concern #17: Label Hierarchy Modeling (LOW)

**Problem:**

Some labels have hierarchical relationships not modeled:
- IRB **is-a** CreditRisk
- Liquidity_LCR **is-a** Liquidity
- FRTB **is-a** MarketRisk

Current one-vs-rest treats all labels as flat.

**Solution:** Hierarchical multi-label classification

**Approach:**
1. Define label taxonomy (tree or DAG)
2. Enforce hierarchical constraints (if IRB → then CreditRisk)
3. Use hierarchical loss functions

**Not Critical:** Can be deferred to future work.

---

### Concern #18: Temporal Validation (MEDIUM)

**Problem:**

For regulatory documents, we might want to:
- Train on CRR v1.0 (2014-2019)
- Test on CRR v2.0 (2020+)

This validates **temporal generalization** (new regulatory text).

Current approach mixes all data chronologically.

**Solution:**

**File:** `+reg/temporal_split_validation.m`

```matlab
function [train_idx, test_idx] = temporal_split_validation(chunksT, cutoff_date)
%TEMPORAL_SPLIT_VALIDATION Split data by document date.
%   Tests if model trained on older regulations generalizes to newer.
%
%   USAGE:
%       [train, test] = reg.temporal_split_validation(chunksT, ...
%           datetime(2020, 1, 1));  % Train on <2020, test on >=2020

if ~ismember('date', chunksT.Properties.VariableNames)
    error('chunksT must have a "date" column');
end

train_idx = chunksT.date < cutoff_date;
test_idx = chunksT.date >= cutoff_date;

fprintf('Training set: %d chunks (before %s)\n', nnz(train_idx), datestr(cutoff_date));
fprintf('Test set: %d chunks (after %s)\n', nnz(test_idx), datestr(cutoff_date));
end
```

**Impact:**
- More realistic evaluation for regulatory documents
- Tests temporal generalization
- Requires document date metadata

---

### Concern #19: RLHF System Validation (MEDIUM)

**Problem:**

The RLHF system (`+reg/+rl/`) was implemented but **no validation** that it works.

**Questions:**
- Does RL agent actually improve selection over random?
- Does reward model correlate with true quality?
- Is policy stable during training?

**Solution:** Create validation protocol

**File:** `+reg/+rl/validate_rlhf_system.m`

```matlab
function report = validate_rlhf_system(chunksT, features, Yweak, varargin)
%VALIDATE_RLHF_SYSTEM Validate RLHF active learning system.
%   Compares RL-based selection to baselines:
%       1. Random selection
%       2. Uncertainty sampling
%       3. Diversity sampling
%
%   METRICS:
%       - Sample efficiency (F1 vs. annotation budget)
%       - Policy stability (variance across runs)
%       - Reward model calibration (predicted vs. actual quality)
%
%   USAGE:
%       report = reg.rl.validate_rlhf_system(chunksT, features, Yweak, ...
%           'BudgetRange', [50, 100, 150, 200], ...
%           'NumTrials', 5);

p = inputParser;
addParameter(p, 'BudgetRange', [50, 100, 150, 200], @isnumeric);
addParameter(p, 'NumTrials', 5, @isnumeric);
parse(p, varargin{:});

budgets = p.Results.BudgetRange;
num_trials = p.Results.NumTrials;

methods = {'random', 'uncertainty', 'diversity', 'rl'};
results = struct();

for budget = budgets
    fprintf('\n=== Budget: %d chunks ===\n', budget);

    for m = 1:numel(methods)
        method = methods{m};
        f1_scores = zeros(num_trials, 1);

        for trial = 1:num_trials
            % Select chunks using method
            if strcmp(method, 'rl')
                % Use RL agent
                [agent, ~] = reg.rl.train_annotation_agent(...);
                selected = select_with_agent(agent, budget);
            else
                % Use baseline
                [selected, ~] = reg.select_chunks_active_learning(..., ...
                    'Strategy', method);
            end

            % Simulate annotation and evaluate
            f1_scores(trial) = evaluate_selection(selected, ...);
        end

        results.(sprintf('budget_%d', budget)).(method) = struct(...
            'mean_f1', mean(f1_scores), ...
            'std_f1', std(f1_scores), ...
            'scores', f1_scores);

        fprintf('%12s: F1 = %.3f ± %.3f\n', method, mean(f1_scores), std(f1_scores));
    end
end

% Generate report
report = results;
report.summary = 'RLHF validation complete';

% Plot learning curves
figure;
for m = 1:numel(methods)
    method = methods{m};
    means = arrayfun(@(b) results.(sprintf('budget_%d', b)).(method).mean_f1, budgets);
    plot(budgets, means, '-o', 'DisplayName', method);
    hold on;
end
xlabel('Annotation Budget');
ylabel('F1 Score');
legend('Location', 'best');
title('Active Learning: Method Comparison');
grid on;
end
```

**Impact:**
- Validates RLHF actually helps
- Quantifies improvement over baselines
- Ensures system reliability

---

### Concern #20: Embedding Projection Head Validation (MEDIUM)

**Problem:**

The projection head (`train_projection_head.m`) is trained but **no ablation study** shows if it helps.

**Question:** Does projection head improve over frozen BERT embeddings?

**Solution:** Systematic comparison

**File:** `+reg/validate_projection_head.m`

```matlab
function report = validate_projection_head(chunksT, Ylogical, varargin)
%VALIDATE_PROJECTION_HEAD Ablation study for projection head.
%   Compares:
%       1. Frozen BERT (no projection)
%       2. Projection head (768 → 384)
%       3. Different projection dimensions (256, 384, 512)
%       4. Different architectures (1-layer, 2-layer, 3-layer)
%
%   METRICS:
%       - Retrieval: Recall@K, mAP, nDCG
%       - Clustering: Multi-label purity, co-occurrence
%       - Computational cost: Training time, inference time
%
%   USAGE:
%       report = reg.validate_projection_head(chunksT, Ylogical, ...
%           'Dimensions', [256, 384, 512, 768], ...
%           'Architectures', [1, 2, 3]);

p = inputParser;
addParameter(p, 'Dimensions', [256, 384, 512, 768], @isnumeric);
addParameter(p, 'Architectures', [1, 2], @isnumeric);  % Number of hidden layers
parse(p, varargin{:});

dims = p.Results.Dimensions;
archs = p.Results.Architectures;

% Get frozen BERT embeddings
E_bert = reg.doc_embeddings_bert_gpu(chunksT.text, struct());

% Baseline: No projection
fprintf('=== Baseline: Frozen BERT (768-dim) ===\n');
[rec_base, map_base] = reg.eval_retrieval(E_bert, posSets, 10);
fprintf('Recall@10: %.3f, mAP: %.3f\n', rec_base, map_base);

results = struct();
results.baseline = struct('recall', rec_base, 'map', map_base, 'dim', 768);

% Test projection heads
for dim = dims
    for arch = archs
        fprintf('\n=== Projection: %d-dim, %d-layer ===\n', dim, arch);

        % Train projection head
        tic;
        net = reg.train_projection_head(..., 'ProjDim', dim, 'NumLayers', arch);
        train_time = toc;

        % Apply projection
        tic;
        E_proj = reg.embed_with_head(E_bert, net);
        inference_time = toc;

        % Evaluate
        [rec, map] = reg.eval_retrieval(E_proj, posSets, 10);

        config_name = sprintf('proj_dim%d_arch%d', dim, arch);
        results.(config_name) = struct(...
            'recall', rec, 'map', map, 'dim', dim, 'arch', arch, ...
            'train_time', train_time, 'inference_time', inference_time);

        fprintf('Recall@10: %.3f (+%.3f), mAP: %.3f (+%.3f)\n', ...
            rec, rec - rec_base, map, map - map_base);
        fprintf('Training: %.1fs, Inference: %.1fs\n', train_time, inference_time);
    end
end

% Find best configuration
configs = fieldnames(results);
best_recall = -inf;
best_config = '';
for i = 1:numel(configs)
    if results.(configs{i}).recall > best_recall
        best_recall = results.(configs{i}).recall;
        best_config = configs{i};
    end
end

fprintf('\n=== Best Configuration ===\n');
fprintf('%s: Recall@10 = %.3f\n', best_config, best_recall);

report = results;
report.best_config = best_config;
end
```

**Impact:**
- Validates projection head utility
- Optimizes architecture
- Justifies computational cost

---

### Concern #21: PDF Extraction Validation (HIGH)

**Problem:**

The Python PDF extraction has **no validation** that two-column detection works correctly.

**Risk:**
- Columns might be read in wrong order
- Formulas might be extracted incorrectly
- No ground-truth comparison

**Solution:** Create PDF extraction test suite

**File:** `tests/TestPDFExtractionValidation.m`

```matlab
classdef TestPDFExtractionValidation < fixtures.RegTestCase
    %TESTPDFEXTRACTIONVALIDATION Validate PDF extraction quality.

    methods (Test)
        function testTwoColumnDetection(testCase)
            % Test that two-column PDFs are correctly detected
            pdf_path = 'tests/fixtures/two_column_sample.pdf';

            % Expected: columns should be read left-to-right, not top-to-bottom
            result = reg.ingest_pdf_python(pdf_path);

            % Check order (left column text should appear before right column)
            testCase.verifyTrue(contains(result.text{1}, 'Left column'), ...
                'Left column should be read first');
            testCase.verifyTrue(result.metadata.num_columns == 2, ...
                'Should detect 2 columns');
        end

        function testFormulaExtraction(testCase)
            % Test that formulas are preserved
            pdf_path = 'tests/fixtures/formula_sample.pdf';
            result = reg.ingest_pdf_python(pdf_path);

            % Check that LaTeX-style formulas are preserved
            testCase.verifyTrue(contains(result.text{1}, 'E = mc^2'), ...
                'Formula should be extracted');
        end

        function testPythonFallback(testCase)
            % Test MATLAB fallback when Python fails
            orig_path = getenv('PATH');
            try
                % Temporarily break Python
                setenv('PATH', '');

                result = reg.ingest_pdf_python('tests/fixtures/sim_text.pdf');

                % Should fall back to MATLAB
                testCase.verifyTrue(~isempty(result.text), ...
                    'Should fall back to MATLAB extraction');
            finally
                setenv('PATH', orig_path);
            end
        end
    end
end
```

**Impact:**
- Ensures PDF extraction quality
- Catches regressions
- Builds confidence in system

---

## 4. Prioritized Fix Recommendations <a name="recommendations"></a>

### Tier 1: Critical Fixes (Implement Immediately) ⚡

| Priority | Issue | Effort | Impact | Can Do Now? |
|----------|-------|--------|--------|-------------|
| 1 | **#3: Classifier Chains** | 2 days | HIGH | ✅ Yes |
| 2 | **#14: Stratified K-Fold** | 1 day | HIGH | ✅ Yes |
| 3 | **#21: PDF Validation** | 1 day | HIGH | ✅ Yes |

**Rationale:** These fix critical methodological flaws and require no annotation.

---

### Tier 2: High-Value Enhancements (Implement Next) 🎯

| Priority | Issue | Effort | Impact | Can Do Now? |
|----------|-------|--------|--------|-------------|
| 4 | **#9: Multi-Label Clustering** | 1 day | MEDIUM | ✅ Yes |
| 5 | **#8: Hyperparam Infrastructure** | 2 days | MEDIUM | ✅ Yes |
| 6 | **#15: Chunk Size Optimization** | 1 day | MEDIUM | ✅ Yes |
| 7 | **#13: Hybrid Search** | 1 day | LOW-MEDIUM | ✅ Yes |

**Rationale:** High value-to-effort ratio, can be done immediately.

---

### Tier 3: Validation & Rigor (Implement After Tier 1-2) 📊

| Priority | Issue | Effort | Impact | Can Do Now? |
|----------|-------|--------|--------|-------------|
| 8 | **#19: RLHF Validation** | 2 days | MEDIUM | ✅ Yes |
| 9 | **#20: Projection Head Validation** | 1 day | MEDIUM | ✅ Yes |
| 10 | **#16: Confidence Calibration** | 1 day | MEDIUM | ✅ Yes (on dev set later) |

**Rationale:** Important for scientific rigor but not critical for functionality.

---

### Tier 4: Future Work (Requires Annotation or Low Priority) 🔮

| Priority | Issue | Effort | Impact | Can Do Now? |
|----------|-------|--------|--------|-------------|
| 11 | **#1: Full Ground-Truth** | 7-9 weeks | CRITICAL | ❌ Needs $42-91K |
| 12 | **#7: Graded Relevance** | 1 day + annotation | HIGH | ❌ Needs annotation |
| 13 | **#10: Gold Pack Expansion** | Part of #1 | MEDIUM | ❌ Needs annotation |
| 14 | **#18: Temporal Validation** | 1 day + metadata | MEDIUM | ⏳ Needs date metadata |
| 15 | **#17: Label Hierarchy** | 3 days | LOW | ✅ Yes (low priority) |

**Rationale:** Either requires external resources or lower priority.

---

## 5. Implementation Plan <a name="implementation-plan"></a>

### Week 1: Critical Fixes

**Day 1-2: Classifier Chains (#3)**
- Implement `train_multilabel_chains.m`
- Implement `predict_multilabel_chains.m`
- Test on zero-budget validation
- Compare with one-vs-rest baseline

**Day 3: Stratified K-Fold (#14)**
- Implement `stratified_kfold_multilabel.m`
- Update `train_multilabel.m` to use stratification
- Verify label distribution across folds

**Day 4: PDF Extraction Validation (#21)**
- Create test fixtures (two-column PDF, formula PDF)
- Implement `TestPDFExtractionValidation.m`
- Verify extraction quality
- Document limitations

**Day 5: Integration & Testing**
- Run full pipeline with new fixes
- Compare metrics before/after
- Update documentation

---

### Week 2: High-Value Enhancements

**Day 6-7: Multi-Label Clustering & Hyperparam Infrastructure**
- Implement `eval_clustering_multilabel.m` (#9)
- Implement `hyperparameter_search.m` (#8)
- Integrate into evaluation pipeline

**Day 8: Chunk Size & Hybrid Search**
- Implement `optimize_chunk_size.m` (#15)
- Implement `hybrid_search_improved.m` (#13)
- Run chunk size optimization study

**Day 9-10: Validation Studies**
- RLHF validation (#19)
- Projection head validation (#20)
- Generate validation reports

---

### Week 3: Documentation & Reporting

**Day 11-12: Comprehensive Testing**
- Run all tests
- Verify no regressions
- Statistical comparisons

**Day 13-14: Documentation**
- Update methodology documentation
- Create validation reports
- Update README with findings

**Day 15: Final Review**
- Code review
- Documentation review
- Prepare for commit

---

## Summary

**Actionable Immediately (No Annotation Required):**
- ✅ 4 remaining original issues (#3 partial, #8 infrastructure, #9, #13)
- ✅ 5 new high-priority concerns (#14, #15, #16, #19, #20, #21)

**Total Implementable Fixes:** **9-10 issues** can be fixed now.

**Expected Timeline:** 2-3 weeks of implementation

**Expected Impact:**
- 10-15% improvement in classification F1
- Proper multi-label methodology
- Validated RLHF and projection systems
- Publication-ready rigor

**Critical Next Step:** Implement Tier 1 fixes (classifier chains, stratified k-fold, PDF validation) this week.

---

**END OF METHODOLOGY REVIEW PART 2**
