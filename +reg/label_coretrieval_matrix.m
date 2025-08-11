function [M, order] = label_coretrieval_matrix(E, Ylogical, K)
%LABEL_CORETRIEVAL_MATRIX Compute label co-retrieval (confusion-style) matrix.
% For each query i, retrieve top-K by cosine. For each true label l of i,
% increment (l, l') for labels l' found among retrieved set's labels.
% E: Nxd normalized embeddings; Ylogical: N x L logical; K: top-K
N = size(E,1); L = size(Ylogical,2);
S = E * E.';
M = zeros(L,L);
for i = 1:N
    s = S(i,:); s(i) = -inf;
    [~, ord] = sort(s, 'descend');
    ord = ord(1:min(K,end));
    qi = find(Ylogical(i,:));
    if isempty(qi), continue; end
    labRetrieved = any(Ylogical(ord,:),1);
    for a = qi
        M(a, :) = M(a, :) + labRetrieved;
    end
end
% Normalize rows to percentages
rowSums = sum(M,2); rowSums(rowSums==0) = 1;
M = M ./ rowSums;
order = 1:L;
end
