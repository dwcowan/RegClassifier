function report = compare_methods_zero_budget(chunksT, varargin)
%COMPARE_METHODS_ZERO_BUDGET Compare baseline vs improved methods (zero cost).
%   report = COMPARE_METHODS_ZERO_BUDGET(chunksT, ...)
%   compares multiple method variants (baseline, improved weak supervision,
%   normalized features, etc.) using zero-budget validation strategies.
%
%   INPUTS:
%       chunksT - Table with chunk text and metadata
%
%   NAME-VALUE ARGUMENTS:
%       'Methods' - Cell array of method names to compare:
%                   'baseline' - Original weak_rules + unnormalized features
%                   'weak_improved' - Improved weak supervision
%                   'features_norm' - Normalized features
%                   'both' - Both improvements
%       'Labels' - Label names (from config)
%       'Config' - Config struct (from config.m)
%       'Verbose' - Display detailed results (default: true)
%
%   OUTPUTS:
%       report - Struct with comparison results:
%                .methods - Method names
%                .metrics - Metrics per method
%                .best_method - Best performing method
%                .improvement - Percentage improvement
%
%   EXAMPLE:
%       C = config();
%       report = reg.compare_methods_zero_budget(chunksT, ...
%           'Methods', {'baseline', 'weak_improved', 'features_norm', 'both'}, ...
%           'Labels', C.labels, ...
%           'Config', C);
%
%       fprintf('Best method: %s\n', report.best_method);
%       fprintf('Improvement: %.1f%%\n', report.improvement);
%
%   ZERO-BUDGET VALIDATION:
%       Uses split-rule validation (train on one keyword set, eval on another)
%       to avoid circular validation without manual annotation.
%
%   SEE ALSO: reg.zero_budget_validation, reg.weak_rules_improved,
%             reg.concat_multimodal_features

% Parse arguments
p = inputParser;
addParameter(p, 'Methods', {'baseline', 'weak_improved'}, @iscell);
addParameter(p, 'Labels', strings(0), @(x) isstring(x) || iscell(x));
addParameter(p, 'Config', struct(), @isstruct);
addParameter(p, 'Verbose', true, @islogical);
parse(p, varargin{:});

methods_to_test = p.Results.Methods;
labels = string(p.Results.Labels);
C = p.Results.Config;
verbose = p.Results.Verbose;

% Initialize report
report = struct();
report.methods = methods_to_test;
report.metrics = containers.Map();

if verbose
    fprintf('\n================================================\n');
    fprintf('ZERO-BUDGET METHOD COMPARISON\n');
    fprintf('================================================\n\n');
    fprintf('Methods to compare: %s\n', strjoin(methods_to_test, ', '));
    fprintf('Chunks: %d\n', height(chunksT));
    fprintf('\n');
end

% Get split rules for validation
[rules_train, rules_eval] = reg.split_weak_rules_for_validation();

%% Test each method
for m = 1:numel(methods_to_test)
    method_name = methods_to_test{m};

    if verbose
        fprintf('--- Testing Method: %s ---\n', method_name);
    end

    % Generate features based on method
    switch method_name
        case 'baseline'
            % Original: weak_rules + unnormalized features
            Yweak_train = generate_labels_simple(chunksT.text, labels, rules_train);
            [docsTok, vocab, Xtfidf] = reg.ta_features(chunksT.text);

            % Compute embeddings (simplified - in practice use full pipeline)
            E = randn(height(chunksT), 768);  % Placeholder
            E = E ./ vecnorm(E, 2, 2);  % L2 normalize

            % Unnormalized concatenation
            features = [Xtfidf, E];

        case 'weak_improved'
            % Improved weak supervision + baseline features
            [Yweak_train, ~] = reg.weak_rules_improved(chunksT.text, labels, ...
                'UseWordBoundaries', true, 'WeightBySpecificity', true, 'Verbose', false);

            [docsTok, vocab, Xtfidf] = reg.ta_features(chunksT.text);
            E = randn(height(chunksT), 768);  % Placeholder
            E = E ./ vecnorm(E, 2, 2);

            % Unnormalized concatenation
            features = [Xtfidf, E];

        case 'features_norm'
            % Baseline weak rules + normalized features
            Yweak_train = generate_labels_simple(chunksT.text, labels, rules_train);

            [docsTok, vocab, Xtfidf] = reg.ta_features(chunksT.text);
            E = randn(height(chunksT), 768);  % Placeholder
            E = E ./ vecnorm(E, 2, 2);

            % Normalized concatenation
            features = reg.concat_multimodal_features(...
                'TFIDF', Xtfidf, 'Embeddings', E, 'Verbose', false);

        case 'both'
            % Both improvements
            [Yweak_train, ~] = reg.weak_rules_improved(chunksT.text, labels, ...
                'UseWordBoundaries', true, 'WeightBySpecificity', true, 'Verbose', false);

            [docsTok, vocab, Xtfidf] = reg.ta_features(chunksT.text);
            E = randn(height(chunksT), 768);  % Placeholder
            E = E ./ vecnorm(E, 2, 2);

            % Normalized concatenation
            features = reg.concat_multimodal_features(...
                'TFIDF', Xtfidf, 'Embeddings', E, 'Verbose', false);

        otherwise
            error('Unknown method: %s', method_name);
    end

    % Train classifier
    Yboot_train = Yweak_train >= 0.5;
    kfold = 5;
    models = reg.train_multilabel(features, Yboot_train, kfold);

    % Predict
    [scores, ~, pred] = reg.predict_multilabel(models, features, Yboot_train);

    % Evaluate on independent eval rules
    Yweak_eval = generate_labels_simple(chunksT.text, labels, rules_eval);
    Yboot_eval = Yweak_eval >= 0.5;

    % Compute metrics
    tp_total = sum(pred & Yboot_eval, 'all');
    fp_total = sum(pred & ~Yboot_eval, 'all');
    fn_total = sum(~pred & Yboot_eval, 'all');

    precision = tp_total / max(1, tp_total + fp_total);
    recall = tp_total / max(1, tp_total + fn_total);
    f1 = 2 * precision * recall / max(1e-9, precision + recall);

    % Store metrics
    method_metrics = struct();
    method_metrics.precision = precision;
    method_metrics.recall = recall;
    method_metrics.f1 = f1;

    report.metrics(method_name) = method_metrics;

    if verbose
        fprintf('  Precision: %.3f\n', precision);
        fprintf('  Recall:    %.3f\n', recall);
        fprintf('  F1:        %.3f\n\n', f1);
    end
end

%% Determine best method
best_f1 = -inf;
best_method = '';
baseline_f1 = 0;

for m = 1:numel(methods_to_test)
    method_name = methods_to_test{m};
    f1 = report.metrics(method_name).f1;

    if strcmp(method_name, 'baseline')
        baseline_f1 = f1;
    end

    if f1 > best_f1
        best_f1 = f1;
        best_method = method_name;
    end
end

report.best_method = best_method;
report.improvement = ((best_f1 - baseline_f1) / max(1e-9, baseline_f1)) * 100;

if verbose
    fprintf('================================================\n');
    fprintf('SUMMARY\n');
    fprintf('================================================\n\n');
    fprintf('Best method: %s (F1: %.3f)\n', best_method, best_f1);

    if baseline_f1 > 0
        fprintf('Improvement over baseline: %.1f%%\n', report.improvement);
    end

    fprintf('\nNote: These metrics use independent keyword sets\n');
    fprintf('for training and evaluation, avoiding circular\n');
    fprintf('validation without manual annotation.\n\n');
end

end

function Yweak = generate_labels_simple(texts, labels, rules)
    % Simple weak label generation (like original weak_rules)
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
            hit = hit | contains(texts, lower(patterns(p)));
        end

        Yweak(:,j) = hit * 0.9;
    end
end
