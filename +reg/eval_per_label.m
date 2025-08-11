function T = eval_per_label(E, Ylogical, K)
%EVAL_PER_LABEL Per-label Recall@K using cosine similarity
if nargin<3, K=10; end
N = size(E,1); L = size(Ylogical,2);
S = E * E.';
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
T = table((1:L).', recall, 'VariableNames', {'LabelIdx','RecallAtK'});
end
