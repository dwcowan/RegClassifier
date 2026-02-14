function [X_norm, stats] = normalize_features(X, varargin)
%NORMALIZE_FEATURES Normalize feature matrix using specified method.
%   X_norm = NORMALIZE_FEATURES(X, 'Method', method) normalizes the feature
%   matrix X using the specified method. This is critical when concatenating
%   features from different modalities (TF-IDF, LDA, embeddings).
%
%   [X_norm, stats] = NORMALIZE_FEATURES(X, 'Method', method) also returns
%   normalization statistics that can be applied to test data.
%
%   X_norm = NORMALIZE_FEATURES(X, 'Method', method, 'Stats', stats) applies
%   pre-computed statistics (e.g., from training data) to normalize X.
%
%   INPUTS:
%       X      - N x D feature matrix (can be sparse or dense)
%
%   NAME-VALUE ARGUMENTS:
%       'Method'  - Normalization method (default: 'l2'):
%                   'l2'     - L2 row-wise normalization (unit norm per sample)
%                   'zscore' - Z-score standardization per feature
%                   'minmax' - Min-max scaling to [0,1] per feature
%                   'none'   - No normalization (returns X unchanged)
%       'Stats'   - Pre-computed normalization statistics (struct)
%       'OmitNaN' - If true, handle NaN values gracefully (default: false)
%
%   OUTPUTS:
%       X_norm - Normalized feature matrix
%       stats  - Struct with normalization statistics (mu, sigma, etc.)
%
%   SEE ALSO: reg.ta_features, reg.doc_embeddings_bert_gpu

% Parse name-value arguments
p = inputParser;
addParameter(p, 'Method', 'l2', @(x) ischar(x) || isstring(x));
addParameter(p, 'Stats', [], @(x) isempty(x) || isstruct(x));
addParameter(p, 'OmitNaN', false, @islogical);
parse(p, varargin{:});

method = char(lower(p.Results.Method));
preStats = p.Results.Stats;
omitNaN = p.Results.OmitNaN;

% Validate method
valid_methods = {'l2', 'zscore', 'minmax', 'none'};
if ~ismember(method, valid_methods)
    error('reg:normalize_features:InvalidMethod', ...
        'Method must be one of: %s. Got: %s', ...
        strjoin(valid_methods, ', '), method);
end

% Handle empty input
if isempty(X)
    X_norm = X;
    stats = struct('method', method);
    return;
end

% Check input dimensions
if ~ismatrix(X)
    error('reg:normalize_features:InvalidDimensions', ...
        'X must be a 2D matrix. Got %d dimensions.', ndims(X));
end

% Validate input for NaN/Inf
if any(isnan(X(:))) && ~omitNaN
    error('reg:normalize_features:NaNDetected', ...
        'Input contains NaN (missing data). Use ''OmitNaN'', true to handle NaN values.');
end
if any(isinf(X(:)))
    error('reg:normalize_features:InfDetected', ...
        'Input contains Inf (infinite) values. Remove Inf values before normalization.');
end

% Check for sparse matrix with methods that destroy sparsity
if issparse(X) && ismember(method, {'zscore', 'minmax'})
    error('reg:normalize_features:SparseNotSupported', ...
        'Method ''%s'' is not supported for sparse matrices. Use ''l2'' for sparse data or convert to full/dense first.', method);
end

[N, D] = size(X);

% Initialize stats
stats = struct('method', method);

% Apply normalization
switch method
    case 'none'
        X_norm = X;

    case 'l2'
        % L2 row-wise normalization (unit norm per sample)
        if issparse(X)
            row_norms = sqrt(sum(X.^2, 2));
        else
            row_norms = vecnorm(X, 2, 2);
        end
        row_norms(row_norms == 0) = 1;
        X_norm = X ./ row_norms;
        stats.row_norms = row_norms;

    case 'zscore'
        if ~isempty(preStats)
            % Apply pre-computed statistics
            mu = preStats.mu;
            sigma = preStats.sigma;
        else
            mu = mean(X, 1);
            sigma = std(X, 0, 1);
            sigma(sigma == 0) = 1;
        end
        X_norm = (X - mu) ./ sigma;
        stats.mu = mu;
        stats.sigma = sigma;

    case 'minmax'
        if ~isempty(preStats)
            min_vals = preStats.min_vals;
            range_vals = preStats.range_vals;
        else
            min_vals = min(X, [], 1);
            max_vals = max(X, [], 1);
            range_vals = max_vals - min_vals;
            range_vals(range_vals == 0) = 1;
        end
        X_norm = (X - min_vals) ./ range_vals;
        stats.min_vals = min_vals;
        stats.range_vals = range_vals;
end

end
