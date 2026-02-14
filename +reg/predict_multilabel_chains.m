function [scores, thresholds, pred] = predict_multilabel_chains(models, X, Yboot)
%PREDICT_MULTILABEL_CHAINS Predict using classifier chains.
%   [scores, thresholds, pred] = PREDICT_MULTILABEL_CHAINS(models, X, Yboot)
%   predicts multi-label assignments using classifier chains trained by
%   train_multilabel_chains. Uses kfoldPredict for CV models.
%
%   Matches the API of predict_multilabel: returns [scores, thresholds, pred].
%
%   INPUTS:
%       models - Cell array {L x 1} from train_multilabel_chains
%       X      - Feature matrix (N x D)
%       Yboot  - Binary label matrix (N x L) used for chain augmentation
%                and threshold calibration
%
%   OUTPUTS:
%       scores     - Prediction scores [0,1] (N x L)
%       thresholds - Calibrated per-label thresholds (1 x L)
%       pred       - Binary predictions (N x L) logical
%
%   EXAMPLE:
%       models = reg.train_multilabel_chains(X, Yboot, 5);
%       [scores, thresholds, pred] = reg.predict_multilabel_chains(models, X, Yboot);
%
%   SEE ALSO: reg.train_multilabel_chains, reg.predict_multilabel
arguments
    models cell
    X double
    Yboot {mustBeNumericOrLogical}
end

K = numel(models);
N = size(X, 1);

% Validate dimensions
if K ~= size(Yboot, 2)
    error('reg:predict_multilabel_chains:DimensionMismatch', ...
        'Number of models (%d) must match number of label columns in Yboot (%d)', ...
        K, size(Yboot, 2));
end
if N ~= size(Yboot, 1)
    error('reg:predict_multilabel_chains:DimensionMismatch', ...
        'Number of samples in X (%d) must match number of rows in Yboot (%d)', ...
        N, size(Yboot, 1));
end

scores = zeros(N, K);

for j = 1:K
    M = models{j};
    if isempty(M), continue; end

    % Augment features with previous label columns (chain dependency)
    if j == 1
        X_aug = X;
    else
        X_aug = [X, double(Yboot(:, 1:(j-1)))];
    end

    if isa(M, 'ClassificationPartitionedLinear')
        % Cross-validated model: use kfoldPredict
        [~, s] = kfoldPredict(M);
        scores(:, j) = s(:, 2);
    else
        % Regular model: use predict with augmented features
        [~, s] = predict(M, X_aug);
        scores(:, j) = s(:, 2);
    end
end

% Calibrate thresholds (same logic as predict_multilabel)
thresholds = 0.5 * ones(1, K);
for j = 1:K
    y = logical(Yboot(:, j));
    if nnz(y) < 3, thresholds(j) = 0.5; continue; end
    ths = linspace(0.2, 0.9, 11);
    bestF1 = 0; bestTh = 0.5;
    for t = ths
        yhat = scores(:, j) >= t;
        p = sum(yhat & y) / max(1, sum(yhat));
        r = sum(yhat & y) / max(1, sum(y));
        F1 = 2*p*r / max(1e-9, (p+r));
        if F1 > bestF1, bestF1 = F1; bestTh = t; end
    end
    thresholds(j) = bestTh;
end

pred = scores >= thresholds;

end
