function E = doc_embeddings_fasttext(textStr, fasttextCfg)
%DOC_EMBEDDINGS_FASTTEXT Mean-pooled fastText vectors (normalized)
% The fastTextWordEmbedding API changed across MATLAB releases.  In some
% versions the language is specified as an input argument, while in others
% the function does not accept any inputs and defaults to English.  Handle
% both cases by attempting to pass the language and falling back to the
% zero-argument form when the former results in a "TooManyInputs" error.

try
    emb = fastTextWordEmbedding(fasttextCfg.language);
catch ME
    if strcmp(ME.identifier, "MATLAB:TooManyInputs")
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
