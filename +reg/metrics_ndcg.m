function ndcg = metrics_ndcg(scores, posSets, K)
%METRICS_NDCG Compute mean nDCG@K given cosine scores and positive sets.
% scores: N x N similarity (diagonal is self)
% posSets: cell N x 1, each contains indices of relevant items for row i
% K: cutoff
N = size(scores,1);

% Precompute discount factors (vectorized instead of per-element loop)
discounts = 1 ./ log2((1:K) + 1);

ndcg_i = zeros(N,1);
for i = 1:N
    pos = posSets{i};
    if isempty(pos), continue; end
    s = scores(i,:);
    s(i) = -inf;                 % remove self
    [~, ord] = sort(s, 'descend');
    topK = min(K, numel(ord));
    ord = ord(1:topK);
    rel = ismember(ord, pos);
    % DCG (vectorized)
    dcg = sum(rel .* discounts(1:topK));
    % IDCG (ideal: all positives ranked first)
    idealK = min(topK, numel(pos));
    idcg = sum(discounts(1:idealK));
    if idcg > 0
        ndcg_i(i) = dcg / idcg;
    end
end
% Exclude queries with no positives from mean (standard IR practice)
hasPos = cellfun(@(p) ~isempty(p), posSets);
if any(hasPos)
    ndcg = mean(ndcg_i(hasPos));
else
    ndcg = 0;
end
end
