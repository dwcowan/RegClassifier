function pdfPath = generate_reg_report(titleStr, chunksT, labels, pred, scores, mdlLDA, vocab)
import mlreportgen.report.*
import mlreportgen.dom.*

r = Report('reg_topics_snapshot','pdf');
append(r, TitlePage('Title', titleStr));
append(r, TableOfContents);

% Coverage
sec = Section('Label Coverage');
% Handle edge cases for empty or mismatched data
if isempty(labels) || numel(labels) == 0
    % No labels defined - skip coverage section
    append(r, sec);
elseif isempty(pred) || size(pred,2) ~= numel(labels)
    % Empty predictions or size mismatch - show zero coverage
    labelsCol = reshape(string(labels), [], 1);  % Force column vector of strings
    covCol = zeros(numel(labels), 1);  % Matching zero coverage column
    tbl = table(labelsCol, covCol, 'VariableNames', {'Label','Coverage'});
    append(sec, FormalTable(tbl));
    append(r, sec);
else
    % Normal case - compute coverage
    cov = mean(pred, 1);  % 1×N row vector
    labelsCol = reshape(string(labels), [], 1);  % N×1 column
    covCol = reshape(cov, [], 1);  % N×1 column
    tbl = table(labelsCol, covCol, 'VariableNames', {'Label','Coverage'});
    append(sec, FormalTable(tbl));
    append(r, sec);
end

% Low-confidence queue (simple heuristic)
sec2 = Section('Low-Confidence Queue');
[~, idx] = sort(max(scores,[],2) - min(scores,[],2), 'ascend');
N = min(10, numel(idx));
for i = 1:N
    snip = extractBetween(chunksT.text(idx(i)), 1, min(strlength(chunksT.text(idx(i))), 240));
    para = Paragraph(sprintf('[%s] %s', chunksT.chunk_id(idx(i)), snip));
    append(sec2, para);
end
append(r, sec2);

% LDA topics
sec3 = Section('LDA Topics');
K = mdlLDA.NumTopics;
for k = 1:K
    [~, topIdx] = maxk(mdlLDA.TopicWordProbabilities(k,:), 10);
    append(sec3, Paragraph(sprintf('Topic %d: %s', k, strjoin(vocab(topIdx), ', '))));
end
append(r, sec3);

pdfPath = r.OutputPath;
close(r);
end
