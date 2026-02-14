function S = eval_clustering_multilabel(E, labelsLogical, varargin)
%EVAL_CLUSTERING_MULTILABEL Multi-label aware clustering evaluation.
%   S = EVAL_CLUSTERING_MULTILABEL(E, labelsLogical) evaluates embedding
%   quality using metrics designed for multi-label data.
%
%   Unlike eval_clustering.m which forces single-label assignment (invalid for
%   multi-label data), this function properly evaluates multi-label embeddings.
%
%   METRICS COMPUTED:
%       1. Label co-occurrence@K     - Jaccard similarity with K nearest neighbors
%       2. Label distribution KL     - KL divergence between local/global distributions
%       3. Multi-label purity        - Per-label purity (micro/macro)
%       4. Neighborhood consistency  - Fraction of neighbors sharing labels
%       5. Label preservation ratio  - How well label structure is preserved
%
%   INPUTS:
%       E              - Embeddings (N x D), L2-normalized
%       labelsLogical  - Binary label matrix (N x L)
%
%   NAME-VALUE ARGUMENTS:
%       'K'            - Neighborhood size (default: 10)
%       'NumClusters'  - Number of clusters for purity (default: auto)
%       'Verbose'      - Display detailed results (default: true)
%       'PlotResults'  - Generate visualization plots (default: false)
%
%   OUTPUTS:
%       S - Struct with metrics:
%           .cooccurrence_at_k          - Label co-occurrence (higher better)
%           .label_dist_kl              - KL divergence (lower better)
%           .multilabel_purity_micro    - Micro-averaged purity
%           .multilabel_purity_macro    - Macro-averaged purity
%           .neighborhood_consistency   - Neighbor label overlap
%           .label_preservation_ratio   - Label structure preservation
%           .per_label_metrics          - Per-label statistics (L x 1 struct)
%           .K                          - Neighborhood size used
%
%   EXAMPLE 1: Evaluate frozen BERT embeddings
%       E_bert = reg.doc_embeddings_bert_gpu(texts, C);
%       S_bert = reg.eval_clustering_multilabel(E_bert, Ylogical);
%
%   EXAMPLE 2: Compare baseline vs. fine-tuned
%       S_baseline = reg.eval_clustering_multilabel(E_baseline, Ylogical, 'Verbose', false);
%       S_finetuned = reg.eval_clustering_multilabel(E_finetuned, Ylogical, 'Verbose', false);
%
%       fprintf('Co-occurrence improvement: %.3f → %.3f (+%.1f%%)\n', ...
%           S_baseline.cooccurrence_at_k, S_finetuned.cooccurrence_at_k, ...
%           100 * (S_finetuned.cooccurrence_at_k - S_baseline.cooccurrence_at_k) / S_baseline.cooccurrence_at_k);
%
%   EXAMPLE 3: Visualize embedding quality
%       S = reg.eval_clustering_multilabel(E, Ylogical, 'PlotResults', true);
%       % Generates plots of label co-occurrence and neighborhood quality
%
%   WHY MULTI-LABEL METRICS MATTER:
%       Standard clustering metrics (purity, silhouette) assume:
%       - Each item belongs to ONE cluster
%       - Exclusive cluster assignments
%
%       Multi-label regulatory documents:
%       - Belong to MULTIPLE topics (e.g., IRB + CreditRisk)
%       - Non-exclusive labels
%       - Standard metrics force invalid single-label assumption
%
%   METRIC INTERPRETATION:
%       1. Co-occurrence@K (0-1, higher better):
%          - 0.8+ : Excellent - neighbors share most labels
%          - 0.6-0.8: Good - neighbors share some labels
%          - <0.6 : Poor - weak label structure preservation
%
%       2. Label distribution KL (0+, lower better):
%          - <0.5 : Excellent - local matches global distribution
%          - 0.5-1.0: Good - some deviation
%          - >1.0 : Poor - high distributional shift
%
%       3. Purity (0-1, higher better):
%          - >0.8 : Excellent - homogeneous neighborhoods
%          - 0.6-0.8: Good - mostly homogeneous
%          - <0.6 : Poor - mixed neighborhoods
%
%   METHODOLOGICAL ISSUE ADDRESSED:
%       Issue #9 (MEDIUM): Clustering evaluation inappropriate for multi-label
%       Original eval_clustering.m:
%       - Forces single-label with max(labelsLogical, [], 2)
%       - Arbitrary tie-breaking
%       - Invalid for multi-label data
%       - Cannot assess if embeddings preserve label co-occurrence
%
%   REFERENCES:
%       Schütze et al. 2008 - "Introduction to Information Retrieval" (Ch 16.3)
%       Tsoumakas et al. 2010 - "Mining Multi-label Data"
%       Madjarov et al. 2012 - "Multi-label learning: extensive experimental comparison"
%
%   SEE ALSO: reg.eval_clustering, reg.eval_retrieval

% Parse arguments
p = inputParser;
addParameter(p, 'K', 10, @(x) isnumeric(x) && x > 0);
addParameter(p, 'NumClusters', [], @(x) isempty(x) || (isnumeric(x) && x > 0));
addParameter(p, 'Verbose', true, @islogical);
addParameter(p, 'PlotResults', false, @islogical);
parse(p, varargin{:});

K = p.Results.K;
num_clusters = p.Results.NumClusters;
verbose = p.Results.Verbose;
plot_results = p.Results.PlotResults;

% Validate inputs
[N, D] = size(E);
[N_labels, L] = size(labelsLogical);

if N ~= N_labels
    error('reg:eval_clustering_multilabel:SizeMismatch', ...
        'E and labelsLogical must have same number of rows');
end

if K >= N
    warning('reg:eval_clustering_multilabel:KTooLarge', ...
        'K=%d >= N=%d, reducing to K=%d', K, N, max(1, N-1));
    K = max(1, N-1);
end

% Convert to logical if needed
if ~islogical(labelsLogical)
    labelsLogical = logical(labelsLogical);
end

% Initialize output
S = struct();
S.K = K;
S.N = N;
S.L = L;

% ===================================================================
% Metric 1: Label Co-Occurrence@K
% ===================================================================
% Measures: Do K nearest neighbors share labels with the query?
% Method: Jaccard similarity = |intersection| / |union|

if verbose
    fprintf('\n=== Multi-Label Clustering Evaluation ===\n');
    fprintf('Computing label co-occurrence@%d...\n', K);
end

% Compute cosine similarity matrix
S_mat = E * E';  % N x N

cooccur = zeros(N, 1);
for i = 1:N
    % Find K nearest neighbors (excluding self)
    [~, neighbors] = sort(S_mat(i,:), 'descend');
    neighbors = neighbors(2:(K+1));  % Exclude self

    my_labels = labelsLogical(i,:);
    neighbor_labels = labelsLogical(neighbors,:);

    % Jaccard: intersection / union
    intersection = sum(my_labels & any(neighbor_labels, 1));
    union = sum(my_labels | any(neighbor_labels, 1));

    if union > 0
        cooccur(i) = intersection / union;
    else
        cooccur(i) = 0;  % No labels at all
    end
end

S.cooccurrence_at_k = mean(cooccur);
S.cooccurrence_per_example = cooccur;

% ===================================================================
% Metric 2: Label Distribution KL Divergence
% ===================================================================
% Measures: How different is local label distribution from global?
% Method: KL( global || local ) for K-neighborhood

if verbose
    fprintf('Computing label distribution KL divergence...\n');
end

global_dist = sum(labelsLogical, 1) / N;  % L x 1
kl_divs = zeros(N, 1);

for i = 1:N
    [~, neighbors] = sort(S_mat(i,:), 'descend');
    neighbors = neighbors(2:(K+1));

    local_dist = sum(labelsLogical(neighbors,:), 1) / K;  % L x 1

    % Add smoothing to avoid log(0)
    local_dist_smooth = local_dist + 1e-9;
    global_dist_smooth = global_dist + 1e-9;

    % KL divergence: sum(p * log(p/q))
    kl_divs(i) = sum(global_dist_smooth .* log(global_dist_smooth ./ local_dist_smooth));
end

S.label_dist_kl = mean(kl_divs);
S.label_dist_kl_per_example = kl_divs;

% ===================================================================
% Metric 3: Multi-Label Purity
% ===================================================================
% Measures: Label homogeneity within clusters
% Method: Per-label purity (not forced single-label)

if verbose
    fprintf('Computing multi-label purity...\n');
end

% Determine number of clusters
if isempty(num_clusters)
    num_clusters = max(2, round(sqrt(N/10)));
end

% Run k-means for cluster assignments (only for purity, not main metric)
try
    [idx, ~] = kmeans(E, num_clusters, 'Distance', 'cosine', ...
        'MaxIter', 100, 'Replicates', 3);
catch ME
    warning('reg:eval_clustering_multilabel:KMeansFailed', ...
        'k-means failed: %s. Using random clustering.', ME.message);
    idx = randi([1, num_clusters], N, 1);
end

% Compute per-label purity
label_purities = zeros(L, 1);
label_support = sum(labelsLogical, 1)';  % Support for each label

for label = 1:L
    label_purity = 0;

    for cluster = 1:num_clusters
        cluster_members = find(idx == cluster);
        if isempty(cluster_members), continue; end

        % Fraction of cluster with this label
        frac = sum(labelsLogical(cluster_members, label)) / numel(cluster_members);

        % Purity contribution: max(frac, 1-frac) × cluster_size
        label_purity = label_purity + numel(cluster_members) * max(frac, 1-frac);
    end

    label_purities(label) = label_purity / N;
end

S.multilabel_purity_macro = mean(label_purities);
S.multilabel_purity_micro = sum(label_purities .* label_support) / sum(label_support);
S.per_label_purity = label_purities;

% ===================================================================
% Metric 4: Neighborhood Consistency
% ===================================================================
% Measures: What fraction of neighbors share at least one label?

if verbose
    fprintf('Computing neighborhood consistency...\n');
end

consistency = zeros(N, 1);
for i = 1:N
    [~, neighbors] = sort(S_mat(i,:), 'descend');
    neighbors = neighbors(2:(K+1));

    my_labels = labelsLogical(i,:);

    % How many neighbors share at least one label?
    neighbor_has_overlap = any(labelsLogical(neighbors,:) & my_labels, 2);
    consistency(i) = mean(neighbor_has_overlap);
end

S.neighborhood_consistency = mean(consistency);
S.neighborhood_consistency_per_example = consistency;

% ===================================================================
% Metric 5: Label Preservation Ratio
% ===================================================================
% Measures: Correlation between label similarity and embedding similarity

if verbose
    fprintf('Computing label preservation ratio...\n');
end

% Compute label similarity matrix (Jaccard)
label_sim = zeros(N, N);
for i = 1:N
    for j = (i+1):N
        intersection = sum(labelsLogical(i,:) & labelsLogical(j,:));
        union = sum(labelsLogical(i,:) | labelsLogical(j,:));

        if union > 0
            label_sim(i,j) = intersection / union;
            label_sim(j,i) = label_sim(i,j);
        end
    end
end

% Flatten upper triangle (exclude diagonal)
idx_upper = triu(true(N,N), 1);
label_sim_vec = label_sim(idx_upper);
embed_sim_vec = S_mat(idx_upper);

% Compute correlation
S.label_preservation_corr = corr(label_sim_vec, embed_sim_vec);

% Preservation ratio: how well does embedding preserve label relationships?
% Use rank correlation (Spearman) for robustness
S.label_preservation_ratio = corr(label_sim_vec, embed_sim_vec, 'Type', 'Spearman');

% ===================================================================
% Per-Label Metrics
% ===================================================================

if verbose
    fprintf('Computing per-label statistics...\n');
end

per_label_metrics = struct();
for label = 1:L
    % Examples with this label
    has_label = labelsLogical(:, label);
    num_with_label = nnz(has_label);

    if num_with_label == 0
        continue;
    end

    % For each example with this label, check if neighbors also have it
    neighbor_has_label = zeros(num_with_label, 1);
    idx_with_label = find(has_label);

    for i_local = 1:num_with_label
        i = idx_with_label(i_local);

        [~, neighbors] = sort(S_mat(i,:), 'descend');
        neighbors = neighbors(2:(K+1));

        % Fraction of neighbors with same label
        neighbor_has_label(i_local) = mean(labelsLogical(neighbors, label));
    end

    per_label_metrics(label).label_id = label;
    per_label_metrics(label).support = num_with_label;
    per_label_metrics(label).avg_neighbor_overlap = mean(neighbor_has_label);
    per_label_metrics(label).purity = label_purities(label);
end

S.per_label_metrics = per_label_metrics;

% ===================================================================
% Display Results
% ===================================================================

if verbose
    fprintf('\n=== Results ===\n');
    fprintf('Neighborhood size (K): %d\n', K);
    fprintf('\n');

    fprintf('Label Co-Occurrence@%d:      %.3f ', K, S.cooccurrence_at_k);
    if S.cooccurrence_at_k >= 0.8
        fprintf('(Excellent)\n');
    elseif S.cooccurrence_at_k >= 0.6
        fprintf('(Good)\n');
    else
        fprintf('(Poor)\n');
    end

    fprintf('Label Distribution KL:        %.3f ', S.label_dist_kl);
    if S.label_dist_kl < 0.5
        fprintf('(Excellent)\n');
    elseif S.label_dist_kl < 1.0
        fprintf('(Good)\n');
    else
        fprintf('(Poor)\n');
    end

    fprintf('Multi-Label Purity (micro):   %.3f\n', S.multilabel_purity_micro);
    fprintf('Multi-Label Purity (macro):   %.3f\n', S.multilabel_purity_macro);

    fprintf('Neighborhood Consistency:     %.3f\n', S.neighborhood_consistency);

    fprintf('Label Preservation (Pearson): %.3f\n', S.label_preservation_corr);
    fprintf('Label Preservation (Spearman):%.3f\n', S.label_preservation_ratio);

    fprintf('\n');
    fprintf('Overall Assessment: ');
    score = (S.cooccurrence_at_k + S.neighborhood_consistency + ...
             S.multilabel_purity_macro + (1 - min(S.label_dist_kl, 1))) / 4;
    if score >= 0.8
        fprintf('EXCELLENT (%.2f)\n', score);
    elseif score >= 0.65
        fprintf('GOOD (%.2f)\n', score);
    elseif score >= 0.5
        fprintf('ACCEPTABLE (%.2f)\n', score);
    else
        fprintf('POOR (%.2f)\n', score);
    end
end

% ===================================================================
% Optional Plotting
% ===================================================================

if plot_results
    figure('Position', [100, 100, 1200, 800]);

    % Plot 1: Co-occurrence distribution
    subplot(2,3,1);
    histogram(S.cooccurrence_per_example, 20);
    xlabel('Label Co-Occurrence@K');
    ylabel('Frequency');
    title(sprintf('Co-Occurrence Distribution (mean=%.3f)', S.cooccurrence_at_k));
    grid on;

    % Plot 2: KL divergence distribution
    subplot(2,3,2);
    histogram(S.label_dist_kl_per_example, 20);
    xlabel('KL Divergence');
    ylabel('Frequency');
    title(sprintf('Label Distribution KL (mean=%.3f)', S.label_dist_kl));
    grid on;

    % Plot 3: Neighborhood consistency
    subplot(2,3,3);
    histogram(S.neighborhood_consistency_per_example, 20);
    xlabel('Neighborhood Consistency');
    ylabel('Frequency');
    title(sprintf('Neighbor Label Overlap (mean=%.3f)', S.neighborhood_consistency));
    grid on;

    % Plot 4: Per-label purity
    subplot(2,3,4);
    bar(S.per_label_purity);
    xlabel('Label Index');
    ylabel('Purity');
    title('Per-Label Purity');
    grid on;

    % Plot 5: Label vs embedding similarity
    subplot(2,3,5);
    scatter(label_sim_vec, embed_sim_vec, 5, 'filled', 'MarkerFaceAlpha', 0.3);
    xlabel('Label Similarity (Jaccard)');
    ylabel('Embedding Similarity (Cosine)');
    title(sprintf('Label Preservation (r=%.3f)', S.label_preservation_corr));
    grid on;

    % Plot 6: Summary radar chart
    subplot(2,3,6);
    metrics_normalized = [
        S.cooccurrence_at_k;
        1 - min(S.label_dist_kl, 1);  % Invert KL (lower is better)
        S.multilabel_purity_macro;
        S.neighborhood_consistency;
        S.label_preservation_ratio;
    ];
    metric_names = {'Co-occur@K', 'Label Dist', 'Purity', 'Consistency', 'Preservation'};

    bar(metrics_normalized);
    set(gca, 'XTickLabel', metric_names, 'XTickLabelRotation', 45);
    ylabel('Score [0-1]');
    title('Multi-Label Clustering Metrics');
    ylim([0, 1]);
    grid on;

    sgtitle('Multi-Label Embedding Evaluation');
end

end
