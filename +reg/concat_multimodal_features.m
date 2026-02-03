function [features, info] = concat_multimodal_features(varargin)
%CONCAT_MULTIMODAL_FEATURES Concatenate and normalize multi-modal features.
%   [features, info] = CONCAT_MULTIMODAL_FEATURES('Name', Value, ...)
%   concatenates features from different modalities (TF-IDF, LDA, embeddings)
%   with proper normalization to avoid scale imbalance.
%
%   NAME-VALUE ARGUMENTS:
%       'TFIDF'     - TF-IDF sparse matrix (N x V)
%       'LDA'       - LDA topic distribution (N x K)
%       'Embeddings' - Dense embeddings (N x D), e.g., BERT
%       'Normalize' - Normalization method: 'l2' (default), 'zscore', 'minmax', 'none'
%       'Verbose'   - Display concatenation summary (default: true)
%
%   OUTPUTS:
%       features - Concatenated feature matrix [TFIDF_norm | LDA_norm | Emb_norm]
%       info     - Struct with concatenation details:
%                  .num_samples     - Number of samples (N)
%                  .tfidf_dim       - TF-IDF dimensions
%                  .lda_dim         - LDA dimensions
%                  .embedding_dim   - Embedding dimensions
%                  .total_dim       - Total feature dimensions
%                  .normalize_method - Normalization method used
%                  .is_sparse       - Whether output is sparse
%
%   MOTIVATION:
%       Concatenating heterogeneous features without normalization causes
%       scale imbalance:
%       - TF-IDF: Unbounded (values > 10 common)
%       - LDA: Probabilities [0,1]
%       - BERT: L2-normalized (row norm = 1)
%
%       Logistic regression and other linear models are sensitive to feature
%       scales. TF-IDF will dominate the loss, reducing the benefit of
%       semantic embeddings.
%
%       SOLUTION: L2-normalize each modality before concatenation.
%
%   EXAMPLE 1: Basic usage
%       [docsTok, vocab, Xtfidf] = reg.ta_features(chunksT.text);
%       % Assume topicDist and E are already computed
%       features = reg.concat_multimodal_features(...
%           'TFIDF', Xtfidf, ...
%           'LDA', topicDist, ...
%           'Embeddings', E);
%
%   EXAMPLE 2: With info output
%       [features, info] = reg.concat_multimodal_features(...
%           'TFIDF', Xtfidf, ...
%           'Embeddings', E, ...
%           'Normalize', 'l2', ...
%           'Verbose', true);
%       fprintf('Total feature dim: %d\n', info.total_dim);
%
%   EXAMPLE 3: Only some modalities
%       % Just TF-IDF and BERT (no LDA)
%       features = reg.concat_multimodal_features(...
%           'TFIDF', Xtfidf, ...
%           'Embeddings', E);
%
%   SEE ALSO: reg.normalize_features, reg.ta_features, reg.doc_embeddings_bert_gpu

% Parse inputs
p = inputParser;
addParameter(p, 'TFIDF', [], @(x) isempty(x) || ismatrix(x));
addParameter(p, 'LDA', [], @(x) isempty(x) || ismatrix(x));
addParameter(p, 'Embeddings', [], @(x) isempty(x) || ismatrix(x));
addParameter(p, 'Normalize', 'l2', @(x) ischar(x) || isstring(x));
addParameter(p, 'Verbose', true, @islogical);
parse(p, varargin{:});

Xtfidf = p.Results.TFIDF;
lda = p.Results.LDA;
emb = p.Results.Embeddings;
normalize_method = char(p.Results.Normalize);
verbose = p.Results.Verbose;

% Check that at least one modality is provided
if isempty(Xtfidf) && isempty(lda) && isempty(emb)
    error('reg:concat_multimodal_features:NoFeatures', ...
        'At least one feature modality must be provided.');
end

% Determine number of samples
N = [];
if ~isempty(Xtfidf), N = size(Xtfidf, 1); end
if ~isempty(lda)
    if isempty(N)
        N = size(lda, 1);
    elseif size(lda, 1) ~= N
        error('reg:concat_multimodal_features:SizeMismatch', ...
            'LDA has %d samples but expected %d.', size(lda, 1), N);
    end
end
if ~isempty(emb)
    if isempty(N)
        N = size(emb, 1);
    elseif size(emb, 1) ~= N
        error('reg:concat_multimodal_features:SizeMismatch', ...
            'Embeddings have %d samples but expected %d.', size(emb, 1), N);
    end
end

% Initialize info struct
info = struct();
info.num_samples = N;
info.tfidf_dim = 0;
info.lda_dim = 0;
info.embedding_dim = 0;
info.normalize_method = normalize_method;

% Normalize each modality
feature_parts = {};

if ~isempty(Xtfidf)
    if verbose
        fprintf('Normalizing TF-IDF features (%d x %d, sparse=%d)...\n', ...
            size(Xtfidf, 1), size(Xtfidf, 2), issparse(Xtfidf));
    end
    Xtfidf_norm = reg.normalize_features(Xtfidf, normalize_method);
    feature_parts{end+1} = Xtfidf_norm;
    info.tfidf_dim = size(Xtfidf, 2);
end

if ~isempty(lda)
    if verbose
        fprintf('Normalizing LDA features (%d x %d)...\n', ...
            size(lda, 1), size(lda, 2));
    end
    lda_norm = reg.normalize_features(lda, normalize_method);

    % Convert to sparse if TFIDF is sparse for memory efficiency
    if ~isempty(Xtfidf) && issparse(Xtfidf)
        lda_norm = sparse(lda_norm);
    end

    feature_parts{end+1} = lda_norm;
    info.lda_dim = size(lda, 2);
end

if ~isempty(emb)
    if verbose
        fprintf('Normalizing embedding features (%d x %d)...\n', ...
            size(emb, 1), size(emb, 2));
    end

    % Check if embeddings are already L2-normalized (common for BERT)
    if strcmpi(normalize_method, 'l2')
        row_norms = vecnorm(emb, 2, 2);
        if all(abs(row_norms - 1) < 1e-6)
            if verbose
                fprintf('  Embeddings already L2-normalized, skipping normalization.\n');
            end
            emb_norm = emb;
        else
            emb_norm = reg.normalize_features(emb, normalize_method);
        end
    else
        emb_norm = reg.normalize_features(emb, normalize_method);
    end

    % Convert to sparse if needed for consistency
    if ~isempty(Xtfidf) && issparse(Xtfidf) && ~issparse(emb_norm)
        emb_norm = sparse(emb_norm);
    end

    feature_parts{end+1} = emb_norm;
    info.embedding_dim = size(emb, 2);
end

% Concatenate all parts
if isempty(feature_parts)
    error('reg:concat_multimodal_features:NoValidFeatures', ...
        'No valid features after normalization.');
end

features = horzcat(feature_parts{:});

% Update info
info.total_dim = size(features, 2);
info.is_sparse = issparse(features);

% Display summary
if verbose
    fprintf('\n=== Multi-modal Feature Concatenation Summary ===\n');
    fprintf('Number of samples:  %d\n', info.num_samples);
    if info.tfidf_dim > 0
        fprintf('TF-IDF dimensions:  %d (%.1f%%)\n', ...
            info.tfidf_dim, 100 * info.tfidf_dim / info.total_dim);
    end
    if info.lda_dim > 0
        fprintf('LDA dimensions:     %d (%.1f%%)\n', ...
            info.lda_dim, 100 * info.lda_dim / info.total_dim);
    end
    if info.embedding_dim > 0
        fprintf('Embedding dimensions: %d (%.1f%%)\n', ...
            info.embedding_dim, 100 * info.embedding_dim / info.total_dim);
    end
    fprintf('Total dimensions:   %d\n', info.total_dim);
    fprintf('Normalization:      %s\n', info.normalize_method);
    fprintf('Sparse matrix:      %s\n', mat2str(info.is_sparse));
    fprintf('Memory usage:       %.1f MB\n', ...
        whos('features').bytes / 1024^2);
    fprintf('================================================\n\n');
end

end
