function E = doc_embeddings_bert_gpu(textStr, varargin)
%DOC_EMBEDDINGS_BERT_GPU Sentence embeddings using MATLAB BERT on GPU.
% Requires Deep Learning Toolbox + "Text Analytics Toolbox Model for BERT English"
% It uses the pooled [CLS] output as a sentence embedding.
%
% Usage:
%   E = reg.doc_embeddings_bert_gpu(textStr);
%   E = reg.doc_embeddings_bert_gpu(textStr, 'MiniBatchSize', 96);
%
% If BERT is unavailable, this function throws. Callers should catch and fallback.

% Set defaults
miniBatchSize = 96;
maxSeqLen = 256;

% Override from params.json if available
if isfile('params.json')
    try
        params = jsondecode(fileread('params.json'));
        if isfield(params, 'MiniBatchSize')
            miniBatchSize = params.MiniBatchSize;
        end
        if isfield(params, 'MaxSeqLength')
            maxSeqLen = params.MaxSeqLength;
        end
    catch ME
        warning('Could not read params.json: %s. Using defaults.', ME.message);
    end
end

p = inputParser;
addParameter(p,'MiniBatchSize', miniBatchSize, @(x)isnumeric(x)&&x>=1);
addParameter(p,'MaxSeqLength',maxSeqLen,@(x)isnumeric(x)&&x>=1);
parse(p, varargin{:});
miniBatchSize = p.Results.MiniBatchSize;
maxSeqLen = p.Results.MaxSeqLength;

% Ensure GPU is available
assert(gpuDeviceCount > 0, 'No GPU device found. Install CUDA-enabled GPU drivers.');

% Load tokenizer using shared initialization function
tok = reg.init_bert_tokenizer();

%% Try to use fine-tuned encoder if available
try
    S = load('fine_tuned_bert.mat','netFT');
    net = S.netFT.base;
    headFT = S.netFT.head; useHead = true;
    maxLenFT = S.netFT.MaxSeqLength;
catch ME
    % Fine-tuned model not available, use base BERT (R2025b API)
    try
        [net, ~] = bert(Model="base");
        useHead = false; maxLenFT = [];
    catch ME2
        try
            [net, ~] = bert();
            useHead = false; maxLenFT = [];
        catch ME3
            error('BERT:ModelMissing', ...
                'BERT model not found. Install ''Text Analytics Toolbox Model for BERT English''. Original error: %s', ME3.message);
        end
    end
end  % returns a dlnetwork

textStr = string(textStr);
N = numel(textStr);
% Tokenize to IDs and masks
% R2025b: encode returns [tokenCodes, segments] as cell arrays, not struct
[tokenCodes, ~] = encode(tok, textStr);
% Manually pad sequences (R2025b encode doesn't auto-pad)
paddingCode = double(tok.PaddingCode);
numSeqs = numel(tokenCodes);
% Find max length in batch, cap at maxSeqLen
seqLens = cellfun(@numel, tokenCodes);
maxLen = min(max(seqLens), maxSeqLen);
% Create padded matrix
ids = paddingCode * ones(numSeqs, maxLen);  % Pre-fill with padding
for i = 1:numSeqs
    seq = double(tokenCodes{i});
    len = min(numel(seq), maxLen);
    ids(i, 1:len) = seq(1:len);
end
mask = double(ids ~= paddingCode);  % Attention mask: 1 for real tokens, 0 for padding


% Mini-batch inference on GPU
E = zeros(N, 768, 'single');  % bert-base hidden size
for s = 1:miniBatchSize:N
    e = min(N, s+miniBatchSize-1);
    batchN = e - s + 1;
    % Reshape to 3D (1, maxLen, batchN) 'CTB' format for BERT sequenceInputLayer (C=1)
    idsMB  = dlarray(gpuArray(single(permute(ids(s:e, :), [3,2,1]))),'CTB');
    segsMB = dlarray(gpuArray(single(ones(1, maxLen, batchN))),'CTB');
    maskMB = dlarray(gpuArray(single(permute(mask(s:e, :), [3,2,1]))),'CTB');

    % Forward through BERT; get pooled output
    out = reg.bert_predict(net, idsMB, segsMB, maskMB);
    if useHead
        pooled = getPooled(out);
        pooled = predict(headFT, pooled);
        pooled = gather(extractdata(pooled));
        if size(pooled,2) ~= 384
            if size(pooled,1)==384, pooled = pooled.'; else, error('HeadDimMismatch'); end
        end
        E(s:e,:) = single(pooled);
        continue
    end
    if isstruct(out)
        % Newer versions may return a struct with fields like "pooledOutput"
        if isfield(out, 'pooledOutput')
            pooled = out.pooledOutput;
        elseif isfield(out, 'sequenceOutput')
            % Fallback: use first token ([CLS]) from sequenceOutput
            seq = out.sequenceOutput;   % (B, T, H) or (H, T, B)
            if ndims(seq)==3 && size(seq,2)==maxLen   % (B,T,H)
                pooled = squeeze(seq(:,1,:));
            else
                pooled = squeeze(seq(1,:,:))'; % try to recover shape
            end
        else
            error("BERT:OutputUnknown","Unknown BERT output struct fields.");
        end
    else
        % Some versions return pooled as second output—try dlfeval?
        pooled = out;
    end

    pooled = gather(extractdata(pooled));  % to CPU
    if size(pooled,2) ~= 768
        % Attempt to fix orientation
        if size(pooled,1)==768
            pooled = pooled.';
        else
            error("BERT:DimMismatch","Expected pooled dimension 768, got %s", mat2str(size(pooled)));
        end
    end
    E(s:e, :) = single(pooled);
end

% L2 normalize
n = vecnorm(E,2,2); n(n==0)=1; E = E ./ n;

% Ensure GPU operations complete
if gpuDeviceCount > 0
    wait(gpuDevice);
end
end


function Z = getPooled(out)
if isstruct(out) && isfield(out,'pooledOutput')
    p = out.pooledOutput;
elseif isstruct(out) && isfield(out,'sequenceOutput')
    p = out.sequenceOutput;
else
    p = out;
end
% For 3D+ outputs, extract CLS token and flatten to (hidden, batch)
if ndims(p) >= 3
    seqDim = 2; chanDim = 1; batchDim = 3;  % defaults for CTB
    if isa(p, 'dlarray')
        fmt = dims(p);
        if strlength(fmt) >= ndims(p)
            fc = char(fmt);
            t = find(fc == 'T' | fc == 'S');
            c = find(fc == 'C');
            b = find(fc == 'B');
            if ~isempty(t), seqDim = t(1); end
            if ~isempty(c), chanDim = c(1); end
            if ~isempty(b), batchDim = b(1); end
        end
    end
    idx = repmat({':'}, 1, ndims(p));
    idx{seqDim} = 1;
    p = p(idx{:});
    p = permute(p, [chanDim, batchDim, seqDim]);
    p = reshape(p, size(p,1), size(p,2));
end
if isa(p, 'dlarray')
    p = stripdims(p);
end
Z = dlarray(p, 'CB');
end
