function [scores, thresholds, pred] = predict_multilabel(models, X, Yboot)
%PREDICT_MULTILABEL Calibrated probabilities from CV; pick per-label thresholds
%   NOTE: Models are cross-validated (ClassificationPartitionedModel). The
%   kfoldPredict call returns out-of-fold predictions on the *training* data.
%   The input X must be the same training data used to build the models;
%   prediction on new/unseen data requires calling predict() on each fold's
%   Trained{k} learner directly.
arguments
    models cell
    X {mustBeNumeric}
    Yboot {mustBeNumericOrLogical}
end

K = numel(models); N = size(X,1);

% Validate dimensions match
if K ~= size(Yboot, 2)
    error('reg:predict_multilabel:DimensionMismatch', ...
        'Number of models (%d) must match number of label columns in Yboot (%d)', ...
        K, size(Yboot, 2));
end
if N ~= size(Yboot, 1)
    error('reg:predict_multilabel:DimensionMismatch', ...
        'Number of samples in X (%d) must match number of rows in Yboot (%d)', ...
        N, size(Yboot, 1));
end
scores = zeros(N,K);
parfor j = 1:K
    M = models{j};
    if isempty(M), continue; end
    if isa(M, 'ClassificationPartitionedModel')
        % Cross-validated model: use out-of-fold predictions on training data
        [~, s] = kfoldPredict(M);
    else
        % Standard model: predict on provided X
        [~, s] = predict(M, X);
    end
    scores(:,j) = s(:,2);
end

thresholds = 0.5 * ones(1,K);
ths = linspace(0.2,0.9,51);
for j = 1:K
    y = logical(Yboot(:,j));
    if nnz(y)<3, continue; end
    % Vectorized: compare scores against all thresholds at once (N×T matrix)
    yhatAll = scores(:,j) >= ths;           % N × 51 logical
    tp = sum(yhatAll & y, 1);               % 1 × 51
    predPos = sum(yhatAll, 1);              % 1 × 51
    actualPos = nnz(y);
    prec = tp ./ max(1, predPos);
    rec  = tp ./ max(1, actualPos);
    F1   = 2 .* prec .* rec ./ max(1e-9, prec + rec);
    [~, bestIdx] = max(F1);
    thresholds(j) = ths(bestIdx);
end
pred = scores >= thresholds;
end
