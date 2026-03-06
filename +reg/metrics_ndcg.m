function ndcg = metrics_ndcg(scores, posSets, K)
%METRICS_NDCG Compute mean nDCG@K given similarity scores and positive sets.
% scores: N x N similarity matrix, OR N x D embedding matrix.
%         When N ~= D (non-square), similarity is computed row-by-row
%         to avoid materializing a full N x N matrix.
% posSets: cell N x 1, each contains indices of relevant items for row i
% K: cutoff
N = size(scores,1);
isEmbedding = size(scores,2) ~= N;

% Precompute discount factors (vectorized instead of per-element loop)
discounts = 1 ./ log2((1:K) + 1);

% If embeddings, L2-normalize rows for cosine similarity via dot product
if isEmbedding
    nrm = vecnorm(scores, 2, 2);
    nrm(nrm == 0) = 1;
    scores = scores ./ nrm;
end

ndcg_i = zeros(N,1);
for i = 1:N
    pos = posSets{i};
    if isempty(pos), continue; end
    if isEmbedding
        s = (scores(i,:) * scores')';  % 1 x N row-by-row dot product
    else
        s = scores(i,:);
    end
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
