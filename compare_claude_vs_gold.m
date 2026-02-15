function results = compare_claude_vs_gold(claude_file)
%COMPARE_CLAUDE_VS_GOLD Compute inter-rater reliability between Claude and gold labels.
%
% Usage:
%   results = compare_claude_vs_gold('gold/claude_annotations.csv')
%
% Computes:
%   - Overall Cohen's kappa
%   - Per-label precision, recall, F1, kappa
%   - Confusion matrices
%   - Disagreement analysis
%
% Returns:
%   results - struct with metrics and disagreements

arguments
    claude_file = 'gold/claude_annotations.csv'
end

%% Load gold truth
gold_dir = 'gold';
ytrue_file = fullfile(gold_dir, 'sample_gold_Ytrue.csv');
chunks_file = fullfile(gold_dir, 'sample_gold_chunks.csv');
labels_file = fullfile(gold_dir, 'sample_gold_labels.json');

Y_true = readmatrix(ytrue_file);
chunks_tbl = readtable(chunks_file, 'TextType', 'string');
labels_json = fileread(labels_file);
labels_data = jsondecode(labels_json);
label_names = labels_data.labels;

n_chunks = size(Y_true, 1);
n_labels = length(label_names);

fprintf('=== CLAUDE vs GOLD ANNOTATION COMPARISON ===\n\n');
fprintf('Ground truth: %d chunks × %d labels\n', n_chunks, n_labels);

%% Load Claude annotations
if ~isfile(claude_file)
    error('Claude annotations not found: %s\nPlease annotate chunks first.', claude_file);
end

claude_tbl = readtable(claude_file, 'TextType', 'string');
fprintf('Claude annotations: %s\n\n', claude_file);

% Extract Claude labels (skip chunk_id and text columns)
claude_label_cols = claude_tbl.Properties.VariableNames(3:end);
Y_claude = table2array(claude_tbl(:, claude_label_cols));

% Verify dimensions
assert(size(Y_claude, 1) == n_chunks, 'Chunk count mismatch');
assert(size(Y_claude, 2) == n_labels, 'Label count mismatch');

%% Overall agreement
% Flatten matrices for overall Cohen's kappa
y_true_flat = Y_true(:);
y_claude_flat = Y_claude(:);

% Cohen's kappa
kappa_overall = compute_kappa(y_true_flat, y_claude_flat);

% Overall accuracy
overall_acc = mean(y_true_flat == y_claude_flat);

fprintf('--- OVERALL METRICS ---\n');
fprintf('Cohen''s kappa:    κ = %.3f\n', kappa_overall);
fprintf('Overall accuracy:      %.1f%%\n', 100 * overall_acc);
fprintf('Total annotations: %d (27 chunks × %d labels)\n\n', ...
    length(y_true_flat), n_labels);

%% Per-label metrics
fprintf('--- PER-LABEL METRICS ---\n');
fprintf('%-20s  κ      Prec   Rec    F1     TP  FP  FN  TN\n', 'Label');
fprintf('%s\n', repmat('-', 1, 70));

per_label = table();
per_label.Label = label_names(:);

for i = 1:n_labels
    label = label_names{i};
    y_true_i = Y_true(:, i);
    y_claude_i = Y_claude(:, i);

    % Confusion matrix
    TP = sum(y_true_i == 1 & y_claude_i == 1);
    FP = sum(y_true_i == 0 & y_claude_i == 1);
    FN = sum(y_true_i == 1 & y_claude_i == 0);
    TN = sum(y_true_i == 0 & y_claude_i == 0);

    % Metrics
    precision = TP / max(TP + FP, 1);
    recall = TP / max(TP + FN, 1);
    f1 = 2 * precision * recall / max(precision + recall, eps);
    kappa_i = compute_kappa(y_true_i, y_claude_i);

    fprintf('%-20s  %.3f  %.3f  %.3f  %.3f  %2d  %2d  %2d  %2d\n', ...
        label, kappa_i, precision, recall, f1, TP, FP, FN, TN);

    % Store in table
    per_label.Kappa(i) = kappa_i;
    per_label.Precision(i) = precision;
    per_label.Recall(i) = recall;
    per_label.F1(i) = f1;
    per_label.TP(i) = TP;
    per_label.FP(i) = FP;
    per_label.FN(i) = FN;
    per_label.TN(i) = TN;
end

fprintf('\n');

%% Identify disagreements
fprintf('--- DISAGREEMENTS ---\n');

disagreements = table();
disagree_idx = [];

for i = 1:n_chunks
    true_labels = label_names(Y_true(i, :) == 1);
    claude_labels = label_names(Y_claude(i, :) == 1);

    % Check if different
    if ~isequal(sort(true_labels), sort(claude_labels))
        disagree_idx(end+1) = i; %#ok<AGROW>

        row = table();
        row.chunk_id = chunks_tbl.chunk_id(i);
        row.text_preview = string(chunks_tbl.text{i}(1:min(80, length(chunks_tbl.text{i}))));
        row.gold_labels = {strjoin(true_labels, ', ')};
        row.claude_labels = {strjoin(claude_labels, ', ')};
        row.error_type = {classify_error(true_labels, claude_labels)};

        disagreements = [disagreements; row]; %#ok<AGROW>
    end
end

n_disagree = length(disagree_idx);
n_agree = n_chunks - n_disagree;

fprintf('Agreement:     %d / %d chunks (%.1f%%)\n', n_agree, n_chunks, 100 * n_agree / n_chunks);
fprintf('Disagreements: %d / %d chunks (%.1f%%)\n\n', n_disagree, n_chunks, 100 * n_disagree / n_chunks);

if n_disagree > 0
    fprintf('Disagreement details:\n');
    disp(disagreements);
    fprintf('\n');
end

%% Interpretation
fprintf('--- INTERPRETATION ---\n');
interpret_kappa(kappa_overall);

fprintf('\nPer-label quality:\n');
for i = 1:n_labels
    label = label_names{i};
    kappa_i = per_label.Kappa(i);
    fprintf('  %s: ', label);
    if kappa_i >= 0.80
        fprintf('✅ EXCELLENT (κ=%.3f)\n', kappa_i);
    elseif kappa_i >= 0.60
        fprintf('✓ GOOD (κ=%.3f)\n', kappa_i);
    elseif kappa_i >= 0.40
        fprintf('⚠ MODERATE (κ=%.3f) - needs improvement\n', kappa_i);
    else
        fprintf('❌ POOR (κ=%.3f) - not reliable\n', kappa_i);
    end
end

fprintf('\n--- RECOMMENDATION ---\n');
if kappa_overall >= 0.70
    fprintf('✅ PROCEED with Claude-as-annotator\n');
    fprintf('   Agreement is GOOD/EXCELLENT for automated annotation.\n');
    fprintf('   Consider using Claude to bootstrap labels on full corpus.\n\n');
elseif kappa_overall >= 0.60
    fprintf('⚠ CAUTIOUS PROCEED - refine guidelines first\n');
    fprintf('   Agreement is MODERATE. Review disagreements and clarify edge cases.\n');
    fprintf('   Re-test on 50 chunks after guideline update.\n\n');
else
    fprintf('❌ DO NOT PROCEED - approach needs rework\n');
    fprintf('   Agreement is too low for reliable annotation.\n');
    fprintf('   Consider: (1) Refine label definitions, (2) Add examples, (3) Simplify labels.\n\n');
end

%% Return results
results = struct();
results.kappa_overall = kappa_overall;
results.overall_accuracy = overall_acc;
results.per_label = per_label;
results.disagreements = disagreements;
results.Y_true = Y_true;
results.Y_claude = Y_claude;
results.chunks = chunks_tbl;
results.label_names = label_names;

% Save results
save('gold/claude_validation_results.mat', 'results');
fprintf('💾 Saved results to: gold/claude_validation_results.mat\n\n');

end

%% Helper functions
function kappa = compute_kappa(y1, y2)
%COMPUTE_KAPPA Cohen's kappa for binary labels.
n = length(y1);
p_o = sum(y1 == y2) / n;  % Observed agreement

% Expected agreement
p_1 = sum(y1 == 1) / n;
p_0 = 1 - p_1;
q_1 = sum(y2 == 1) / n;
q_0 = 1 - q_1;
p_e = p_1 * q_1 + p_0 * q_0;

kappa = (p_o - p_e) / max(1 - p_e, eps);
end

function interpret_kappa(kappa)
%INTERPRET_KAPPA Display interpretation of Cohen's kappa.
fprintf('Overall Cohen''s kappa: κ = %.3f\n', kappa);
if kappa >= 0.81
    fprintf('  ✅ ALMOST PERFECT agreement (0.81-1.00)\n');
elseif kappa >= 0.61
    fprintf('  ✅ SUBSTANTIAL agreement (0.61-0.80)\n');
elseif kappa >= 0.41
    fprintf('  ⚠ MODERATE agreement (0.41-0.60)\n');
elseif kappa >= 0.21
    fprintf('  ⚠ FAIR agreement (0.21-0.40)\n');
else
    fprintf('  ❌ POOR agreement (< 0.21)\n');
end
end

function error_type = classify_error(true_labels, claude_labels)
%CLASSIFY_ERROR Categorize type of disagreement.
if isempty(true_labels) && ~isempty(claude_labels)
    error_type = 'False Positive (noise chunk mislabeled)';
elseif ~isempty(true_labels) && isempty(claude_labels)
    error_type = 'False Negative (missed all labels)';
elseif length(claude_labels) > length(true_labels)
    error_type = 'Over-labeling (too many labels)';
elseif length(claude_labels) < length(true_labels)
    error_type = 'Under-labeling (missed some labels)';
else
    error_type = 'Label mismatch (wrong labels)';
end
end
