function [recallAtK, mAP] = eval_retrieval(E, posSets, K)
%EVAL_RETRIEVAL Simple retrieval metrics using cosine similarity
% E: Nxd projected embeddings (L2-normalized)
% posSets: cell N x 1, each contains vector of positive indices for that anchor
% K: cutoff (e.g., 10)
N = size(E,1);

% Compute similarities row-by-row to avoid O(N²) memory.
% For N>5000, the full N×N matrix can exceed available RAM.
recallK = zeros(N,1);
AP = zeros(N,1);
for i = 1:N
    pos = posSets{i};
    if isempty(pos), continue; end

    % Compute similarities for this query only (1×N instead of N×N)
    sim_i = E(i,:) * E';
    sim_i(i) = -inf;  % remove self

    [~, ord] = sort(sim_i, 'descend');

    % Handle edge case: ord is empty or too small
    if isempty(ord)
        recallK(i) = 0;
        AP(i) = 0;
        continue;
    end

    topK = ord(1:min(K, numel(ord)));
    recallK(i) = sum(ismember(topK, pos)) / numel(pos);
    % AP
    hits = ismember(ord, pos);
    cumHits = cumsum(hits);
    ranks = find(hits);
    if isempty(ranks)
        AP(i) = 0;
    else
        ranks = ranks(:);
        cumHitsAtRanks = cumHits(ranks);
        cumHitsAtRanks = cumHitsAtRanks(:);
        precAtHits = cumHitsAtRanks ./ ranks;
        AP(i) = mean(precAtHits);
    end
end
% Exclude queries with no positives from means (standard IR practice)
hasPos = cellfun(@(p) ~isempty(p), posSets);
if any(hasPos)
    recallAtK = mean(recallK(hasPos));
    mAP = mean(AP(hasPos));
else
    recallAtK = 0;
    mAP = 0;
end
end
