function S = hybrid_search(Xtfidf, E, vocab, options)
%HYBRID_SEARCH Prepare structures and provide a query function.
%   The returned struct S exposes a query(q, alpha) function. Calling QUERY
%   yields a table with columns:
%       docId (double) - 1-based identifier of the matching document
%       score (double) - blended relevance score
%       rank (double) - 1-based rank position
arguments
    Xtfidf
    E
    vocab
    options.EmbeddingBackend (1,1) string = "fasttext"
end
E = single(E);
E = E ./ max(1e-9, vecnorm(E,2,2));
% Build vocabulary dictionary for O(1) lookup instead of O(V) linear search
vocabMap = containers.Map(cellstr(vocab), num2cell(1:numel(vocab)));
% Precompute IDF once instead of recomputing on every query
idf = log( size(Xtfidf,1) ./ max(1,sum(Xtfidf>0,1)) );
S = struct('Xtfidf', Xtfidf, 'E', E, 'vocab', vocab, ...
    'vocabMap', vocabMap, 'idf', idf, 'embedding_backend', options.EmbeddingBackend);
S.query = @(q, alpha) do_query(q, alpha, S);
end

function out = do_query(q, alpha, S)
if nargin<2, alpha = 0.5; end
qTok = tokenizedDocument(string(q));
qTok = lower(erasePunctuation(removeStopWords(qTok)));

% Create bag and get counts aligned with corpus vocabulary (O(1) lookup via map)
bagQ = bagOfWords(qTok);
qv = zeros(1, numel(S.vocab));
for i = 1:numel(bagQ.Vocabulary)
    word = char(bagQ.Vocabulary(i));
    if isKey(S.vocabMap, word)
        qv(S.vocabMap(word)) = bagQ.Counts(1, i);
    end
end

qtfidf = qv .* S.idf;

% Embed query using the same backend as corpus embeddings
if strcmpi(S.embedding_backend, "bert")
    try
        qe = reg.doc_embeddings_bert_gpu(string(q));
        qe = single(qe);
    catch ME
        warning('RegClassifier:BertQueryFailed', ...
            'BERT query embedding failed: %s. Falling back to FastText.', ME.message);
        qe = fasttext_query_embed(qTok, size(S.E,2));
    end
else
    qe = fasttext_query_embed(qTok, size(S.E,2));
end

% Ensure query embedding matches corpus embedding dimension
if size(qe,2) ~= size(S.E,2)
    warning('RegClassifier:DimensionMismatch', ...
        'Query embedding dim (%d) != corpus embedding dim (%d). Using zero vector.', ...
        size(qe,2), size(S.E,2));
    qe = zeros(1,size(S.E,2),'single');
end
qe = qe ./ max(1e-9, norm(qe));

bm = (S.Xtfidf * qtfidf') ./ max(1e-9, norm(qtfidf));
em = single(S.E * qe');
score = alpha*bm + (1-alpha)*em;
[sv, idx] = maxk(score, 20);
rank = (1:numel(idx))';
out = table(idx, sv, rank, 'VariableNames', {'docId','score','rank'});
end

function qe = fasttext_query_embed(qTok, targetDim)
%FASTTEXT_QUERY_EMBED Embed query tokens using FastText.
try
    emb = fastTextWordEmbedding("en");
catch ME
    if strcmp(ME.identifier, "MATLAB:TooManyInputs")
        emb = fastTextWordEmbedding();
    else
        rethrow(ME);
    end
end
seq = doc2sequence(emb, qTok);
if ~isempty(seq) && ~isempty(seq{1})
    qe = mean(single(seq{1}), 1);
    if size(qe,2) ~= targetDim
        qe = zeros(1, targetDim, 'single');
    end
else
    qe = zeros(1, targetDim, 'single');
end
end
