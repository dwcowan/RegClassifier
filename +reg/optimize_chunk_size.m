function [optimal_config, results] = optimize_chunk_size(texts, labels, varargin)
%OPTIMIZE_CHUNK_SIZE Empirically determine optimal chunk size and overlap.
%   [optimal_config, results] = OPTIMIZE_CHUNK_SIZE(texts, labels) tests
%   multiple chunk size configurations and measures performance.
%
%   This addresses the arbitrary choice of chunk_size=300, overlap=80 in knobs.json
%   by empirically finding optimal values based on actual data.
%
%   INPUTS:
%       texts  - Cell array of document texts
%       labels - Label names (for evaluation)
%
%   NAME-VALUE ARGUMENTS:
%       'SizeRange'     - Chunk sizes to test (default: [150, 200, 250, 300, 350, 400, 500])
%       'OverlapRange'  - Overlap amounts to test (default: [0, 40, 60, 80, 100, 120])
%       'Metric'        - Evaluation metric: 'f1', 'recall', 'retrieval' (default: 'f1')
%       'SampleSize'    - Number of texts to use (default: min(100, numel(texts)))
%       'Verbose'       - Display progress (default: true)
%       'PlotResults'   - Generate heatmap visualization (default: true)
%
%   OUTPUTS:
%       optimal_config - Struct with optimal configuration:
%                        .size    - Optimal chunk size
%                        .overlap - Optimal overlap
%                        .score   - Score achieved
%                        .metric  - Metric used
%       results        - Array of structs with all configurations tested:
%                        .size, .overlap, .score, .num_chunks, .avg_chunk_length
%
%   EXAMPLE 1: Basic optimization
%       [optimal, results] = reg.optimize_chunk_size(texts, C.labels);
%       fprintf('Optimal: size=%d, overlap=%d, F1=%.3f\n', ...
%           optimal.size, optimal.overlap, optimal.score);
%
%   EXAMPLE 2: Custom ranges
%       [optimal, results] = reg.optimize_chunk_size(texts, C.labels, ...
%           'SizeRange', [100, 200, 300, 400, 500], ...
%           'OverlapRange', [0, 50, 100]);
%
%   EXAMPLE 3: Optimize for retrieval
%       [optimal, results] = reg.optimize_chunk_size(texts, C.labels, ...
%           'Metric', 'retrieval', 'PlotResults', true);
%
%   EVALUATION METHODS:
%       'f1'        - Zero-budget F1 score (split-rule validation)
%       'recall'    - Recall@10 for retrieval
%       'retrieval' - Mean average precision (mAP)
%
%   TRADE-OFFS:
%       Smaller chunks (150-200):
%       + More precise topic boundaries
%       + Better for retrieval
%       - More chunks to process
%       - Less context per chunk
%
%       Larger chunks (400-500):
%       + More context per chunk
%       + Fewer chunks to process
%       - Less precise boundaries
%       - May mix multiple topics
%
%       Overlap:
%       + Prevents topic splitting at boundaries
%       + Improves coverage
%       - Increases redundancy
%       - More chunks to process
%
%   COMPUTATIONAL COST:
%       Time: O(num_sizes × num_overlaps × sample_size)
%       Typical: 7 sizes × 6 overlaps × 100 samples ≈ 5-10 minutes
%
%   METHODOLOGICAL ISSUE ADDRESSED:
%       Issue #15 (NEW, MEDIUM): Chunk size optimization
%       Original knobs.json: size=300, overlap=80 (arbitrary)
%       This fix: Data-driven optimization
%       Expected: 3-5% improvement from optimal chunking
%
%   SEE ALSO: reg.chunk_text, reg.zero_budget_validation

% Parse arguments
p = inputParser;
addParameter(p, 'SizeRange', [150, 200, 250, 300, 350, 400, 500], @isnumeric);
addParameter(p, 'OverlapRange', [0, 40, 60, 80, 100, 120], @isnumeric);
addParameter(p, 'Metric', 'f1', @(x) ismember(x, {'f1', 'recall', 'retrieval'}));
addParameter(p, 'SampleSize', min(100, numel(texts)), @isnumeric);
addParameter(p, 'Verbose', true, @islogical);
addParameter(p, 'PlotResults', true, @islogical);
parse(p, varargin{:});

sizes = p.Results.SizeRange;
overlaps = p.Results.OverlapRange;
metric = p.Results.Metric;
sample_size = p.Results.SampleSize;
verbose = p.Results.Verbose;
plot_results = p.Results.PlotResults;

% Sample texts if needed
if numel(texts) > sample_size
    sample_idx = randperm(numel(texts), sample_size);
    texts = texts(sample_idx);
end

if verbose
    fprintf('\n=== Chunk Size Optimization ===\n');
    fprintf('Texts: %d\n', numel(texts));
    fprintf('Sizes to test: %s\n', mat2str(sizes));
    fprintf('Overlaps to test: %s\n', mat2str(overlaps));
    fprintf('Metric: %s\n', metric);
    fprintf('\n');
end

% Test all configurations
results = [];
total_configs = numel(sizes) * numel(overlaps);
config_idx = 0;

% Pre-allocate score matrix for heatmap
score_matrix = nan(numel(sizes), numel(overlaps));

for size_idx = 1:numel(sizes)
    size_val = sizes(size_idx);

    for overlap_idx = 1:numel(overlaps)
        overlap_val = overlaps(overlap_idx);

        % Skip invalid configurations
        if overlap_val >= size_val
            continue;
        end

        config_idx = config_idx + 1;

        if verbose
            fprintf('[%2d/%2d] Testing size=%d, overlap=%d... ', ...
                config_idx, total_configs, size_val, overlap_val);
        end

        try
            % Evaluate configuration
            [score, num_chunks, avg_length] = evaluate_chunk_config(...
                texts, labels, size_val, overlap_val, metric);

            % Store results
            result = struct(...
                'size', size_val, ...
                'overlap', overlap_val, ...
                'score', score, ...
                'num_chunks', num_chunks, ...
                'avg_chunk_length', avg_length, ...
                'metric', metric);

            results = [results; result];

            % Store in matrix for heatmap
            score_matrix(size_idx, overlap_idx) = score;

            if verbose
                fprintf('score=%.4f, chunks=%d, avg_len=%.1f\n', ...
                    score, num_chunks, avg_length);
            end

        catch ME
            warning('Config failed: %s', ME.message);
            score_matrix(size_idx, overlap_idx) = nan;
            if verbose
                fprintf('FAILED\n');
            end
        end
    end
end

% Find optimal
[~, best_idx] = max([results.score]);
optimal_config = results(best_idx);

if verbose
    fprintf('\n=== Optimal Configuration ===\n');
    fprintf('Size:    %d tokens\n', optimal_config.size);
    fprintf('Overlap: %d tokens\n', optimal_config.overlap);
    fprintf('Score:   %.4f (%s)\n', optimal_config.score, metric);
    fprintf('Chunks:  %d (avg)\n', optimal_config.num_chunks);
    fprintf('Length:  %.1f tokens (avg)\n', optimal_config.avg_chunk_length);

    % Compare to default (300, 80)
    default_idx = find([results.size] == 300 & [results.overlap] == 80, 1);
    if ~isempty(default_idx)
        improvement = 100 * (optimal_config.score - results(default_idx).score) / results(default_idx).score;
        fprintf('\nImprovement over default (300, 80): %.1f%%\n', improvement);
    end
end

% Visualization
if plot_results
    figure('Position', [100, 100, 1000, 600]);

    % Heatmap
    subplot(1,2,1);
    imagesc(overlaps, sizes, score_matrix);
    colorbar;
    xlabel('Overlap (tokens)');
    ylabel('Chunk Size (tokens)');
    title(sprintf('Chunk Configuration Performance (%s)', upper(metric)));
    set(gca, 'YDir', 'normal');
    colormap('hot');

    % Mark optimal
    [opt_size_idx, opt_overlap_idx] = find(score_matrix == optimal_config.score, 1);
    hold on;
    plot(overlaps(opt_overlap_idx), sizes(opt_size_idx), 'g*', 'MarkerSize', 20, 'LineWidth', 2);
    hold off;

    % Line plots
    subplot(1,2,2);

    % Plot performance vs. size (for each overlap)
    for overlap_idx = 1:numel(overlaps)
        overlap_val = overlaps(overlap_idx);
        size_scores = score_matrix(:, overlap_idx);

        % Skip if all nan
        if all(isnan(size_scores))
            continue;
        end

        plot(sizes, size_scores, '-o', 'DisplayName', sprintf('overlap=%d', overlap_val));
        hold on;
    end

    xlabel('Chunk Size (tokens)');
    ylabel(sprintf('Score (%s)', upper(metric)));
    title('Performance vs. Chunk Size');
    legend('Location', 'best');
    grid on;
    hold off;

    sgtitle('Chunk Size Optimization Results');
end

end

% =========================================================================
% HELPER: Evaluate Configuration
% =========================================================================
function [score, num_chunks, avg_chunk_length] = evaluate_chunk_config(texts, labels, size_val, overlap_val, metric)
%EVALUATE_CHUNK_CONFIG Evaluate a chunk size configuration.

% Chunk all texts
all_chunks = {};
for i = 1:numel(texts)
    chunks = reg.chunk_text(texts{i}, size_val, overlap_val);
    all_chunks = [all_chunks; chunks];
end

num_chunks = numel(all_chunks);

% Compute average chunk length
chunk_lengths = cellfun(@(x) numel(strsplit(x)), all_chunks);
avg_chunk_length = mean(chunk_lengths);

% Evaluate based on metric
switch metric
    case 'f1'
        % Use zero-budget validation
        score = evaluate_f1(all_chunks, labels);

    case 'recall'
        % Use retrieval recall@10
        score = evaluate_recall(all_chunks, labels);

    case 'retrieval'
        % Use mean average precision
        score = evaluate_map(all_chunks, labels);

    otherwise
        error('Unknown metric: %s', metric);
end

end

% =========================================================================
% EVALUATION FUNCTIONS
% =========================================================================

function f1 = evaluate_f1(chunks, labels)
%EVALUATE_F1 Zero-budget F1 score.

% Generate weak labels (simplified for speed)
try
    % Split rules for validation
    [rules_train, rules_eval] = reg.split_weak_rules_for_validation();

    % Generate labels
    Yweak_train = reg.weak_rules_improved(chunks, labels, ...
        'RuleSet', rules_train, 'Verbose', false);
    Yweak_eval = reg.weak_rules_improved(chunks, labels, ...
        'RuleSet', rules_eval, 'Verbose', false);

    % Simple classifier (for speed, use TF-IDF only)
    [~, ~, X] = reg.ta_features(chunks);

    % Train very simple model
    Y_pred = zeros(size(Yweak_train));
    for j = 1:size(Yweak_train, 2)
        y = Yweak_train(:, j);
        if nnz(y) >= 3
            mdl = fitclinear(X, y, 'Learner', 'logistic', 'ObservationsIn', 'rows');
            [~, scores] = predict(mdl, X);
            Y_pred(:, j) = scores(:, 2) > 0.5;
        end
    end

    % Compute F1 against eval labels
    tp = sum(Y_pred & Yweak_eval, 1);
    fp = sum(Y_pred & ~Yweak_eval, 1);
    fn = sum(~Y_pred & Yweak_eval, 1);

    precision = tp ./ (tp + fp + eps);
    recall = tp ./ (tp + fn + eps);
    f1_per_label = 2 * (precision .* recall) ./ (precision + recall + eps);

    f1 = mean(f1_per_label(~isnan(f1_per_label)));

catch ME
    warning('F1 evaluation failed: %s', ME.message);
    f1 = 0;
end

end

function recall = evaluate_recall(chunks, labels)
%EVALUATE_RECALL Retrieval recall@10.

try
    % Generate embeddings (simplified)
    E = reg.doc_embeddings_bert_gpu(chunks, struct('embeddings_backend', 'bert'));

    % Generate weak labels
    Yweak = reg.weak_rules_improved(chunks, labels, 'Verbose', false);

    % Build positive sets
    posSets = cell(size(E, 1), 1);
    for i = 1:size(E, 1)
        my_labels = find(Yweak(i,:));
        if ~isempty(my_labels)
            % Find chunks with any overlapping labels
            overlap = Yweak * Yweak(i,:)';
            posSets{i} = find(overlap > 0 & (1:size(E,1))' ~= i);
        else
            posSets{i} = [];
        end
    end

    % Compute recall@10
    [recall, ~] = reg.eval_retrieval(E, posSets, 10);

catch ME
    warning('Recall evaluation failed: %s', ME.message);
    recall = 0;
end

end

function map_score = evaluate_map(chunks, labels)
%EVALUATE_MAP Mean average precision.

try
    % Same as recall but return mAP
    E = reg.doc_embeddings_bert_gpu(chunks, struct('embeddings_backend', 'bert'));
    Yweak = reg.weak_rules_improved(chunks, labels, 'Verbose', false);

    posSets = cell(size(E, 1), 1);
    for i = 1:size(E, 1)
        my_labels = find(Yweak(i,:));
        if ~isempty(my_labels)
            overlap = Yweak * Yweak(i,:)';
            posSets{i} = find(overlap > 0 & (1:size(E,1))' ~= i);
        else
            posSets{i} = [];
        end
    end

    [~, map_score] = reg.eval_retrieval(E, posSets, 10);

catch ME
    warning('mAP evaluation failed: %s', ME.message);
    map_score = 0;
end

end
