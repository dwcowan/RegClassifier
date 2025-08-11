function E = doc_embeddings_fasttext(textStr, fasttextCfg)
%DOC_EMBEDDINGS_FASTTEXT Mean-pooled fastText vectors (normalized)
% Handle different fastTextWordEmbedding signatures across MATLAB
% versions. Some releases expect a language argument while others do not.
if isstruct(fasttextCfg) && isfield(fasttextCfg, "language")
    try
        emb = fastTextWordEmbedding(fasttextCfg.language);
    catch
        emb = fastTextWordEmbedding();
    end
else
    emb = fastTextWordEmbedding();
end
tok = tokenizedDocument(string(textStr));
W = doc2sequence(emb, tok);
d = size(emb.WordVectors,2);
E = zeros(numel(W), d, 'single');
for i = 1:numel(W)
    if isempty(W{i}), continue; end
    V = single(W{i});
    E(i,:) = mean(V, 2, 'omitnan');
end
n = vecnorm(E,2,2); n(n==0)=1; E = E ./ n;
end
