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

% Determine chain label order from model feature dimensions.
% Label j was trained on [X, Yboot(:, prev_labels)], so the number of
% chain features = model dimension - D tells us how many preceding labels
% were used.  We predict sequentially to augment X for non-CV models.
D = size(X, 2);
for j = 1:K
    M = models{j};
    if isempty(M), continue; end
    if isa(M, 'ClassificationPartitionedModel')
        % CV model: kfoldPredict uses internally stored training data
        [~, s] = kfoldPredict(M);
    else
        % Non-CV model: augment X with preceding chain labels (Yboot)
        % to match the feature space used during training
        numChainFeats = numel(M.PredictorNames) - D;
        if numChainFeats > 0
            % Use Yboot ground-truth labels for chain features (matches training)
            chainCols = 1:numChainFeats;
            X_aug = [X, double(Yboot(:, chainCols))];
            [~, s] = predict(M, X_aug);
        else
            [~, s] = predict(M, X);
        end
    end
    scores(:, j) = s(:, 2);
end

% Calibrate thresholds (vectorized, same logic as predict_multilabel)
thresholds = 0.5 * ones(1, K);
ths = linspace(0.2, 0.9, 51);
for j = 1:K
    y = logical(Yboot(:, j));
    if nnz(y) < 3, continue; end
    yhatAll = scores(:, j) >= ths;           % N x 51 logical
    tp = sum(yhatAll & y, 1);               % 1 x 51
    predPos = sum(yhatAll, 1);              % 1 x 51
    actualPos = nnz(y);
    prec = tp ./ max(1, predPos);
    rec  = tp ./ max(1, actualPos);
    F1   = 2 .* prec .* rec ./ max(1e-9, prec + rec);
    [~, bestIdx] = max(F1);
    thresholds(j) = ths(bestIdx);
end

pred = scores >= thresholds;

end
