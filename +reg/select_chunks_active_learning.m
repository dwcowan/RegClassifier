function [selected_idx, info] = select_chunks_active_learning(chunksT, scores, Yweak_train, Yweak_eval, budget, labels, varargin)
%SELECT_CHUNKS_ACTIVE_LEARNING Select chunks for annotation via active learning.
%   [selected_idx, info] = SELECT_CHUNKS_ACTIVE_LEARNING(chunksT, scores,
%       Yweak_train, Yweak_eval, budget, labels, ...)
%   selects chunks for human annotation using budget-adaptive active learning.
%
%   INPUTS:
%       chunksT      - Table with chunk text and metadata
%       scores       - Prediction scores (N x L) from classifier
%       Yweak_train  - Weak labels from training rules (N x L)
%       Yweak_eval   - Weak labels from eval rules (N x L)
%       budget       - Number of chunks to select for annotation
%       labels       - Label names (L x 1 string array)
%
%   NAME-VALUE ARGUMENTS:
%       'DiversityWeight' - Weight for diversity phase (default: 0.4)
%                          First (diversityWeight * budget) chunks selected
%                          for diversity, rest for uncertainty
%       'Strategy'        - Active learning strategy:
%                          'adaptive' (default) - Mix diversity + uncertainty
%                          'uncertainty' - Pure uncertainty sampling
%                          'diversity' - Pure diversity sampling
%                          'random' - Random baseline
%       'UncertaintyMetric' - Uncertainty measure to use:
%                            'combined' (default) - Weighted combination
%                            'entropy' - Shannon entropy
%                            'disagreement' - Split-rule disagreement
%                            'least_confidence' - Least confidence
%                            'margin' - Margin sampling
%       'Verbose'         - Display detailed progress (default: true)
%
%   OUTPUTS:
%       selected_idx - Indices of selected chunks (budget x 1)
%       info         - Struct with selection statistics:
%                      .diversity_count - Chunks selected for diversity
%                      .uncertainty_count - Chunks selected for uncertainty
%                      .label_distribution - Selected chunks per label
%                      .uncertainty_scores - Uncertainty for all chunks
%
%   ALGORITHM:
%       Based on recent active learning research (2024-2025):
%       - Low budget: Prioritize diversity (cover all labels, document types)
%       - High budget: Mix diversity + uncertainty
%       - Diversity ensures coverage, uncertainty refines boundaries
%
%   EXAMPLE 1: Select 100 chunks with default adaptive strategy
%       [idx, info] = reg.select_chunks_active_learning(chunksT, scores, ...
%           Yweak_train, Yweak_eval, 100, C.labels);
%       annotation_set = chunksT(idx, :);
%       writetable(annotation_set, 'chunks_to_annotate.csv');
%
%   EXAMPLE 2: Pure uncertainty sampling for high-budget scenario
%       [idx, info] = reg.select_chunks_active_learning(chunksT, scores, ...
%           Yweak_train, Yweak_eval, 200, C.labels, 'Strategy', 'uncertainty');
%
%   EXAMPLE 3: Export with uncertainty scores for prioritization
%       [idx, info] = reg.select_chunks_active_learning(...);
%       annotation_set = chunksT(idx, :);
%       annotation_set.uncertainty = info.uncertainty_scores(idx);
%       [~, priority_order] = sort(annotation_set.uncertainty, 'descend');
%       annotation_set = annotation_set(priority_order, :);
%       % Annotate in priority order (highest uncertainty first)
%
%   REFERENCES:
%       Settles 2009 - Active Learning Literature Survey
%       Yang et al. 2024 - Uncertainty Herding (arXiv:2412.20644)
%       Wang et al. 2024 - Enhanced Uncertainty Sampling (PLOS One)
%
%   SEE ALSO: reg.zero_budget_validation, reg.split_weak_rules_for_validation

% Parse arguments
p = inputParser;
addParameter(p, 'DiversityWeight', 0.4, @(x) x >= 0 && x <= 1);
addParameter(p, 'Strategy', 'adaptive', @(x) ismember(x, {'adaptive', 'uncertainty', 'diversity', 'random'}));
addParameter(p, 'UncertaintyMetric', 'combined', @(x) ismember(x, {'combined', 'entropy', 'disagreement', 'least_confidence', 'margin'}));
addParameter(p, 'Verbose', true, @islogical);
parse(p, varargin{:});

diversity_weight = p.Results.DiversityWeight;
strategy = p.Results.Strategy;
uncertainty_metric = p.Results.UncertaintyMetric;
verbose = p.Results.Verbose;

% Validate inputs
N = height(chunksT);
L = numel(labels);

if size(scores, 1) ~= N || size(scores, 2) ~= L
    error('reg:select_chunks_active_learning:SizeMismatch', ...
        'scores must be N x L (N=%d, L=%d)', N, L);
end

if size(Yweak_train, 1) ~= N || size(Yweak_train, 2) ~= L
    error('reg:select_chunks_active_learning:SizeMismatch', ...
        'Yweak_train must be N x L');
end

if size(Yweak_eval, 1) ~= N || size(Yweak_eval, 2) ~= L
    error('reg:select_chunks_active_learning:SizeMismatch', ...
        'Yweak_eval must be N x L');
end

if budget > N
    warning('reg:select_chunks_active_learning:BudgetExceedsData', ...
        'Budget (%d) exceeds number of chunks (%d). Selecting all chunks.', budget, N);
    budget = N;
end

if verbose
    fprintf('\n=== Active Learning Chunk Selection ===\n');
    fprintf('Total chunks:     %d\n', N);
    fprintf('Budget:           %d (%.1f%%)\n', budget, (budget/N)*100);
    fprintf('Strategy:         %s\n', strategy);
    fprintf('Labels:           %d\n', L);
    fprintf('\n');
end

% Initialize
selected_idx = [];
info = struct();

% Strategy-specific selection
switch strategy
    case 'random'
        % Random baseline (no active learning)
        selected_idx = randperm(N, budget)';
        info.diversity_count = 0;
        info.uncertainty_count = 0;

    case 'diversity'
        % Pure diversity: ensure all labels covered
        selected_idx = select_diverse(N, L, budget, Yweak_train, Yweak_eval, labels);
        info.diversity_count = numel(selected_idx);
        info.uncertainty_count = 0;

    case 'uncertainty'
        % Pure uncertainty: select most uncertain chunks
        uncertainty_scores = compute_uncertainty(scores, Yweak_train, Yweak_eval, uncertainty_metric);
        [~, sort_idx] = sort(uncertainty_scores, 'descend');
        selected_idx = sort_idx(1:budget);
        info.diversity_count = 0;
        info.uncertainty_count = budget;

    case 'adaptive'
        % Adaptive: diversity first, then uncertainty
        diversity_budget = floor(diversity_weight * budget);
        uncertainty_budget = budget - diversity_budget;

        if verbose
            fprintf('Phase 1: Diversity selection (%d chunks)\n', diversity_budget);
        end

        % Phase 1: Diversity
        selected_idx = select_diverse(N, L, diversity_budget, Yweak_train, Yweak_eval, labels);

        if verbose
            fprintf('  Selected: %d chunks\n', numel(selected_idx));
            fprintf('\nPhase 2: Uncertainty selection (%d chunks)\n', uncertainty_budget);
        end

        % Phase 2: Uncertainty (excluding already selected)
        uncertainty_scores = compute_uncertainty(scores, Yweak_train, Yweak_eval, uncertainty_metric);

        available = setdiff((1:N)', selected_idx);
        [~, sort_idx] = sort(uncertainty_scores(available), 'descend');

        n_to_select = min(uncertainty_budget, numel(available));
        selected_uncertain = available(sort_idx(1:n_to_select));
        selected_idx = [selected_idx; selected_uncertain];

        info.diversity_count = diversity_budget;
        info.uncertainty_count = numel(selected_uncertain);

        if verbose
            fprintf('  Selected: %d chunks\n', numel(selected_uncertain));
        end
end

% Ensure unique
selected_idx = unique(selected_idx);

% Compute statistics
info.uncertainty_scores = compute_uncertainty(scores, Yweak_train, Yweak_eval, uncertainty_metric);
info.label_distribution = compute_label_distribution(selected_idx, Yweak_train, Yweak_eval, labels);
info.strategy = strategy;
info.budget = budget;
info.total_chunks = N;
info.coverage = numel(selected_idx) / N;

if verbose
    fprintf('\n=== Selection Summary ===\n');
    fprintf('Selected chunks:  %d\n', numel(selected_idx));
    fprintf('Coverage:         %.1f%%\n', info.coverage * 100);
    fprintf('\nLabel distribution in selection:\n');
    for j = 1:numel(labels)
        fprintf('  %-25s: %3d chunks (%.1f%%)\n', labels(j), ...
            info.label_distribution(j), ...
            (info.label_distribution(j) / numel(selected_idx)) * 100);
    end
    fprintf('\n');
end

end

%% Helper Functions

function selected = select_diverse(N, L, budget, Yweak_train, Yweak_eval, labels)
% Select diverse chunks ensuring all labels represented

selected = [];

% Ensure all labels have at least min_per_label chunks
min_per_label = max(1, floor(budget / (L * 2)));  % At least budget/(2*L) per label

for j = 1:L
    % Find chunks with this label in either train or eval rules
    has_label = (Yweak_train(:,j) > 0.5) | (Yweak_eval(:,j) > 0.5);
    candidates = find(has_label);

    if isempty(candidates)
        continue;
    end

    % Sample randomly for diversity
    n_to_select = min(min_per_label, numel(candidates));
    if n_to_select > 0
        sel = candidates(randperm(numel(candidates), n_to_select));
        selected = [selected; sel];
    end
end

selected = unique(selected);

% If we haven't reached budget, add random chunks
if numel(selected) < budget
    remaining = budget - numel(selected);
    available = setdiff((1:N)', selected);
    n_to_add = min(remaining, numel(available));
    if n_to_add > 0
        additional = available(randperm(numel(available), n_to_add));
        selected = [selected; additional];
    end
end

% Trim if over budget
if numel(selected) > budget
    selected = selected(randperm(numel(selected), budget));
end
end

function uncertainty = compute_uncertainty(scores, Yweak_train, Yweak_eval, metric)
% Compute uncertainty scores for all chunks

N = size(scores, 1);
uncertainty = zeros(N, 1);

switch metric
    case 'entropy'
        % Shannon entropy across label predictions
        uncertainty = -sum(scores .* log(scores + 1e-10), 2);

    case 'disagreement'
        % Disagreement between train and eval rule sets
        Yweak_train_bin = Yweak_train > 0.5;
        Yweak_eval_bin = Yweak_eval > 0.5;
        uncertainty = sum(xor(Yweak_train_bin, Yweak_eval_bin), 2);

    case 'least_confidence'
        % 1 - max confidence
        [max_prob, ~] = max(scores, [], 2);
        uncertainty = 1 - max_prob;

    case 'margin'
        % Margin between top 2 predictions
        sorted_scores = sort(scores, 2, 'descend');
        if size(sorted_scores, 2) >= 2
            margin = sorted_scores(:,1) - sorted_scores(:,2);
        else
            margin = sorted_scores(:,1);
        end
        uncertainty = -margin;  % Smaller margin = higher uncertainty

    case 'combined'
        % Weighted combination of multiple metrics
        entropy = -sum(scores .* log(scores + 1e-10), 2);
        disagreement = sum(xor(Yweak_train > 0.5, Yweak_eval > 0.5), 2);
        [max_prob, ~] = max(scores, [], 2);
        least_conf = 1 - max_prob;

        % Normalize to [0,1]
        entropy_norm = normalize_to_01(entropy);
        disagreement_norm = normalize_to_01(disagreement);
        least_conf_norm = normalize_to_01(least_conf);

        % Weighted combination
        uncertainty = 0.4 * entropy_norm + 0.4 * disagreement_norm + 0.2 * least_conf_norm;

    otherwise
        error('Unknown uncertainty metric: %s', metric);
end
end

function x_norm = normalize_to_01(x)
% Min-max normalization to [0,1]
min_x = min(x);
max_x = max(x);
if max_x - min_x < 1e-10
    x_norm = zeros(size(x));
else
    x_norm = (x - min_x) / (max_x - min_x);
end
end

function dist = compute_label_distribution(selected_idx, Yweak_train, Yweak_eval, labels)
% Count how many selected chunks have each label

L = numel(labels);
dist = zeros(L, 1);

for j = 1:L
    % Count chunks with this label in either train or eval rules
    has_label = (Yweak_train(selected_idx, j) > 0.5) | (Yweak_eval(selected_idx, j) > 0.5);
    dist(j) = sum(has_label);
end
end
