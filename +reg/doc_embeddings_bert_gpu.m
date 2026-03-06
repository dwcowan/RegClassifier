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
    % Use the sequence length the fine-tuned model was trained with
    if isfield(S.netFT, 'MaxSeqLength') && ~isempty(S.netFT.MaxSeqLength)
        maxSeqLen = S.netFT.MaxSeqLength;
    end
catch ME
    % Fine-tuned model not available, use base BERT
    try
        net = bert("base-uncased");
        useHead = false;
    catch ME2
        error("BERT:ModelMissing", "BERT model not found. Install 'Text Analytics Toolbox Model for BERT English'. Original error: %s", ME2.message);
    end
end  % returns a dlnetwork

textStr = string(textStr);
N = numel(textStr);
paddingCode = double(tok.PaddingCode);

% Determine output dimension: 384 if fine-tuned head is used, 768 for base BERT
if useHead
    embDim = 384;
else
    embDim = 768;
end
E = zeros(N, embDim, 'single');

% Tokenize and process per mini-batch to avoid holding all token IDs in memory
for s = 1:miniBatchSize:N
    e = min(N, s+miniBatchSize-1);
    batchN = e - s + 1;

    % Tokenize this batch only (avoids O(N) cell array for large corpora)
    [tokenCodes, ~] = encode(tok, textStr(s:e));
    seqLens = cellfun(@numel, tokenCodes);
    maxLen = min(max(seqLens), maxSeqLen);

    % Pad sequences
    ids = paddingCode * ones(batchN, maxLen);
    for i = 1:batchN
        seq = double(tokenCodes{i});
        len = min(numel(seq), maxLen);
        ids(i, 1:len) = seq(1:len);
    end
    mask = double(ids ~= paddingCode);

    % Reshape to 3D (1, maxLen, batchN) 'CTB' format for BERT
    idsMB  = dlarray(gpuArray(single(permute(ids, [3,2,1]))),'CTB');
    segsMB = dlarray(gpuArray(single(ones(1, maxLen, batchN))),'CTB');
    maskMB = dlarray(gpuArray(single(permute(mask, [3,2,1]))),'CTB');

    % Forward through BERT; get pooled output
    out = predict(net, idsMB, segsMB, maskMB);
    if useHead
        pooled = getPooled(out);
        pooled = predict(headFT, pooled);
        pooled = gather(extractdata(pooled));
        % getPooled returns [embDim x batch] (CB format); transpose to [batch x embDim]
        if size(pooled,1) == embDim && size(pooled,2) == batchN
            pooled = pooled.';
        elseif size(pooled,2) ~= embDim
            error('HeadDimMismatch: expected %d columns, got [%d x %d]', embDim, size(pooled,1), size(pooled,2));
        end
        E(s:e,:) = single(pooled);
    else
        if isstruct(out)
            if isfield(out, 'pooledOutput')
                pooled = out.pooledOutput;
            elseif isfield(out, 'sequenceOutput')
                seq = out.sequenceOutput;
                if ndims(seq)==3 && size(seq,2)==maxLen
                    pooled = squeeze(seq(:,1,:));
                else
                    pooled = squeeze(seq(1,:,:))';
                end
            else
                error("BERT:OutputUnknown","Unknown BERT output struct fields.");
            end
        else
            pooled = out;
        end

        pooled = gather(extractdata(pooled));
        if size(pooled,2) ~= 768
            if size(pooled,1)==768
                pooled = pooled.';
            else
                error("BERT:DimMismatch","Expected pooled dimension 768, got %s", mat2str(size(pooled)));
            end
        end
        E(s:e,:) = single(pooled);
    end

    % Clear GPU intermediates to prevent memory accumulation between batches
    clear idsMB segsMB maskMB out pooled tokenCodes ids mask;
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
    Z = dlarray(out.pooledOutput,'CB');
elseif isstruct(out) && isfield(out,'sequenceOutput')
    seq = out.sequenceOutput;
    if ndims(seq)==3
        % seq is (hidden, seqLen, batch) 'CTB'; extract CLS token (position 1)
        Z = squeeze(seq(:,1,:));  % (hidden, batch)
        Z = dlarray(Z,'CB');
    else
        Z = dlarray(seq,'CB');
    end
else
    Z = dlarray(out,'CB');
end
end
