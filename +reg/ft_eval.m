function metrics = ft_eval(chunksT, Ylogical, netFT, varargin)
%FT_EVAL Evaluate retrieval & clustering with a fine-tuned encoder
% NV: 'K'(10)
p = inputParser;
addParameter(p,'K',10);
parse(p,varargin{:});
K = p.Results.K;

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
S = reg.eval_clustering(E, Ylogical);
metrics = struct('recallAtK', recallK, 'mAP', mAP, 'purity', S.purity, 'silhouette', S.silhouette);
end

function E = ft_embed_all(textStr, netFT)
tok = bertTokenizer("base-uncased");
textStr = string(textStr);
N = numel(textStr);
mb = 64;  % reasonable default for pooled inference
E = zeros(N, 384, 'single');
for s = 1:mb:N
    e = min(N, s+mb-1);
    enc = encode(tok, textStr(s:e), 'Padding','longest','Truncation','longest');
    ids = enc.InputIDs; mask = enc.AttentionMask;
    if size(ids,2) > netFT.MaxSeqLength
        ids = ids(:,1:netFT.MaxSeqLength); mask = mask(:,1:netFT.MaxSeqLength);
    end
    ids = dlarray(gpuArray(int32(ids)),'CB'); mask = dlarray(gpuArray(int32(mask)),'CB');
    out = predict(netFT.base, ids, mask);
    Z = localPooled(out);
    Z = predict(netFT.head, Z);
    Z = gather(extractdata(Z))';
    % L2 norm
    n = vecnorm(Z,2,2); n(n==0)=1; Z = Z ./ n;
    E(s:e,:) = single(Z);
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
