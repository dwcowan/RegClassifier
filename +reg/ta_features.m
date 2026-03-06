function [docsTok, vocab, Xtfidf] = ta_features(textStr)
%TA_FEATURES Tokenize/clean; build TF-IDF
textStr = string(textStr);

% Handle empty input
if isempty(textStr)
    docsTok = tokenizedDocument(string.empty(0,1));
    vocab = string.empty(0,1);
    Xtfidf = zeros(0,0);
    return;
end

docsTok = tokenizedDocument(textStr);
docsTok = lower(docsTok);
docsTok = erasePunctuation(docsTok);
docsTok = removeStopWords(docsTok);
docsTok = normalizeWords(docsTok,'Style','lemma');
docsTok = removeShortWords(docsTok,3);

bag = bagOfWords(docsTok);
% Only drop infrequent words when at least one term appears twice.
% This prevents removing all vocabulary for small corpora.
counts = full(sum(bag.Counts,1));
if any(counts >= 2)
    bag = removeInfrequentWords(bag, 2);
end
% Note: do NOT call removeEmptyDocuments here, as it changes the
% document count and causes dimension mismatches downstream.
% Use built-in tfidf() from Text Analytics Toolbox (returns sparse matrix
% with proper IDF weighting) instead of hand-computing from Counts.
Xtfidf = tfidf(bag);
vocab = bag.Vocabulary;
end
