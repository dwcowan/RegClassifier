function [recallAtK, mAP] = eval_retrieval(E, posSets, K)
%EVAL_RETRIEVAL Simple retrieval metrics using cosine similarity
% E: Nxd projected embeddings (L2-normalized)
% posSets: cell N x 1, each contains vector of positive indices for that anchor
% K: cutoff (e.g., 10)
N = size(E,1);
scores = E * E';  % cosine
recallK = zeros(N,1);
AP = zeros(N,1);
for i = 1:N
    pos = posSets{i};
    if isempty(pos), continue; end
    [~, ord] = sort(scores(i,:), 'descend');
    ord(ord==i) = []; % remove self

    % Handle edge case: ord is empty or too small after removing self
    if isempty(ord)
        recallK(i) = 0;
        AP(i) = 0;
        continue;
    end

    topK = ord(1:min(K, numel(ord)));
    recallK(i) = any(ismember(topK, pos));
    % AP
    hits = ismember(ord, pos);
    cumHits = cumsum(hits);
    ranks = find(hits);
    if isempty(ranks)
        AP(i) = 0;
    else
        precAtHits = cumHits(ranks) ./ ranks';
        AP(i) = mean(precAtHits);
    end
end
recallAtK = mean(recallK);
mAP = mean(AP);
end
