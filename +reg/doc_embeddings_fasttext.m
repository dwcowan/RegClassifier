function E = doc_embeddings_fasttext(textStr, fasttextCfg)
%DOC_EMBEDDINGS_FASTTEXT Mean-pooled fastText vectors (normalized)
% The fastTextWordEmbedding API changed across MATLAB releases. In some
% versions the language is specified as an input argument, while in others
% the function does not accept any inputs and defaults to English. Handle
% both cases by attempting to pass the language and falling back to the
% zero-argument form when the former results in a "TooManyInputs" error.

if nargin < 2
    fasttextCfg = struct();
end

lang = '';
if isstruct(fasttextCfg) && isfield(fasttextCfg, 'language')
    lang = fasttextCfg.language;
end

try
    if ~isempty(lang)
        emb = fastTextWordEmbedding(lang);
    else
        emb = fastTextWordEmbedding();
    end
catch ME
    if strcmp(ME.identifier, "MATLAB:TooManyInputs")
        emb = fastTextWordEmbedding();
    else
        rethrow(ME);
    end
end

% The "tokens" function for tokenizedDocument objects is not available in
% all MATLAB releases. To maintain compatibility, perform a simple
% whitespace-based tokenization that works across versions. Trim leading
% and trailing spaces before splitting to avoid empty tokens at the ends of
% the array.
textStr = string(textStr);

% Handle API differences between MATLAB versions
% Older versions: emb.WordVectors (matrix property)
% Newer versions: emb.Dimension (scalar property)
try
    d = emb.Dimension;
catch
    d = size(emb.WordVectors, 2);
end

E = zeros(numel(textStr), d, 'single');
for i = 1:numel(textStr)
    t = split(strtrim(regexprep(lower(textStr(i)), '\s+', ' ')));
    t(t=="") = [];
    V = word2vec(emb, t);
    V = single(V);
    V(all(isnan(V),2),:) = [];
    if isempty(V), continue; end
    E(i,:) = mean(V, 1, 'omitnan');
end
n = vecnorm(E,2,2);
n(n==0) = 1;
E = E ./ n;
end
