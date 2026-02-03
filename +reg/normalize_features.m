function X_norm = normalize_features(X, method)
%NORMALIZE_FEATURES Normalize feature matrix using specified method.
%   X_norm = NORMALIZE_FEATURES(X, method) normalizes the feature matrix X
%   using the specified method. This is critical when concatenating features
%   from different modalities (TF-IDF, LDA, embeddings) which have different
%   scales.
%
%   INPUTS:
%       X      - N x D feature matrix (can be sparse or dense)
%       method - Normalization method (default: 'l2'):
%                'l2'     - L2 row-wise normalization (unit norm per sample)
%                'zscore' - Z-score standardization per feature
%                'minmax' - Min-max scaling to [0,1] per feature
%                'none'   - No normalization (returns X unchanged)
%
%   OUTPUTS:
%       X_norm - Normalized feature matrix (same size and sparsity as X)
%
%   NORMALIZATION METHODS:
%
%   L2 (recommended for concatenation):
%       Each row (sample) is scaled to unit L2 norm.
%       X_norm(i,:) = X(i,:) / ||X(i,:)||_2
%       Preserves sparsity, good for cosine similarity.
%
%   Z-Score (standardization):
%       Each column (feature) is scaled to mean=0, std=1.
%       X_norm(:,j) = (X(:,j) - mean(X(:,j))) / std(X(:,j))
%       Destroys sparsity, good for linear models.
%
%   Min-Max:
%       Each column scaled to [0,1] range.
%       X_norm(:,j) = (X(:,j) - min(X(:,j))) / (max(X(:,j)) - min(X(:,j)))
%       Destroys sparsity, bounded outputs.
%
%   EXAMPLE:
%       % Normalize TF-IDF before concatenation
%       Xtfidf_norm = reg.normalize_features(Xtfidf, 'l2');
%       lda_norm = reg.normalize_features(topicDist, 'l2');
%       E_norm = E;  % BERT already L2-normalized
%       features = [Xtfidf_norm, sparse(lda_norm), E_norm];
%
%   WHY THIS IS IMPORTANT:
%       When concatenating features from different modalities:
%       - TF-IDF: Unbounded, values can be > 10
%       - LDA: Probability distributions, values in [0,1]
%       - BERT: L2-normalized, values ~ [-1,1], row norm = 1
%       Without normalization, TF-IDF dominates the loss function in
%       linear models (e.g., logistic regression), reducing the benefit
%       of semantic embeddings.
%
%   SEE ALSO: reg.ta_features, reg.doc_embeddings_bert_gpu

% Default method
if nargin < 2 || isempty(method)
    method = 'l2';
end

% Validate method
valid_methods = {'l2', 'zscore', 'minmax', 'none'};
if ~ismember(lower(method), valid_methods)
    error('reg:normalize_features:InvalidMethod', ...
        'Method must be one of: %s. Got: %s', ...
        strjoin(valid_methods, ', '), method);
end

% Handle empty input
if isempty(X)
    X_norm = X;
    return;
end

% Check input dimensions
if ~ismatrix(X)
    error('reg:normalize_features:InvalidDimensions', ...
        'X must be a 2D matrix. Got %d dimensions.', ndims(X));
end

[N, D] = size(X);

% Apply normalization
switch lower(method)
    case 'none'
        % No normalization
        X_norm = X;

    case 'l2'
        % L2 row-wise normalization (unit norm per sample)
        % Compute row norms
        if issparse(X)
            % For sparse matrices, use efficient norm computation
            row_norms = sqrt(sum(X.^2, 2));
        else
            row_norms = vecnorm(X, 2, 2);  % Faster for dense
        end

        % Avoid division by zero
        row_norms(row_norms == 0) = 1;

        % Normalize
        if issparse(X)
            % Preserve sparsity
            X_norm = X ./ row_norms;
        else
            X_norm = X ./ row_norms;
        end

    case 'zscore'
        % Z-score standardization per feature (column)
        % WARNING: This destroys sparsity!

        if issparse(X)
            warning('reg:normalize_features:ZScoreDestroysSparsity', ...
                'Z-score normalization converts sparse matrix to dense. Consider using ''l2'' instead.');
            X = full(X);  % Convert to dense
        end

        % Compute mean and std per feature
        mu = mean(X, 1);      % 1 x D
        sigma = std(X, 0, 1); % 1 x D

        % Avoid division by zero (constant features)
        sigma(sigma == 0) = 1;

        % Standardize
        X_norm = (X - mu) ./ sigma;

    case 'minmax'
        % Min-max scaling to [0,1] per feature
        % WARNING: This destroys sparsity!

        if issparse(X)
            warning('reg:normalize_features:MinMaxDestroysSparsity', ...
                'Min-max normalization converts sparse matrix to dense. Consider using ''l2'' instead.');
            X = full(X);
        end

        % Compute min and max per feature
        min_vals = min(X, [], 1);  % 1 x D
        max_vals = max(X, [], 1);  % 1 x D

        % Compute range
        range_vals = max_vals - min_vals;
        range_vals(range_vals == 0) = 1;  % Avoid division by zero

        % Scale
        X_norm = (X - min_vals) ./ range_vals;

    otherwise
        error('reg:normalize_features:UnknownMethod', ...
            'Unknown normalization method: %s', method);
end

% Validation: Check for NaN or Inf
if any(isnan(X_norm(:))) || any(isinf(X_norm(:)))
    warning('reg:normalize_features:InvalidOutput', ...
        'Normalization produced NaN or Inf values. Check input data.');
end

end
