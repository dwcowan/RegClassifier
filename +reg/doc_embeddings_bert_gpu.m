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
    % Fine-tuned model not available, use base BERT
    try
        net = bert("base-uncased");
        useHead = false; maxLenFT = [];
    catch ME2
        error("BERT:ModelMissing", "BERT model not found. Install 'Text Analytics Toolbox Model for BERT English'. Original error: %s", ME2.message);
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
dlX = [];
for s = 1:miniBatchSize:N
    e = min(N, s+miniBatchSize-1);
    idsMB  = gpuArray(int32(ids(s:e, :)));
    maskMB = gpuArray(int32(mask(s:e, :)));

    % Forward through BERT; get pooled output
    out = predict(net, idsMB, maskMB);
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
if canUseGPU
    wait(gpuDevice);
end
end


function Z = getPooled(out)
if isstruct(out) && isfield(out,'pooledOutput')
    Z = dlarray(out.pooledOutput,'CB');
elseif isstruct(out) && isfield(out,'sequenceOutput')
    seq = out.sequenceOutput;
    if ndims(seq)==3
        Z = squeeze(seq(:,1,:));
        Z = dlarray(Z','CB');
    else
        Z = dlarray(seq,'CB');
    end
else
    Z = dlarray(out,'CB');
end
end
