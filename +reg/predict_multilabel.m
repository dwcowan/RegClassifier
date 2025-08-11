function [scores, thresholds, pred] = predict_multilabel(models, X, Yboot)
%PREDICT_MULTILABEL Calibrated probabilities from CV; pick per-label thresholds
K = numel(models); N = size(X,1);
scores = zeros(N,K);
parfor j = 1:K
    M = models{j};
    if isempty(M), continue; end
    [~, s] = kfoldPredict(M);
    scores(:,j) = s(:,2);
end

thresholds = 0.5 * ones(1,K);
for j = 1:K
    y = logical(Yboot(:,j));
    if nnz(y)<3, thresholds(j)=0.5; continue; end
    ths = linspace(0.2,0.9,11);
    bestF1 = 0; bestTh = 0.5;
    for t = ths
        yhat = scores(:,j) >= t;
        p = sum(yhat & y) / max(1,sum(yhat));
        r = sum(yhat & y) / max(1,sum(y));
        F1 = 2*p*r / max(1e-9,(p+r));
        if F1 > bestF1, bestF1 = F1; bestTh = t; end
    end
    thresholds(j) = bestTh;
end
pred = scores >= thresholds;
end
