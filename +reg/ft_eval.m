function metrics = ft_eval(chunksT, Ylogical, netFT, varargin)
%FT_EVAL Evaluate retrieval & clustering with a fine-tuned encoder.
%   METRICS = FT_EVAL(chunksT, Ylogical, netFT) embeds the chunks and
%   computes retrieval metrics. Optional name-value pairs:
%       'K'                (default 10)   - Retrieval depth
%       'ComputeClustering'(default true) - Also compute clustering metrics
p = inputParser;
addParameter(p,'K',10);
addParameter(p,'ComputeClustering',true);
parse(p,varargin{:});
K = p.Results.K;
doClust = p.Results.ComputeClustering;

% Embed all chunks
E = ft_embed_all(chunksT.text, netFT);

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
metrics = struct('recallAtK', recallK, 'mAP', mAP, ...
                 'purity', purity, 'silhouette', silhouette);
end

function E = ft_embed_all(textStr, netFT)
tok = reg.init_bert_tokenizer();
textStr = string(textStr);
N = numel(textStr);
mb = 64;  % reasonable default for pooled inference
E = zeros(N, 384, 'single');
useGPU = gpuDeviceCount > 0;

for s = 1:mb:N
    e = min(N, s+mb-1);
    % R2025b: encode returns [tokenCodes, segments] as cell arrays, not struct
    [tokenCodes, ~] = encode(tok, textStr(s:e));
    % Manually pad sequences to maxLen (R2025b encode doesn't auto-pad)
    paddingCode = double(tok.PaddingCode);
    numSeqs = numel(tokenCodes);
    maxLen = netFT.MaxSeqLength;
    ids = paddingCode * ones(numSeqs, maxLen);  % Pre-fill with padding
    for i = 1:numSeqs
        seq = double(tokenCodes{i});
        len = min(numel(seq), maxLen);
        ids(i, 1:len) = seq(1:len);
    end
    mask = double(ids ~= paddingCode);  % Attention mask: 1 for real tokens, 0 for padding
    ids = dlarray(gpuArray(int32(ids)),'CB'); mask = dlarray(gpuArray(int32(mask)),'CB');
    out = predict(netFT.base, ids, mask);
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
        Z = squeeze(seq(:,1,:));
        Z = dlarray(Z','CB');
    else
        Z = dlarray(seq,'CB');
    end
else
    Z = dlarray(out,'CB');
end
end
