function results = zero_budget_validation(chunksT, features, varargin)
%ZERO_BUDGET_VALIDATION Evaluate model without manual annotation (zero cost).
%   results = ZERO_BUDGET_VALIDATION(chunksT, features, ...)
%   implements multiple validation strategies that don't require human
%   annotation, suitable for research projects with zero budget.
%
%   INPUTS:
%       chunksT  - Table with chunk text and metadata
%       features - N x D feature matrix (TF-IDF + LDA + embeddings)
%
%   NAME-VALUE ARGUMENTS:
%       'Methods' - Cell array of validation methods to run:
%                   'split-rules' (default) - Train/eval rule splitting
%                   'consistency' - Cross-rule consistency check
%                   'synthetic' - Synthetic test cases
%                   'all' - Run all methods
%       'Verbose' - Display detailed results (default: true)
%       'Labels'  - Label names (from config)
%
%   OUTPUTS:
%       results - Struct with fields:
%                 .split_rules - Split-rule validation metrics
%                 .consistency - Consistency check results
%                 .synthetic   - Synthetic test results
%                 .summary     - Overall summary
%
%   VALIDATION METHODS:
%
%   1. SPLIT-RULE VALIDATION:
%      - Split keywords into disjoint train/eval sets
%      - Train on training rules, evaluate on eval rules
%      - Addresses circular validation (different signals)
%
%   2. CONSISTENCY CHECK:
%      - Multiple independent rule variants
%      - Measure inter-rule agreement (like inter-annotator)
%      - High agreement = reliable labels
%
%   3. SYNTHETIC TEST CASES:
%      - Programmatically generated edge cases
%      - Negation, false matches, boundary cases
%      - Definitive ground truth by construction
%
%   EXAMPLE:
%       C = config();
%       results = reg.zero_budget_validation(chunksT, features, ...
%           'Methods', {'split-rules', 'consistency'}, ...
%           'Labels', C.labels, ...
%           'Verbose', true);
%
%       fprintf('Split-rule Recall@10: %.3f\n', results.split_rules.recall10);
%       fprintf('Consistency score: %.3f\n', results.consistency.agreement);
%
%   ADVANTAGES:
%       - Zero cost (no annotation needed)
%       - Addresses data leakage
%       - Can run today
%       - Multiple independent validation signals
%
%   LIMITATIONS:
%       - All methods use weak labels (noisy)
%       - Less reliable than human annotation
%       - Best for relative comparisons (baseline vs improved)
%
%   SEE ALSO: reg.split_weak_rules_for_validation, reg.weak_rules_improved

% Parse arguments
p = inputParser;
addParameter(p, 'Methods', {'split-rules'}, @(x) iscell(x) || ischar(x) || isstring(x));
addParameter(p, 'Verbose', true, @islogical);
addParameter(p, 'Labels', strings(0), @(x) isstring(x) || iscell(x));
addParameter(p, 'KFold', 5, @(x) x > 0);
parse(p, varargin{:});

methods = p.Results.Methods;
verbose = p.Results.Verbose;
labels = string(p.Results.Labels);
kfold = p.Results.KFold;

% Handle 'all' methods
if ischar(methods) || isstring(methods)
    if strcmpi(methods, 'all')
        methods = {'split-rules', 'consistency', 'synthetic'};
    else
        methods = {char(methods)};
    end
end

% Initialize results
results = struct();

if verbose
    fprintf('\n========================================\n');
    fprintf('ZERO-BUDGET VALIDATION\n');
    fprintf('========================================\n\n');
    fprintf('Methods: %s\n', strjoin(methods, ', '));
    fprintf('Chunks: %d\n', height(chunksT));
    fprintf('Labels: %d\n', numel(labels));
    fprintf('\n');
end

%% Method 1: Split-Rule Validation
if ismember('split-rules', methods)
    if verbose
        fprintf('--- Method 1: Split-Rule Validation ---\n');
    end

    % Get train/eval rule splits
    [rules_train, rules_eval] = reg.split_weak_rules_for_validation();

    % Generate training labels with training rules
    Yweak_train = generate_labels_from_rules(chunksT.text, labels, rules_train);
    Yboot_train = Yweak_train >= 0.5;  % Threshold

    % Generate evaluation labels with eval rules (INDEPENDENT)
    Yweak_eval = generate_labels_from_rules(chunksT.text, labels, rules_eval);
    Yboot_eval = Yweak_eval >= 0.5;

    % Train classifier on training rules (k-fold CV models)
    models = reg.train_multilabel(features, Yboot_train, kfold);

    % Predict using out-of-fold (cross-validated) predictions.
    % train_multilabel returns ClassificationPartitionedModel objects;
    % predict_multilabel calls kfoldPredict which returns predictions
    % where each sample is scored by a model that did NOT see it during
    % training. This avoids in-sample bias.
    [scores, ~, pred] = reg.predict_multilabel(models, features, Yboot_train);

    % Evaluate against eval rules (independent signal)
    split_results = struct();

    % Precision, Recall, F1 per label
    split_results.per_label = zeros(numel(labels), 4);  % [precision, recall, f1, support]
    for j = 1:numel(labels)
        if sum(Yboot_eval(:,j)) == 0
            continue;  % No positive examples in eval set
        end

        tp = sum(pred(:,j) & Yboot_eval(:,j));
        fp = sum(pred(:,j) & ~Yboot_eval(:,j));
        fn = sum(~pred(:,j) & Yboot_eval(:,j));

        precision = tp / max(1, tp + fp);
        recall = tp / max(1, tp + fn);
        f1 = 2 * precision * recall / max(1e-9, precision + recall);

        split_results.per_label(j, :) = [precision, recall, f1, sum(Yboot_eval(:,j))];
    end

    % Micro-averaged metrics
    tp_total = sum(pred & Yboot_eval, 'all');
    fp_total = sum(pred & ~Yboot_eval, 'all');
    fn_total = sum(~pred & Yboot_eval, 'all');

    split_results.micro_precision = tp_total / max(1, tp_total + fp_total);
    split_results.micro_recall = tp_total / max(1, tp_total + fn_total);
    split_results.micro_f1 = 2 * split_results.micro_precision * split_results.micro_recall / ...
        max(1e-9, split_results.micro_precision + split_results.micro_recall);

    % Macro-averaged metrics
    valid_labels = split_results.per_label(:,4) > 0;
    split_results.macro_precision = mean(split_results.per_label(valid_labels, 1));
    split_results.macro_recall = mean(split_results.per_label(valid_labels, 2));
    split_results.macro_f1 = mean(split_results.per_label(valid_labels, 3));

    results.split_rules = split_results;

    if verbose
        fprintf('  Micro-avg Precision: %.3f\n', split_results.micro_precision);
        fprintf('  Micro-avg Recall:    %.3f\n', split_results.micro_recall);
        fprintf('  Micro-avg F1:        %.3f\n', split_results.micro_f1);
        fprintf('  Macro-avg Precision: %.3f\n', split_results.macro_precision);
        fprintf('  Macro-avg Recall:    %.3f\n', split_results.macro_recall);
        fprintf('  Macro-avg F1:        %.3f\n\n', split_results.macro_f1);
    end
end

%% Method 2: Consistency Check
if ismember('consistency', methods)
    if verbose
        fprintf('--- Method 2: Rule Consistency Check ---\n');
    end

    % Generate labels with multiple rule variants
    [rules_train, rules_eval] = reg.split_weak_rules_for_validation();

    Yweak_v1 = generate_labels_from_rules(chunksT.text, labels, rules_train);
    Yweak_v2 = generate_labels_from_rules(chunksT.text, labels, rules_eval);

    % Compute Cohen's kappa (chance-corrected inter-annotator agreement)
    N_chunks = height(chunksT);
    kappa = zeros(numel(labels), 1);
    raw_agreement = zeros(numel(labels), 1);
    for j = 1:numel(labels)
        a = Yweak_v1(:,j) > 0;
        b = Yweak_v2(:,j) > 0;

        % Observed agreement
        p_agree = mean(a == b);
        raw_agreement(j) = p_agree;

        % Expected agreement by chance
        p_a_pos = mean(a);  p_b_pos = mean(b);
        p_chance = p_a_pos * p_b_pos + (1 - p_a_pos) * (1 - p_b_pos);

        % Cohen's kappa
        if abs(1 - p_chance) < 1e-10
            kappa(j) = 1;  % Perfect agreement when chance is 1
        else
            kappa(j) = (p_agree - p_chance) / (1 - p_chance);
        end
    end

    consistency_results = struct();
    consistency_results.per_label_kappa = kappa;
    consistency_results.per_label_agreement = raw_agreement;
    % Filter to labels where both rule sets have at least one positive hit.
    % The old filter (raw_agreement > 0) was effectively a no-op since
    % proportion agreement is almost always > 0.
    has_support = false(numel(labels), 1);
    for j = 1:numel(labels)
        has_support(j) = any(Yweak_v1(:,j) > 0) && any(Yweak_v2(:,j) > 0);
    end
    valid = has_support;
    consistency_results.mean_kappa = mean(kappa(valid));
    consistency_results.mean_agreement = mean(raw_agreement(valid));

    results.consistency = consistency_results;

    if verbose
        fprintf('  Per-label Cohen''s kappa:\n');
        for j = 1:numel(labels)
            fprintf('    %-25s: kappa=%.3f  agreement=%.3f\n', ...
                labels(j), kappa(j), raw_agreement(j));
        end
        fprintf('  Mean kappa:     %.3f\n', consistency_results.mean_kappa);
        fprintf('  Mean agreement: %.3f\n', consistency_results.mean_agreement);
        fprintf('  (kappa > 0.6 = substantial agreement)\n\n');
    end
end

%% Method 3: Synthetic Test Cases
if ismember('synthetic', methods)
    if verbose
        fprintf('--- Method 3: Synthetic Test Cases ---\n');
    end

    % Generate synthetic test cases with known expected labels
    [synthetic_texts, expected_labels] = generate_synthetic_tests(labels);

    % Build ground truth matrix for synthetic texts
    num_synth = numel(synthetic_texts);
    synth_Ytrue = false(num_synth, numel(labels));
    for i = 1:num_synth
        for k = 1:numel(expected_labels{i})
            lbl_idx = find(labels == string(expected_labels{i}{k}));
            if ~isempty(lbl_idx)
                synth_Ytrue(i, lbl_idx) = true;
            end
        end
    end

    % Process synthetic texts through feature extraction and prediction
    % Train on the full corpus, then predict on synthetic texts
    [rules_train_s, ~] = reg.split_weak_rules_for_validation('Verbose', false);
    Yweak_synth_train = generate_labels_from_rules(chunksT.text, labels, rules_train_s);
    Yboot_synth_train = Yweak_synth_train >= 0.5;

    % Featurize synthetic texts in the SAME TF-IDF space as corpus.
    % We fit the vocabulary on the corpus only, then encode synthetic texts
    % against that vocabulary to ensure identical feature dimensions and
    % consistent column semantics.
    [docsTok_corpus, ~, ~] = reg.ta_features(chunksT.text);
    synth_features = encode_tfidf_in_corpus_space( ...
        string(synthetic_texts'), docsTok_corpus);

    % Pad to match full feature width (features may include embeddings)
    D_train = size(features, 2);
    D_synth = size(synth_features, 2);
    if D_synth < D_train
        synth_features = [synth_features, zeros(num_synth, D_train - D_synth)];
    end

    % Train non-CV models for prediction on NEW data.
    % train_multilabel returns CV partitioned models whose kfoldPredict
    % only works on the original training data. For unseen synthetic texts
    % we need standard (non-partitioned) models.
    synth_models = cell(numel(labels), 1);
    for j = 1:numel(labels)
        y = double(Yboot_synth_train(:, j));
        if nnz(y) >= 2 && nnz(y) < height(chunksT)
            synth_models{j} = fitclinear(features, y, ...
                'Learner', 'logistic', 'ObservationsIn', 'rows');
        else
            synth_models{j} = [];
        end
    end

    % Predict on synthetic texts
    synth_scores = zeros(num_synth, numel(labels));
    for j = 1:numel(labels)
        if ~isempty(synth_models{j})
            [~, sc] = predict(synth_models{j}, synth_features);
            synth_scores(:, j) = sc(:, end);
        end
    end
    synth_pred = synth_scores > 0.5;

    % Evaluate: pass/fail per test case
    synthetic_results = struct();
    synthetic_results.num_tests = num_synth;
    synthetic_results.passed = 0;
    synthetic_results.failed = 0;
    synthetic_results.details = cell(num_synth, 1);

    for i = 1:num_synth
        expected = synth_Ytrue(i, :);
        predicted = synth_pred(i, :);
        match = isequal(expected, predicted);

        if match
            synthetic_results.passed = synthetic_results.passed + 1;
            status = 'PASS';
        else
            synthetic_results.failed = synthetic_results.failed + 1;
            status = 'FAIL';
        end

        detail = struct();
        detail.text = synthetic_texts{i};
        detail.expected = labels(expected);
        detail.predicted = labels(predicted);
        detail.status = status;
        synthetic_results.details{i} = detail;

        if verbose
            exp_str = strjoin(labels(expected), ', ');
            pred_str = strjoin(labels(predicted), ', ');
            if isempty(exp_str); exp_str = '(none)'; end
            if isempty(pred_str); pred_str = '(none)'; end
            fprintf('  [%s] Expected: {%s}  Predicted: {%s}\n', status, exp_str, pred_str);
        end
    end

    synthetic_results.accuracy = synthetic_results.passed / num_synth;
    results.synthetic = synthetic_results;

    if verbose
        fprintf('  Synthetic test accuracy: %d/%d (%.0f%%)\n\n', ...
            synthetic_results.passed, num_synth, synthetic_results.accuracy * 100);
    end
end

%% Summary
results.summary = struct();
if isfield(results, 'split_rules')
    results.summary.split_rules_f1 = results.split_rules.micro_f1;
end
if isfield(results, 'consistency')
    results.summary.consistency_score = results.consistency.mean_kappa;
end
if isfield(results, 'synthetic')
    results.summary.synthetic_accuracy = results.synthetic.accuracy;
    results.summary.num_synthetic_tests = results.synthetic.num_tests;
end

if verbose
    fprintf('========================================\n');
    fprintf('VALIDATION COMPLETE\n');
    fprintf('========================================\n\n');
    fprintf('KEY INSIGHT: While these metrics use weak labels,\n');
    fprintf('they provide INDEPENDENT validation signals that\n');
    fprintf('address circular validation issues.\n\n');
    fprintf('Use for: Comparing methods (baseline vs improved),\n');
    fprintf('         Monitoring training progress,\n');
    fprintf('         Detecting regressions.\n\n');
end

end

function Yweak = generate_labels_from_rules(texts, labels, rules)
    % Generate weak labels from rule set using word boundary matching
    % to avoid substring false positives (e.g., "AML" in "AMALGAMATION").
    texts = lower(string(texts));
    Yweak = zeros(numel(texts), numel(labels));

    for j = 1:numel(labels)
        lab = labels(j);
        if ~isKey(rules, lab)
            continue;
        end

        patterns = rules(lab);
        hit = false(numel(texts), 1);

        for p = 1:numel(patterns)
            % Use word boundary regex to avoid substring false positives
            pat = ['\<', regexptranslate('escape', char(lower(patterns(p)))), '\>'];
            hit = hit | ~cellfun('isempty', regexp(texts, pat, 'once'));
        end

        Yweak(:,j) = hit * 0.9;
    end
end

function Xtfidf = encode_tfidf_in_corpus_space(texts, corpus_docsTok)
%ENCODE_TFIDF_IN_CORPUS_SPACE Encode new texts in the corpus TF-IDF space.
%   Applies identical preprocessing as ta_features, then computes term
%   counts against the corpus vocabulary and applies corpus IDF weights.
%   This guarantees that column k in the output corresponds to the same
%   word as column k in the corpus features.

    % Rebuild corpus bag with same filtering as ta_features
    bag = bagOfWords(corpus_docsTok);
    counts_sum = full(sum(bag.Counts, 1));
    if any(counts_sum >= 2)
        bag = removeInfrequentWords(bag, 2);
    end
    vocab = bag.Vocabulary;
    V = numel(vocab);
    N_corpus = size(bag.Counts, 1);

    % Preprocess new texts identically to ta_features
    docs = tokenizedDocument(string(texts));
    docs = lower(docs);
    docs = erasePunctuation(docs);
    docs = removeStopWords(docs);
    docs = normalizeWords(docs, 'Style', 'lemma');
    docs = removeShortWords(docs, 3);

    % Build count matrix for new texts in corpus vocabulary
    M = numel(texts);
    X = zeros(M, V);
    for i = 1:M
        words = string(docs(i));
        [found, idx] = ismember(words, vocab);
        valid_idx = idx(found);
        if ~isempty(valid_idx)
            X(i, :) = accumarray(valid_idx(:), 1, [V, 1])';
        end
    end

    % Apply corpus IDF weights (same formula as ta_features)
    idf = log(N_corpus ./ max(1, full(sum(bag.Counts > 0, 1))));
    Xtfidf = X .* idf;
end

function [texts, labels] = generate_synthetic_tests(label_names)
    % Generate synthetic test cases with known labels

    texts = {};
    labels = {};

    % Positive examples
    texts{end+1} = 'Institutions using the IRB approach shall estimate PD for each obligor.';
    labels{end+1} = {'IRB'};

    texts{end+1} = 'The LCR shall be calculated as HQLA divided by net cash outflows.';
    labels{end+1} = {'Liquidity_LCR'};

    texts{end+1} = 'Operational risk capital requirements under the SMA.';
    labels{end+1} = {'OperationalRisk'};

    % Negation examples (should have NO labels)
    texts{end+1} = 'This regulation does not apply to IRB approaches.';
    labels{end+1} = {};

    texts{end+1} = 'Institutions not using the LCR are exempt.';
    labels{end+1} = {};

    % False match examples (should have NO labels)
    texts{end+1} = 'The AMALGAMATION of two credit institutions.';
    labels{end+1} = {};  % Should NOT match AML_KYC

    texts{end+1} = 'SALIENT features of the framework.';
    labels{end+1} = {};  % Should NOT match MarketRisk_FRTB (SA)

    % Multi-label examples
    texts{end+1} = 'IRB institutions shall calculate credit risk capital requirements.';
    labels{end+1} = {'IRB', 'CreditRisk'};

    texts{end+1} = 'LCR and NSFR liquidity requirements must be met.';
    labels{end+1} = {'Liquidity_LCR', 'Liquidity_NSFR'};
end
