function models = train_multilabel_chains(X, Yboot, kfold, varargin)
%TRAIN_MULTILABEL_CHAINS Classifier chains for multi-label learning.
%   models = TRAIN_MULTILABEL_CHAINS(X, Yboot, kfold) trains a classifier
%   chain that captures label dependencies by augmenting features with
%   previous label predictions in the chain order.
%
%   Returns a cell array of models (one per label), matching the API of
%   train_multilabel. Each model is trained on features augmented with
%   the ground-truth labels of all preceding labels in the chain order.
%
%   INPUTS:
%       X      - Feature matrix (N x D)
%       Yboot  - Binary label matrix (N x L)
%       kfold  - Number of CV folds (0 for no CV)
%
%   NAME-VALUE ARGUMENTS:
%       'LabelOrder'  - Custom label order (1 x L) or [] for 1:L (default: [])
%       'Verbose'     - Display training progress (default: false)
%
%   OUTPUTS:
%       models - Cell array {L x 1} of trained classifiers (one per label),
%                compatible with predict_multilabel_chains.
%
%   EXAMPLE:
%       models = reg.train_multilabel_chains(X, Yboot, 5);
%       [scores, thresholds, pred] = reg.predict_multilabel_chains(models, X, Yboot);
%
%   SEE ALSO: reg.predict_multilabel_chains, reg.train_multilabel

% Parse arguments
p = inputParser;
addParameter(p, 'LabelOrder', [], @(x) isempty(x) || (isnumeric(x) && isvector(x)));
addParameter(p, 'Verbose', false, @islogical);
parse(p, varargin{:});

label_order_custom = p.Results.LabelOrder;
verbose = p.Results.Verbose;

% Get dimensions
[N, D] = size(X);
labelsK = size(Yboot, 2);

% Validate inputs
if size(Yboot, 1) ~= N
    error('reg:train_multilabel_chains:SizeMismatch', ...
        'X and Yboot must have same number of rows (N=%d vs %d)', N, size(Yboot,1));
end

if ~isempty(label_order_custom) && numel(label_order_custom) ~= labelsK
    error('reg:train_multilabel_chains:InvalidLabelOrder', ...
        'LabelOrder must have length L=%d', labelsK);
end

% Convert Y to logical if needed
if ~islogical(Yboot)
    Yboot = logical(Yboot);
end

% Determine label order
if ~isempty(label_order_custom)
    label_order = label_order_custom;
else
    label_order = 1:labelsK;
end

if verbose
    fprintf('\n=== Training Classifier Chains ===\n');
    fprintf('Examples: %d\n', N);
    fprintf('Features: %d\n', D);
    fprintf('Labels:   %d\n', labelsK);
    fprintf('K-fold:   %d\n', kfold);
    fprintf('\n');
end

% Initialize output cell array (one model per label)
models = cell(labelsK, 1);

% Train classifiers in chain order
for j_idx = 1:labelsK
    j = label_order(j_idx);
    y = Yboot(:, j);

    % Skip labels with insufficient positive examples
    if nnz(y) < 3
        models{j} = [];
        if verbose
            fprintf('  Label %d: skipped (only %d positives)\n', j, nnz(y));
        end
        continue;
    end

    % Augment features with previous label columns in chain order
    if j_idx == 1
        X_aug = X;
    else
        prev_labels = label_order(1:(j_idx-1));
        X_aug = [X, double(Yboot(:, prev_labels))];
    end

    % Train classifier on augmented features
    if kfold > 0
        models{j} = fitclinear(X_aug, y, 'Learner', 'logistic', ...
            'ObservationsIn', 'rows', 'KFold', kfold, ...
            'ClassNames', [false true]);
    else
        models{j} = fitclinear(X_aug, y, 'Learner', 'logistic', ...
            'ObservationsIn', 'rows', 'ClassNames', [false true]);
    end

    if verbose
        fprintf('  Label %d: trained on %d features (base %d + %d chain)\n', ...
            j, size(X_aug, 2), D, size(X_aug, 2) - D);
    end
end

if verbose
    num_trained = sum(~cellfun(@isempty, models));
    fprintf('\nTraining complete: %d/%d classifiers trained\n', num_trained, labelsK);
end

end
