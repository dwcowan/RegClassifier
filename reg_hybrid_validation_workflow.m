%% Hybrid Validation Workflow for RegClassifier
% This script demonstrates the hybrid validation approach combining:
% 1. Zero-budget split-rule validation
% 2. Active learning chunk selection
% 3. Strategic minimal annotation
% 4. Semi-supervised learning

%% Setup
clear; clc;

% Load configuration
C = config();

% Annotation budget (adjust based on your resources)
ANNOTATION_BUDGET = 100;  % 50, 100, or 200 recommended

fprintf('==========================================================\n');
fprintf('HYBRID VALIDATION WORKFLOW\n');
fprintf('==========================================================\n');
fprintf('Annotation Budget: %d chunks\n', ANNOTATION_BUDGET);
fprintf('Estimated Cost: $%.0f\n', (ANNOTATION_BUDGET * 10 / 60) * 200);
fprintf('==========================================================\n\n');

%% Phase 1: Zero-Budget Baseline Validation

fprintf('PHASE 1: ZERO-BUDGET BASELINE VALIDATION\n');
fprintf('----------------------------------------------------------\n');

% Check if features exist
if ~exist('workspace_after_features.mat', 'file')
    error('Please run reg_pipeline.m first to generate features');
end

% Load data
load('workspace_after_features.mat', 'chunksT', 'features', 'Yweak', 'Yboot');

fprintf('Loaded data:\n');
fprintf('  Chunks: %d\n', height(chunksT));
fprintf('  Features: %d dimensions\n', size(features, 2));
fprintf('  Labels: %d\n', numel(C.labels));
fprintf('\n');

% Get split rules for validation
[rules_train, rules_eval] = reg.split_weak_rules_for_validation();

% Generate labels from split rules
Yweak_train = generate_labels_from_rules(chunksT.text, C.labels, rules_train);
Yweak_eval = generate_labels_from_rules(chunksT.text, C.labels, rules_eval);

% Train classifier on training rules
Yboot_train = Yweak_train >= 0.5;
fprintf('Training multi-label classifier (%d-fold CV)...\n', C.kfold);
models = reg.train_multilabel(features, Yboot_train, C.kfold);

% Generate predictions
[scores, ~, predictions] = reg.predict_multilabel(models, features, Yboot_train);

% Evaluate on eval rules (zero-budget validation)
Yboot_eval = Yweak_eval >= 0.5;

tp = sum(predictions & Yboot_eval, 'all');
fp = sum(predictions & ~Yboot_eval, 'all');
fn = sum(~predictions & Yboot_eval, 'all');

precision_zerobud = tp / max(1, tp + fp);
recall_zerobud = tp / max(1, tp + fn);
f1_zerobud = 2 * precision_zerobud * recall_zerobud / max(1e-9, precision_zerobud + recall_zerobud);

fprintf('\nZero-Budget Validation Results (split-rule):\n');
fprintf('  Precision: %.3f\n', precision_zerobud);
fprintf('  Recall:    %.3f\n', recall_zerobud);
fprintf('  F1:        %.3f\n\n', f1_zerobud);

%% Phase 2: Active Learning Chunk Selection

fprintf('PHASE 2: ACTIVE LEARNING CHUNK SELECTION\n');
fprintf('----------------------------------------------------------\n');

% Select chunks for annotation using active learning
[selected_idx, selection_info] = reg.select_chunks_active_learning(...
    chunksT, scores, Yweak_train, Yweak_eval, ANNOTATION_BUDGET, C.labels, ...
    'Strategy', 'adaptive', ...
    'DiversityWeight', 0.4, ...
    'UncertaintyMetric', 'combined', ...
    'Verbose', true);

% Create annotation dataset
annotation_set = chunksT(selected_idx, :);
annotation_set.chunk_id = selected_idx;
annotation_set.uncertainty_score = selection_info.uncertainty_scores(selected_idx);

% Sort by uncertainty (annotate highest uncertainty first)
[~, priority_order] = sort(annotation_set.uncertainty_score, 'descend');
annotation_set = annotation_set(priority_order, :);

% Export for annotation
output_file = 'chunks_to_annotate.csv';
writetable(annotation_set, output_file);

fprintf('Annotation file created: %s\n', output_file);
fprintf('Chunks to annotate: %d\n', height(annotation_set));
fprintf('\nNext steps:\n');
fprintf('  1. Open chunks_to_annotate.csv in annotation tool\n');
fprintf('  2. For each chunk, assign binary labels (0/1) for all 14 topics\n');
fprintf('  3. Save annotated file as chunks_annotated.csv\n');
fprintf('  4. Run Phase 3 (below) after annotation complete\n\n');

%% Phase 3: Evaluation on Annotated Set
% NOTE: This phase requires manual annotation. If you have annotated data,
% uncomment and run the code below.

% fprintf('PHASE 3: EVALUATION ON ANNOTATED SET\n');
% fprintf('----------------------------------------------------------\n');
%
% % Load annotated data
% if ~exist('chunks_annotated.csv', 'file')
%     warning('Annotated file not found. Please complete annotation first.');
%     return;
% end
%
% annotated_data = readtable('chunks_annotated.csv');
%
% % Extract ground truth labels (assuming columns named as C.labels)
% Ytrue = zeros(height(annotated_data), numel(C.labels));
% for j = 1:numel(C.labels)
%     if ismember(C.labels(j), annotated_data.Properties.VariableNames)
%         Ytrue(:, j) = annotated_data.(C.labels(j));
%     else
%         warning('Label %s not found in annotated data', C.labels(j));
%     end
% end
%
% % Get original chunk IDs (restore original order)
% chunk_ids = annotated_data.chunk_id;
%
% % Get predictions for annotated chunks
% scores_annotated = scores(chunk_ids, :);
% pred_annotated = predictions(chunk_ids, :);
%
% % Compute metrics on GROUND TRUTH
% tp = sum(pred_annotated & Ytrue, 'all');
% fp = sum(pred_annotated & ~Ytrue, 'all');
% fn = sum(~pred_annotated & Ytrue, 'all');
%
% precision_hybrid = tp / max(1, tp + fp);
% recall_hybrid = tp / max(1, tp + fn);
% f1_hybrid = 2 * precision_hybrid * recall_hybrid / max(1e-9, precision_hybrid + recall_hybrid);
%
% fprintf('\nHybrid Validation Results (ground truth on %d chunks):\n', height(annotated_data));
% fprintf('  Precision: %.3f\n', precision_hybrid);
% fprintf('  Recall:    %.3f\n', recall_hybrid);
% fprintf('  F1:        %.3f\n\n', f1_hybrid);
%
% % Per-label metrics
% fprintf('Per-Label F1 Scores:\n');
% f1_per_label = zeros(numel(C.labels), 1);
% for j = 1:numel(C.labels)
%     tp_j = sum(pred_annotated(:,j) & Ytrue(:,j));
%     fp_j = sum(pred_annotated(:,j) & ~Ytrue(:,j));
%     fn_j = sum(~pred_annotated(:,j) & Ytrue(:,j));
%
%     prec_j = tp_j / max(1, tp_j + fp_j);
%     rec_j = tp_j / max(1, tp_j + fn_j);
%     f1_per_label(j) = 2 * prec_j * rec_j / max(1e-9, prec_j + rec_j);
%
%     fprintf('  %-25s: %.3f\n', C.labels(j), f1_per_label(j));
% end
%
% % Bootstrap confidence intervals
% fprintf('\nComputing bootstrap confidence intervals...\n');
% metric_fn = @(idx) compute_f1_on_subset(pred_annotated(idx,:), Ytrue(idx,:));
% [ci_low, ci_high] = reg.bootstrap_ci(metric_fn, (1:height(annotated_data))', ...
%     'NumBootstrap', 5000, 'Alpha', 0.05, 'Verbose', true);
%
% fprintf('\nF1 Score: %.3f [%.3f, %.3f] (95%% CI)\n', f1_hybrid, ci_low, ci_high);
%
% % Compare to zero-budget baseline
% fprintf('\n==========================================================\n');
% fprintf('COMPARISON: ZERO-BUDGET vs. HYBRID\n');
% fprintf('==========================================================\n');
% fprintf('Zero-Budget F1:  %.3f (split-rule validation)\n', f1_zerobud);
% fprintf('Hybrid F1:       %.3f [%.3f, %.3f] (ground truth)\n', f1_hybrid, ci_low, ci_high);
% fprintf('Improvement:     %.1f%%\n', ((f1_hybrid - f1_zerobud) / f1_zerobud) * 100);
% fprintf('Annotation Cost: $%.0f (%d chunks)\n', (ANNOTATION_BUDGET * 10 / 60) * 200, ANNOTATION_BUDGET);
% fprintf('==========================================================\n');
%
% % Statistical significance test
% fprintf('\nStatistical Significance Test:\n');
% % Note: For proper significance testing, need multiple runs or cross-validation
% fprintf('  (For full significance testing, use reg.significance_test with multiple CV folds)\n\n');
%
% % Save results
% results = struct();
% results.zerobud.precision = precision_zerobud;
% results.zerobud.recall = recall_zerobud;
% results.zerobud.f1 = f1_zerobud;
% results.hybrid.precision = precision_hybrid;
% results.hybrid.recall = recall_hybrid;
% results.hybrid.f1 = f1_hybrid;
% results.hybrid.ci_low = ci_low;
% results.hybrid.ci_high = ci_high;
% results.hybrid.annotated_chunks = ANNOTATION_BUDGET;
% results.per_label_f1 = f1_per_label;
%
% save('hybrid_validation_results.mat', 'results');
% fprintf('Results saved to: hybrid_validation_results.mat\n\n');

%% Phase 4: Semi-Supervised Learning (Optional)
% Use annotated chunks to improve weak labels via semi-supervised learning

% fprintf('PHASE 4: SEMI-SUPERVISED LEARNING\n');
% fprintf('----------------------------------------------------------\n');
%
% % Create semi-supervised labels
% Ysemi = Yboot_train;  % Start with weak labels
% Ysemi(chunk_ids, :) = Ytrue;  % Override with ground truth for annotated chunks
%
% fprintf('Training semi-supervised model...\n');
% fprintf('  Weak labels: %d chunks\n', height(chunksT) - ANNOTATION_BUDGET);
% fprintf('  Ground truth: %d chunks\n', ANNOTATION_BUDGET);
%
% % Retrain with semi-supervised labels
% models_semi = reg.train_multilabel(features, Ysemi, C.kfold);
%
% % Evaluate
% [scores_semi, ~, pred_semi] = reg.predict_multilabel(models_semi, features, Ysemi);
%
% % Evaluate on held-out annotated set (use cross-validation for proper eval)
% pred_semi_annotated = pred_semi(chunk_ids, :);
%
% tp_semi = sum(pred_semi_annotated & Ytrue, 'all');
% fp_semi = sum(pred_semi_annotated & ~Ytrue, 'all');
% fn_semi = sum(~pred_semi_annotated & Ytrue, 'all');
%
% precision_semi = tp_semi / max(1, tp_semi + fp_semi);
% recall_semi = tp_semi / max(1, tp_semi + fn_semi);
% f1_semi = 2 * precision_semi * recall_semi / max(1e-9, precision_semi + recall_semi);
%
% fprintf('\nSemi-Supervised Results:\n');
% fprintf('  Precision: %.3f\n', precision_semi);
% fprintf('  Recall:    %.3f\n', recall_semi);
% fprintf('  F1:        %.3f\n', f1_semi);
% fprintf('  Improvement over weak-only: %.1f%%\n', ((f1_semi - f1_hybrid) / f1_hybrid) * 100);
% fprintf('\n');

%% Summary

fprintf('\n==========================================================\n');
fprintf('WORKFLOW COMPLETE\n');
fprintf('==========================================================\n');
fprintf('Phase 1: Zero-budget validation completed\n');
fprintf('Phase 2: Active learning selection completed\n');
fprintf('Phase 3: Awaiting annotation (see chunks_to_annotate.csv)\n');
fprintf('Phase 4: Semi-supervised learning (after annotation)\n');
fprintf('\n');
fprintf('Annotation Instructions:\n');
fprintf('  1. Open annotation tool (Label Studio, Prodigy, or Excel)\n');
fprintf('  2. Load chunks_to_annotate.csv\n');
fprintf('  3. For each chunk, mark relevant labels (binary 0/1)\n');
fprintf('  4. Save as chunks_annotated.csv with label columns:\n');
for j = 1:numel(C.labels)
    fprintf('     - %s\n', C.labels(j));
end
fprintf('  5. Uncomment Phase 3 code above and re-run\n');
fprintf('\n');
fprintf('Estimated annotation time: %.1f hours\n', (ANNOTATION_BUDGET * 10) / 60);
fprintf('Estimated cost (expert): $%.0f\n', (ANNOTATION_BUDGET * 10 / 60) * 200);
fprintf('==========================================================\n');

%% Helper Functions

function Yweak = generate_labels_from_rules(texts, labels, rules)
    % Generate weak labels from keyword rules
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

        Yweak(:,j) = hit * 0.9;  % Fixed confidence
    end
end

function f1 = compute_f1_on_subset(predictions, ground_truth)
    % Compute F1 on a subset (for bootstrap)
    tp = sum(predictions & ground_truth, 'all');
    fp = sum(predictions & ~ground_truth, 'all');
    fn = sum(~predictions & ground_truth, 'all');

    prec = tp / max(1, tp + fp);
    rec = tp / max(1, tp + fn);
    f1 = 2 * prec * rec / max(1e-9, prec + rec);
end
