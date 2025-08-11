function ndcg = metrics_ndcg(scores, posSets, K)
%METRICS_NDCG Compute mean nDCG@K given cosine scores and positive sets.
% scores: N x N similarity (diagonal is self)
% posSets: cell N x 1, each contains indices of relevant items for row i
% K: cutoff
N = size(scores,1);
ndcg_i = zeros(N,1);
for i = 1:N
    pos = posSets{i};
    if isempty(pos), continue; end
    s = scores(i,:);
    s(i) = -inf;                 % remove self
    [~, ord] = sort(s, 'descend');
    ord = ord(1:min(K,end));
    rel = ismember(ord, pos);
    % DCG
    dcg = 0;
    for j = 1:numel(ord)
        dcg = dcg + (rel(j) / log2(j+1));
    end
    % IDCG (ideal: all positives ranked first)
    idealRel = ones(1, min(K, numel(pos)));
    idcg = 0;
    for j = 1:numel(idealRel)
        idcg = idcg + (idealRel(j) / log2(j+1));
    end
    if idcg > 0
        % MATLAB uses 1-based indexing with parentheses. The previous
        % implementation accidentally used square brackets (`ndcg_i[i]`)
        % which is Python-style indexing and results in a syntax error.
        % Use the correct parenthesis-based indexing.
        ndcg_i(i) = dcg / idcg;
    else
        ndcg_i(i) = 0;
    end
end
ndcg = mean(ndcg_i);
end
