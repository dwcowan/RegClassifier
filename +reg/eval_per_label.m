function [T, recall] = eval_per_label(E, Ylogical, K)
%EVAL_PER_LABEL Per-label Recall@K using cosine similarity.
%   T = EVAL_PER_LABEL(E, Ylogical, K) computes recall for each label and
%   returns a table with columns:
%       * LabelIdx  – numeric label index (1..L)
%       * RecallAtK – per-label recall@K
%       * Support   – number of query examples considered for that label
%   [T, RECALL] = EVAL_PER_LABEL(...) also returns the raw recall vector.
if nargin<3, K=10; end
N = size(E,1); L = size(Ylogical,2);
E = E ./ vecnorm(E, 2, 2); % normalize each row for cosine similarity
S = E * E.'; % cosine similarity matrix
rec = zeros(L,1); denom = zeros(L,1);
for i = 1:N
    labs = find(Ylogical(i,:));
    if isempty(labs), continue; end
    s = S(i,:); s(i) = -inf;
    [~, ord] = sort(s,'descend');
    ord = ord(1:min(K,end));
    for l = labs
        denom(l) = denom(l) + 1;
        rel = find(Ylogical(:,l));
        rel(rel==i) = [];
        if any(ismember(ord, rel)), rec(l) = rec(l) + 1; end
    end
end
recall = zeros(L,1);
for l=1:L
    if denom(l)>0, recall(l) = rec(l)/denom(l); else, recall(l)=NaN; end
end
T = table((1:L).', recall, denom, ...
    'VariableNames', {'LabelIdx','RecallAtK','Support'});
end
