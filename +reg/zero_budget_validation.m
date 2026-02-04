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

    % Train classifier on training rules
    models = reg.train_multilabel(features, Yboot_train, kfold);

    % Predict
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

    % Compute agreement (like inter-annotator agreement)
    agreement = zeros(numel(labels), 1);
    for j = 1:numel(labels)
        % Chunks where at least one rule assigns label
        relevant = (Yweak_v1(:,j) > 0) | (Yweak_v2(:,j) > 0);
        if sum(relevant) == 0
            continue;
        end

        % Agreement on these chunks
        both_agree = (Yweak_v1(relevant,j) > 0) == (Yweak_v2(relevant,j) > 0);
        agreement(j) = mean(both_agree);
    end

    consistency_results = struct();
    consistency_results.per_label_agreement = agreement;
    consistency_results.mean_agreement = mean(agreement(agreement > 0));

    results.consistency = consistency_results;

    if verbose
        fprintf('  Mean agreement across labels: %.3f\n', consistency_results.mean_agreement);
        fprintf('  (High agreement = reliable weak labels)\n\n');
    end
end

%% Method 3: Synthetic Test Cases
if ismember('synthetic', methods)
    if verbose
        fprintf('--- Method 3: Synthetic Test Cases ---\n');
    end

    % Generate synthetic test cases
    [synthetic_texts, synthetic_labels] = generate_synthetic_tests(labels);

    % Compute features for synthetic texts
    % (In practice, would need to process through full pipeline)
    % Here we just report what was generated

    synthetic_results = struct();
    synthetic_results.num_tests = numel(synthetic_texts);
    synthetic_results.tests = cell(numel(synthetic_texts), 2);
    for i = 1:numel(synthetic_texts)
        synthetic_results.tests{i,1} = synthetic_texts{i};
        synthetic_results.tests{i,2} = synthetic_labels{i};
    end

    results.synthetic = synthetic_results;

    if verbose
        fprintf('  Generated %d synthetic test cases\n', synthetic_results.num_tests);
        fprintf('  (To evaluate: process through pipeline and check predictions)\n\n');
    end
end

%% Summary
results.summary = struct();
if isfield(results, 'split_rules')
    results.summary.split_rules_f1 = results.split_rules.micro_f1;
end
if isfield(results, 'consistency')
    results.summary.consistency_score = results.consistency.mean_agreement;
end
if isfield(results, 'synthetic')
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
    % Generate weak labels from rule set
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
            % Simple contains check (could use improved version)
            hit = hit | contains(texts, lower(patterns(p)));
        end

        Yweak(:,j) = hit * 0.9;
    end
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
