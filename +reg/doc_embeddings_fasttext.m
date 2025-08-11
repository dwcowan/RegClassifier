function E = doc_embeddings_fasttext(textStr, fasttextCfg)
%DOC_EMBEDDINGS_FASTTEXT Mean-pooled fastText vectors (normalized)
%   E = doc_embeddings_fasttext(textStr) returns mean-pooled fastText
%   embeddings using the default model. An optional fasttextCfg argument is
%   accepted for backward compatibility but is ignored.
if nargin < 2
    fasttextCfg = struct(); %#ok<NASGU>
end
emb = fastTextWordEmbedding();
tok = tokenizedDocument(string(textStr));
W = doc2sequence(emb, tok);
d = size(emb.WordVectors,2);
E = zeros(numel(W), d, 'single');
for i = 1:numel(W)
    if isempty(W{i}), continue; end
    V = single(W{i});
    E(i,:) = mean(V, 2, 'omitnan')';
end
n = vecnorm(E,2,2); n(n==0)=1; E = E ./ n;
end
