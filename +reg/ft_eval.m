function result = ft_eval(arg1, arg2, varargin)
%FT_EVAL Evaluate or embed with a fine-tuned encoder.
%   Two calling conventions:
%
%   EMBEDDING MODE:
%   E = FT_EVAL(netFT, textStr) returns embedding matrix E (N x projDim).
%   E = FT_EVAL(netFT, textStr, 'MaxSeqLength', 128, 'BatchSize', 64)
%
%   EVALUATION MODE:
%   METRICS = FT_EVAL(chunksT, Ylogical, netFT) embeds the chunks and
%   computes retrieval metrics. Optional name-value pairs:
%       'K'                (default 10)   - Retrieval depth
%       'ComputeClustering'(default true) - Also compute clustering metrics

% Detect calling convention: embedding mode vs evaluation mode
if isstruct(arg1) && isfield(arg1, 'base') && isfield(arg1, 'head')
    % Embedding mode: ft_eval(netFT, textStr, NV...)
    netFT = arg1;
    textStr = arg2;
    p = inputParser;
    addParameter(p,'MaxSeqLength',256);
    addParameter(p,'BatchSize',64);
    parse(p,varargin{:});
    if isfield(netFT,'MaxSeqLength')
        maxLen = netFT.MaxSeqLength;
    else
        maxLen = p.Results.MaxSeqLength;
    end
    result = ft_embed_all(textStr, netFT, maxLen, p.Results.BatchSize);
else
    % Evaluation mode: ft_eval(chunksT, Ylogical, netFT, NV...)
    chunksT = arg1;
    Ylogical = arg2;
    netFT = varargin{1};
    nvArgs = varargin(2:end);
    p = inputParser;
    addParameter(p,'K',10);
    addParameter(p,'ComputeClustering',true);
    parse(p,nvArgs{:});
    K = p.Results.K;
    doClust = p.Results.ComputeClustering;

    % Embed all chunks
    E = ft_embed_all(chunksT.text, netFT, netFT.MaxSeqLength, 64);

    % Build pos sets from labels
    N = height(chunksT);
    posSets = cell(N,1);
    for i = 1:N
        labs = Ylogical(i,:);
        pos = find(any(Ylogical(:,labs),2));
        pos(pos==i) = [];
        posSets{i} = pos;
    end

    [recallK, mAP] = reg.eval_retrieval(E, posSets, K);
    if doClust
        S = reg.eval_clustering(E, Ylogical);
        purity = S.purity; silhouette = S.silhouette;
    else
        purity = NaN; silhouette = NaN;
    end
    result = struct('recallAtK', recallK, 'mAP', mAP, ...
                     'purity', purity, 'silhouette', silhouette);
end
end

function E = ft_embed_all(textStr, netFT, maxLen, mb)
tok = reg.init_bert_tokenizer();
textStr = string(textStr);
N = numel(textStr);

% Handle empty input
if N == 0
    E = zeros(0, 384, 'single');
    return;
end

E = zeros(N, 384, 'single');
useGPU = gpuDeviceCount > 0;

for s = 1:mb:N
    e = min(N, s+mb-1);
    % R2025b: encode returns [tokenCodes, segments] as cell arrays, not struct
    [tokenCodes, ~] = encode(tok, textStr(s:e));
    % Manually pad sequences to maxLen (R2025b encode doesn't auto-pad)
    paddingCode = double(tok.PaddingCode);
    numSeqs = numel(tokenCodes);
    ids = paddingCode * ones(numSeqs, maxLen);  % Pre-fill with padding
    for i = 1:numSeqs
        seq = double(tokenCodes{i});
        len = min(numel(seq), maxLen);
        ids(i, 1:len) = seq(1:len);
    end
    mask = double(ids ~= paddingCode);  % Attention mask: 1 for real tokens, 0 for padding
    % Reshape to 3D (1, maxLen, N) 'CTB' format for BERT sequenceInputLayer (C=1)
    ids = dlarray(gpuArray(single(permute(ids, [3,2,1]))),'CTB');
    segs = dlarray(gpuArray(single(ones(1, maxLen, numSeqs))),'CTB');
    mask = dlarray(gpuArray(single(permute(mask, [3,2,1]))),'CTB');
    out = reg.bert_predict(netFT.base, ids, segs, mask);
    Z = localPooled(out);
    Z = predict(netFT.head, Z);
    Z = gather(extractdata(Z))';
    % L2 norm
    n = vecnorm(Z,2,2); n(n==0)=1; Z = Z ./ n;
    E(s:e,:) = single(Z);

    % Clear GPU arrays to prevent memory accumulation in loop
    if useGPU
        clear ids mask out Z;
    end
end

% Final GPU cleanup
if useGPU
    wait(gpuDevice);
end
end

function Z = localPooled(out)
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
