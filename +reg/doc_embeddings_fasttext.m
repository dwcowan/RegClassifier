function E = doc_embeddings_fasttext(textStr, fasttextCfg)
%DOC_EMBEDDINGS_FASTTEXT Mean-pooled fastText vectors (normalized)

% Some MATLAB releases (used in CI) ship a fastTextWordEmbedding that does
% not accept a language argument. Guard the call so the function works on
% both new and old versions.
try
    if nargin >= 2 && isstruct(fasttextCfg) && isfield(fasttextCfg,"language")
        emb = fastTextWordEmbedding(fasttextCfg.language);
    else
        emb = fastTextWordEmbedding();
    end
catch ME
    if strcmp(ME.identifier,'MATLAB:TooManyInputs')
        % Older MATLAB: fall back to default (English) embedding
        emb = fastTextWordEmbedding();
    else
        rethrow(ME);
    end
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
