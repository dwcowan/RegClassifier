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

params = jsondecode(fileread('params.json'));
miniBatchSize = params.MiniBatchSize;
maxSeqLen = params.MaxSeqLength;

p = inputParser;
addParameter(p,'MiniBatchSize', miniBatchSize, @(x)isnumeric(x)&&x>=1);
addParameter(p,'MaxSeqLength',maxSeqLen,@(x)isnumeric(x)&&x>=1);
parse(p, varargin{:});
miniBatchSize = p.Results.MiniBatchSize;
maxSeqLen = p.Results.MaxSeqLength;

% Ensure GPU is available
assert(gpuDeviceCount > 0, 'No GPU device found. Install CUDA-enabled GPU drivers.');

% Load tokenizer and model
try
    tok = bertTokenizer("base-uncased"); % R2023b+ (support package)
catch
    try
        tok = bertWordPieceTokenizer("base-uncased"); % older naming
    catch ME
        error("BERT:TokenizerMissing", "BERT tokenizer not found. Install 'Text Analytics Toolbox Model for BERT English'. Original error: %s", ME.message);
    end
end

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
enc = encode(tok, textStr, 'Padding','longest','Truncation','longest'); % struct with fields: InputIDs, AttentionMask, ...
ids = enc.InputIDs; mask = enc.AttentionMask;
maxLen = size(ids,2);

if maxSeqLen < maxLen
    ids  = ids(:, 1:maxSeqLen);
    mask = mask(:,1:maxSeqLen);
    maxLen = maxSeqLen;
end


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
