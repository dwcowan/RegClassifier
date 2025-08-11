function [docsTok, vocab, Xtfidf] = ta_features(textStr)
%TA_FEATURES Tokenize/clean; build TF-IDF
textStr = string(textStr);
docsTok = tokenizedDocument(textStr);
docsTok = lower(docsTok);
docsTok = erasePunctuation(docsTok);
docsTok = removeStopWords(docsTok);
docsTok = normalizeWords(docsTok,'Style','lemma');
docsTok = removeShortWords(docsTok,3);

bag = bagOfWords(docsTok);
bag = removeInfrequentWords(bag, 1);
bag = removeEmptyDocuments(bag);
X = bag.Counts;                  % docs×terms
idf = log( size(X,1) ./ max(1,sum(X>0,1)) );
Xtfidf = X .* idf;
vocab = bag.Vocabulary;
end
