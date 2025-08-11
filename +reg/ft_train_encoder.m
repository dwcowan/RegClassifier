function netFT = ft_train_encoder(chunksT, P, varargin)
%FT_TRAIN_ENCODER Contrastive fine-tuning of BERT encoder (MATLAB R2024a)
% Name-Value params:
%   'Epochs' (4)
%   'BatchSize' (32)
%   'MaxSeqLength' (256)
%   'EncoderLR' (1e-5)   % top layers small LR
%   'HeadLR' (1e-3)      % projection head LR
%   'Margin' (0.2)       % used for triplet loss
%   'UnfreezeTopLayers' (4)
%   'UseFP16' (false)
%   'Loss' ('triplet'|'supcon')  % supervised contrastive (NT-Xent) or triplet
%   'CheckpointDir' ('checkpoints')
%   'Resume' (true)  % resume from latest checkpoint if present
%
% P is a struct with fields anchor, positive, negative (uint32 indices). For 'supcon',
% we internally form two views per anchor (anchor, positive) and treat same-index pairs as positives.

p = inputParser;
addParameter(p,'Epochs',4);
addParameter(p,'BatchSize',32);
addParameter(p,'MaxSeqLength',256);
addParameter(p,'EncoderLR',1e-5);
addParameter(p,'HeadLR',1e-3);
addParameter(p,'Margin',0.2);
addParameter(p,'UnfreezeTopLayers',4);
addParameter(p,'UseFP16',false);
addParameter(p,'Loss','triplet',@(s)any(strcmpi(s,{'triplet','supcon'})));
addParameter(p,'CheckpointDir','checkpoints',@ischar);
addParameter(p,'Resume',true,@islogical);
addParameter(p,'EarlyStopPatience',2);
addParameter(p,'EarlyStopMinDelta',0.01);  % 1 percentage point
addParameter(p,'EvalY',[]);                % logical labels for eval
addParameter(p,'EvalEvery',1);             % epochs
addParameter(p,'HardNegatives',true);
addParameter(p,'HardNegMaxN',2000);        % mine on subset if corpus is huge
addParameter(p,'Yboot',[]);                % optional weak labels for hard-negative mining
parse(p,varargin{:});
R = p.Results;

assert(gpuDeviceCount > 0, 'GPU required for fine-tuning');
tok = bertTokenizer("base-uncased");
base = bert("base-uncased");   % dlnetwork

% Small MLP head on pooled output
projDim = 384;
layers = [
    featureInputLayer(768,'Normalization','none','Name','in')
    fullyConnectedLayer(512,'Name','fc1')
    reluLayer('Name','relu1')
    fullyConnectedLayer(projDim,'Name','fc2')
];
head = dlnetwork(layerGraph(layers));

% Freeze bottom encoder layers (unfreeze top N)
encParams = base.Learnables;
encLearnMask = true(height(encParams),1);
try
    encLayerNames = string(encParams.Layer);
    ids = regexp(encLayerNames, "\d+", "match");
    layerNums = zeros(numel(ids),1);
    for i = 1:numel(ids)
        if ~isempty(ids{i})
            % Use parentheses for indexing; square brackets cause errors.
            layerNums(i) = str2double(ids{i}{end});
        end
    end
    maxNum = max(layerNums);
    cutoff = maxNum - R.UnfreezeTopLayers + 1;
    if isfinite(cutoff) && cutoff>0
        encLearnMask = layerNums >= cutoff;
    end
catch
    warning('Could not parse layer indices; training full encoder at low LR.');
end

% Prepare triplets
A = double(P.anchor); Pp = double(P.positive); Nn = double(P.negative);
numTrip = numel(A);
mb = R.BatchSize; itersPerEpoch = ceil(numTrip / mb);

% Checkpointing
if ~isfolder(R.CheckpointDir), mkdir(R.CheckpointDir); end
startEpoch = 1; iter = 0;
taE = []; ta2E = []; taH = []; ta2H = [];
if R.Resume
    listing = dir(fullfile(R.CheckpointDir, 'ft_epoch*.mat'));
    if ~isempty(listing)
        [~, idx] = max([listing.datenum]);
        ck = load(fullfile(listing(idx).folder, listing(idx).name));
        if isfield(ck,'base'), base = ck.base; end
        if isfield(ck,'head'), head = ck.head; end
        if isfield(ck,'taE'), taE = ck.taE; end
        if isfield(ck,'ta2E'), ta2E = ck.ta2E; end
        if isfield(ck,'taH'), taH = ck.taH; end
        if isfield(ck,'ta2H'), ta2H = ck.ta2H; end
        if isfield(ck,'epoch'), startEpoch = ck.epoch + 1; end
        fprintf('Resumed from checkpoint: %s\n', listing(idx).name);
    end
end

% Training loop
bestScore = -inf; noImprove = 0;
for epoch = startEpoch:R.Epochs
    % Hard-negative mining (optional)
    if R.HardNegatives
        if ~isempty(R.Yboot)
            try
                [A, Pp, Nn] = localMineNegatives(base, head, chunksT, R.Yboot, A, Pp, Nn, R.MaxSeqLength, R.HardNegMaxN);
            catch ME
                warning('Hard-negative mining skipped: %s', ME.message);
            end
        else
            warning('Hard-negative mining skipped: Yboot labels not provided.');
        end
    end
    ord = randperm(numTrip);
    lossEpoch = 0;
    for it = 1:itersPerEpoch
        iter = iter + 1;
        s = (it-1)*mb + 1; e = min(numTrip, it*mb);
        aIdx = A(ord(s:e)); pIdx = Pp(ord(s:e)); nIdx = Nn(ord(s:e));

        switch lower(R.Loss)
            case 'triplet'
                [loss, gE, gH] = dlfeval(@gradTripletBatch, base, head, tok, aIdx, pIdx, nIdx, R.MaxSeqLength, R.UseFP16, R.Margin);
            case 'supcon'
                % Build two views per anchor: view1 = anchor, view2 = positive; negatives provided as usual
                [loss, gE, gH] = dlfeval(@gradSupConBatch, base, head, tok, aIdx, pIdx, R.MaxSeqLength, R.UseFP16);
        end

        % Zero grads for frozen encoder params
        if any(~encLearnMask)
            for gi = 1:height(gE)
                if ~encLearnMask(gi), gE.Value{gi}(:) = 0; end
            end
        end

        % AdamW updates
        [base, taE, ta2E] = adamupdate(base, gE, taE, ta2E, iter, R.EncoderLR, 0.9, 0.999);
        [head, taH, ta2H] = adamupdate(head, gH, taH, ta2H, iter, R.HeadLR, 0.9, 0.999);

        lossEpoch = lossEpoch + double(gather(extractdata(loss)));
    end
    fprintf("FT Epoch %d/%d [%s] - loss: %.4f\n", epoch, R.Epochs, upper(R.Loss), lossEpoch/itersPerEpoch);

    % End-of-epoch evaluation & early stopping
    if ~isempty(R.EvalY) && mod(epoch, R.EvalEvery)==0
        try
            metrics = localEvaluate(base, head, chunksT.text, R.EvalY, R.MaxSeqLength);
            curr = double(metrics.ndcg10);
            fprintf("Eval Epoch %d: Recall@10=%.3f mAP=%.3f nDCG@10=%.3f\n", epoch, metrics.recall10, metrics.mAP, metrics.ndcg10);
            if curr > bestScore + R.EarlyStopMinDelta
                bestScore = curr; noImprove = 0;
                save(fullfile(R.CheckpointDir, 'ft_best.mat'), 'base','head','epoch','-v7.3');
            else
                noImprove = noImprove + 1;
            end
            if noImprove >= R.EarlyStopPatience
                fprintf("Early stopping at epoch %d (no improvement %d epochs).\n", epoch, noImprove);
                break;
            end
        catch ME
            warning("Epoch evaluation failed: %s", ME.message);
        end
    end

    % Save checkpoint
    save(fullfile(R.CheckpointDir, sprintf('ft_epoch%02d.mat', epoch)), 'base','head','taE','ta2E','taH','ta2H','epoch','-v7.3');
end

netFT.base = base;
netFT.head = head;
netFT.MaxSeqLength = R.MaxSeqLength;
end

% === Helpers ===
function [loss, gE, gH] = gradTripletBatch(base, head, tok, aIdx, pIdx, nIdx, maxLen, useFP16, margin)
B = numel(aIdx);
texts = [aIdx(:); pIdx(:); nIdx(:)];
ids = encode(tok, string(assignin('caller','chunksT',[])), 'Padding','longest'); %#ok<NASGU>
% Re-encode directly from caller chunksT:
persistent cachedChunks;
if isempty(cachedChunks), cachedChunks = evalin('caller','chunksT'); end
batchTexts = [cachedChunks.text(aIdx); cachedChunks.text(pIdx); cachedChunks.text(nIdx)];
enc = encode(tok, batchTexts, 'Padding','longest','Truncation','longest');
X = enc.InputIDs; M = enc.AttentionMask;
if size(X,2) > maxLen, X = X(:,1:maxLen); M = M(:,1:maxLen); end
Xa = dlarray(gpuArray(int32(X(1:B,:))),'CB');
Xp = dlarray(gpuArray(int32(X(B+1:2*B,:))),'CB');
Xn = dlarray(gpuArray(int32(X(2*B+1:end,:))),'CB');
Ma = dlarray(gpuArray(int32(M(1:B,:))),'CB');
Mp = dlarray(gpuArray(int32(M(B+1:2*B,:))),'CB');
Mn = dlarray(gpuArray(int32(M(2*B+1:end,:))),'CB');

oA = predict(base, Xa, Ma); oP = predict(base, Xp, Mp); oN = predict(base, Xn, Mn);
ZA = pooled(oA); ZP = pooled(oP); ZN = pooled(oN);
ZA = forward(head, ZA); ZP = forward(head, ZP); ZN = forward(head, ZN);
ZA = l2norm(ZA); ZP = l2norm(ZP); ZN = l2norm(ZN);
dap = 1 - sum(ZA .* ZP, 1);
dan = 1 - sum(ZA .* ZN, 1);
L = max(0, dap - dan + margin);
loss = mean(L, 'all');
gH = dlgradient(loss, head.Learnables);
gE = dlgradient(loss, base.Learnables);
end

function [loss, gE, gH] = gradSupConBatch(base, head, tok, aIdx, pIdx, maxLen, useFP16)
% Supervised contrastive (NT-Xent) with two positives per "class" (anchor ~ positive)
B = numel(aIdx);
persistent cachedChunks;
if isempty(cachedChunks), cachedChunks = evalin('caller','chunksT'); end
batchTexts = [cachedChunks.text(aIdx); cachedChunks.text(pIdx)];
enc = encode(tok, batchTexts, 'Padding','longest','Truncation','longest');
X = enc.InputIDs; M = enc.AttentionMask;
if size(X,2) > maxLen, X = X(:,1:maxLen); M = M(:,1:maxLen); end
X1 = dlarray(gpuArray(int32(X(1:B,:))),'CB');  M1 = dlarray(gpuArray(int32(M(1:B,:))),'CB');
X2 = dlarray(gpuArray(int32(X(B+1:end,:))),'CB'); M2 = dlarray(gpuArray(int32(M(B+1:end,:))),'CB');

o1 = predict(base, X1, M1); o2 = predict(base, X2, M2);
Z1 = pooled(o1); Z2 = pooled(o2);
Z1 = forward(head, Z1); Z2 = forward(head, Z2);
Z1 = l2norm(Z1); Z2 = l2norm(Z2);
Z = [Z1 Z2];   % 2B samples
loss = nt_xent(Z, B);  % positives are pairs (i, i+B)

gH = dlgradient(loss, head.Learnables);
gE = dlgradient(loss, base.Learnables);
end

function loss = nt_xent(Z, B)
% NT-Xent loss for 2B samples with positives (i, i+B)
tau = 0.07;
S = (Z.' * Z);                % cosine since Z is normalized
S = S - eye(size(S));         % remove self-similarity
lossSum = dlarray(0.0);
count = 0;
for i = 1:B
    pos1 = S(i, i+B);
    denom1 = sum(exp(S(i,:) / tau));
    pos2 = S(i+B, i);
    denom2 = sum(exp(S(i+B,:) / tau));
    l1 = -log(exp(pos1/tau) / denom1);
    l2 = -log(exp(pos2/tau) / denom2);
    lossSum = lossSum + l1 + l2;
    count = count + 2;
end
loss = lossSum / count;
end

function Z = pooled(out)
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

function Z = l2norm(Z)
n = sqrt(sum(Z.^2,1) + 1e-9);
Z = Z ./ n;
end

function [Aout, Pout, Nout] = localMineNegatives(base, head, chunksT, Yboot, A, P, N, maxLen, maxN)
% Mine hard negatives using current encoder: closest items with different labels
Nall = height(chunksT);
subset = 1:Nall;
if Nall > maxN
    subset = sort(randperm(Nall, maxN));
end
tok = bertTokenizer("base-uncased");
texts = string(chunksT.text(subset));
enc = encode(tok, texts, 'Padding','longest','Truncation','longest');
ids = enc.InputIDs; mask = enc.AttentionMask;
if size(ids,2) > maxLen, ids = ids(:,1:maxLen); mask = mask(:,1:maxLen); end
ids = dlarray(gpuArray(int32(ids)),'CB'); mask = dlarray(gpuArray(int32(mask)),'CB');
out = predict(base, ids, mask);
Z = pooled(out);
Z = forward(head, Z);
Z = gather(extractdata(Z))';
n = vecnorm(Z,2,2); n(n==0)=1; Z = Z ./ n;
% Map to full space
E = zeros(Nall, size(Z,2), 'single');
E(subset,:) = single(Z);
% For each anchor in subset, pick closest negative (no shared labels)
S = E * E.';
Aout = A; Pout = P; Nout = N;
for i = subset
    labs = find(Yboot(i,:));
    if isempty(labs), continue; end
    s = S(i,:); s(i) = -inf;
    % mask out items sharing label
    share = any(Yboot(:,labs),2);
    s(share) = -inf;
    [~, ord] = sort(s,'descend');
    if ~isempty(ord)
        Nout(A==i) = ord(1); % set for triplets with this anchor
    end
end
end

function metrics = localEvaluate(base, head, textStr, Ylogical, maxLen)
tok = bertTokenizer("base-uncased");
textStr = string(textStr);
N = numel(textStr);
mb = 64;
E = zeros(N, 384, 'single');
for s = 1:mb:N
    e = min(N, s+mb-1);
    enc = encode(tok, textStr(s:e), 'Padding','longest','Truncation','longest');
    ids = enc.InputIDs; mask = enc.AttentionMask;
    if size(ids,2) > maxLen, ids = ids(:,1:maxLen); mask = mask(:,1:maxLen); end
    ids = dlarray(gpuArray(int32(ids)),'CB'); mask = dlarray(gpuArray(int32(mask)),'CB');
    out = predict(base, ids, mask);
    Z = pooled(out);
    Z = predict(head, Z);
    Z = gather(extractdata(Z))';
    n = vecnorm(Z,2,2); n(n==0)=1; Z = Z ./ n;
    E(s:e,:) = single(Z);
end
posSets = cell(N,1);
for i=1:N
    labs = Ylogical(i,:);
    pos = find(any(Ylogical(:,labs),2)); pos(pos==i) = [];
    posSets{i} = pos;
end
[recall10, mAP] = reg.eval_retrieval(E, posSets, 10);
ndcg10 = reg.metrics_ndcg(E*E.', posSets, 10);
metrics = struct('recall10', recall10, 'mAP', mAP, 'ndcg10', ndcg10);
end
