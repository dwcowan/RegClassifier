function S = hybrid_search(Xtfidf, E, vocab)
%HYBRID_SEARCH Prepare structures and provide a query function
E = single(E);
E = E ./ max(1e-9, vecnorm(E,2,2));
S = struct('Xtfidf', Xtfidf, 'E', E, 'vocab', {vocab});
S.query = @(q, alpha) do_query(q, alpha, S);
end

function out = do_query(q, alpha, S)
if nargin<2, alpha = 0.5; end
qTok = tokenizedDocument(string(q));
qTok = lower(erasePunctuation(removeStopWords(qTok)));
bagQ = bagOfWords(qTok, S.vocab);
qv = bagQ.Counts; idf = log( size(S.Xtfidf,1) ./ max(1,sum(S.Xtfidf>0,1)) );
qtfidf = qv .* idf;

% Some MATLAB releases do not accept a language argument for
% fastTextWordEmbedding. Attempt to request English embeddings, but fall
% back to the default if the call fails.
try
    emb = fastTextWordEmbedding("en");
catch
    emb = fastTextWordEmbedding();
end
seq = doc2sequence(emb, qTok);
if ~isempty(seq) && ~isempty(seq{1}), qe = mean(single(seq{1}),2)'; else, qe = zeros(1,size(S.E,2),'single'); end
qe = qe ./ max(1e-9, norm(qe));

bm = (S.Xtfidf * qtfidf') ./ max(1e-9, norm(qtfidf));
em = single(S.E * qe');
score = alpha*bm + (1-alpha)*em;
[sv, idx] = maxk(score, 20);
out = table(idx, sv, 'VariableNames', {'row','score'});
end
