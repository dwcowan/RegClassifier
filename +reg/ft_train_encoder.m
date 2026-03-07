function netFT = ft_train_encoder(chunksT, P, varargin)
%FT_TRAIN_ENCODER Contrastive fine-tuning of BERT encoder (MATLAB R2025b)
% Name-Value params (defaults read from params.json > FineTune when available):
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

% --- Load params.json for defaults (resolve relative to project root) ---
params = struct();
paramsPath_ = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'params.json');
if isfile(paramsPath_)
    try
        params = jsondecode(fileread(paramsPath_));
    catch ME
        warning('Failed to read params.json: %s', ME.message);
    end
end
ft = struct();
if isfield(params,'FineTune'), ft = params.FineTune; end

% Helper: override default only if field exists and is non-empty (JSON null decodes to [])
    function v = nonnull(s, f, default)
        if isfield(s, f) && ~isempty(s.(f)), v = s.(f); else, v = default; end
    end

defBatchSize      = nonnull(ft, 'BatchSize', 32);
defUnfreeze       = nonnull(ft, 'UnfreezeTopLayers', 4);
defEncLR          = nonnull(ft, 'EncoderLR', 1e-5);
defHeadLR         = nonnull(ft, 'HeadLR', 1e-3);
defEpochs         = nonnull(ft, 'Epochs', 4);
defLoss           = nonnull(ft, 'Loss', 'triplet');
defMaxSeqLen      = nonnull(params, 'MaxSeqLength', 256);
defMargin         = nonnull(ft, 'Margin', 0.2);
defUseFP16        = nonnull(ft, 'UseFP16', false);
defCheckpointDir  = nonnull(ft, 'CheckpointDir', 'checkpoints');
defResume         = nonnull(ft, 'Resume', true);
defEarlyStopPatience  = nonnull(ft, 'EarlyStopPatience', 2);
defEarlyStopMinDelta  = nonnull(ft, 'EarlyStopMinDelta', 0.01);
defEvalY          = nonnull(ft, 'EvalY', []);
defEvalEvery      = nonnull(ft, 'EvalEvery', 1);
defHardNegatives  = nonnull(ft, 'HardNegatives', true);
defHardNegMaxN    = nonnull(ft, 'HardNegMaxN', 2000);
defYboot          = nonnull(ft, 'Yboot', []);

% --- Parse inputs ---
p = inputParser;
addParameter(p,'Epochs',defEpochs);
addParameter(p,'BatchSize',defBatchSize);
addParameter(p,'MaxSeqLength',defMaxSeqLen);
addParameter(p,'EncoderLR',defEncLR);
addParameter(p,'HeadLR',defHeadLR);
addParameter(p,'Margin',defMargin);
addParameter(p,'UnfreezeTopLayers',defUnfreeze);
addParameter(p,'UseFP16',defUseFP16);
addParameter(p,'Loss',defLoss,@(s)any(strcmpi(s,{'triplet','supcon'})));
addParameter(p,'CheckpointDir',defCheckpointDir,@ischar);
addParameter(p,'Resume',defResume,@islogical);
addParameter(p,'EarlyStopPatience',defEarlyStopPatience);
addParameter(p,'EarlyStopMinDelta',defEarlyStopMinDelta);  % 1 percentage point
addParameter(p,'EvalY',defEvalY);                % logical labels for eval
addParameter(p,'EvalEvery',defEvalEvery);             % epochs
addParameter(p,'HardNegatives',defHardNegatives);
addParameter(p,'HardNegMaxN',defHardNegMaxN);        % mine on subset if corpus is huge
addParameter(p,'Yboot',defYboot);                % optional weak labels for hard-negative mining
parse(p,varargin{:});
R = p.Results;

assert(gpuDeviceCount > 0, 'GPU required for fine-tuning');

% Initialize BERT model and tokenizer (R2025b API)
% In R2025b, bert() returns both network and tokenizer together
try
    [base, tok] = bert(Model="base");
catch ME1
    % Fallback for older MATLAB versions
    try
        [base, tok] = bert();
    catch ME2
        error('RegClassifier:BERTNotAvailable', ...
            ['Failed to initialize BERT model and tokenizer.\n' ...
             'BERT is included by default in MATLAB R2025b+.\n' ...
             'For earlier versions, run: supportPackageInstaller\n\n' ...
             'Errors:\n' ...
             '  bert(Model="base"): %s\n' ...
             '  bert(): %s'], ...
            ME1.message, ME2.message);
    end
end

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
    for idx = 1:numel(ids)
        if ~isempty(ids{idx})
            % Use standard parenthesis indexing for numeric arrays.
            % Prior versions mistakenly used square brackets, leading to a
            % syntax error in MATLAB.
            layerNums(idx) = str2double(ids{idx}{end});
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
if ~isfolder(R.CheckpointDir)
    [success, msg] = mkdir(R.CheckpointDir);
    if ~success
        error('reg:ft_train_encoder:CheckpointDirFailed', ...
            'Failed to create checkpoint directory: %s', msg);
    end
end
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
                [A, Pp, Nn] = localMineNegatives(tok, base, head, chunksT, R.Yboot, A, Pp, Nn, R.MaxSeqLength, R.HardNegMaxN);
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
                [loss, gE, gH] = dlfeval(@gradTripletBatch, base, head, tok, chunksT, aIdx, pIdx, nIdx, R.MaxSeqLength, R.UseFP16, R.Margin);
            case 'supcon'
                % Build two views per anchor: view1 = anchor, view2 = positive; negatives provided as usual
                [loss, gE, gH] = dlfeval(@gradSupConBatch, base, head, tok, chunksT, aIdx, pIdx, R.MaxSeqLength, R.UseFP16);
        end

        % Zero grads for frozen encoder params
        if any(~encLearnMask)
            for gi = 1:height(gE)
                if ~encLearnMask(gi), gE.Value{gi}(:) = 0; end
            end
        end

        % AdamW updates: Adam step + decoupled weight decay
        wd = 0.01;
        [base, taE, ta2E] = adamupdate(base, gE, taE, ta2E, iter, R.EncoderLR, 0.9, 0.999);
        [head, taH, ta2H] = adamupdate(head, gH, taH, ta2H, iter, R.HeadLR, 0.9, 0.999);
        % Decoupled weight decay (applied after Adam step, per Loshchilov & Hutter 2019).
        % The decay factor is (1 - wd) independent of learning rate — this is
        % what makes AdamW "decoupled". Coupling decay to LR (the previous bug)
        % under-regularised the encoder (low LR) and over-regularised the head.
        % Skip bias parameters — standard practice is to only decay weights.
        for wi = 1:height(base.Learnables)
            if ~contains(string(base.Learnables.Parameter(wi)), "Bias")
                base.Learnables.Value{wi} = base.Learnables.Value{wi} * (1 - wd);
            end
        end
        for wi = 1:height(head.Learnables)
            if ~contains(string(head.Learnables.Parameter(wi)), "Bias")
                head.Learnables.Value{wi} = head.Learnables.Value{wi} * (1 - wd);
            end
        end

        lossEpoch = lossEpoch + double(gather(extractdata(loss)));
    end
    fprintf("FT Epoch %d/%d [%s] - loss: %.4f\n", epoch, R.Epochs, upper(R.Loss), lossEpoch/itersPerEpoch);

    % End-of-epoch evaluation & early stopping
    if ~isempty(R.EvalY) && mod(epoch, R.EvalEvery)==0
        try
            metrics = localEvaluate(tok, base, head, chunksT.text, R.EvalY, R.MaxSeqLength);
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

% Ensure all GPU operations complete
if gpuDeviceCount > 0
    wait(gpuDevice);
end
end

% === Helpers ===
function [loss, gE, gH] = gradTripletBatch(base, head, tok, chunksT, aIdx, pIdx, nIdx, maxLen, useFP16, margin)
B = numel(aIdx);
% Re-encode batch texts from chunksT table
batchTexts = [chunksT.text(aIdx); chunksT.text(pIdx); chunksT.text(nIdx)];
[tokenCodes, ~] = encode(tok, batchTexts);  % R2025b: returns cell arrays
% Manually pad sequences to maxLen (R2025b encode doesn't auto-pad)
paddingCode = double(tok.PaddingCode);
numSeqs = numel(tokenCodes);
X = paddingCode * ones(numSeqs, maxLen);  % Pre-fill with padding
for i = 1:numSeqs
    seq = double(tokenCodes{i});
    len = min(numel(seq), maxLen);
    X(i, 1:len) = seq(1:len);
end
M = double(X ~= paddingCode);  % Attention mask: 1 for real tokens, 0 for padding
% Select precision: FP16 halves GPU memory usage at slight accuracy cost
if useFP16, castFn = @half; else, castFn = @single; end
% Reshape to 3D (1, maxLen, B) 'CTB' format for BERT sequenceInputLayer (C=1)
Xa = dlarray(gpuArray(castFn(permute(X(1:B,:), [3,2,1]))),'CTB');
Xp = dlarray(gpuArray(castFn(permute(X(B+1:2*B,:), [3,2,1]))),'CTB');
Xn = dlarray(gpuArray(castFn(permute(X(2*B+1:end,:), [3,2,1]))),'CTB');
% Segment IDs (all ones for single-segment input; MATLAB embedding uses 1-based indexing)
Sa = dlarray(gpuArray(castFn(ones(1, maxLen, B))),'CTB');
Sp = Sa; Sn = Sa;
Ma = dlarray(gpuArray(castFn(permute(M(1:B,:), [3,2,1]))),'CTB');
Mp = dlarray(gpuArray(castFn(permute(M(B+1:2*B,:), [3,2,1]))),'CTB');
Mn = dlarray(gpuArray(castFn(permute(M(2*B+1:end,:), [3,2,1]))),'CTB');

oA = forward(base, Xa, Sa, Ma); oP = forward(base, Xp, Sp, Mp); oN = forward(base, Xn, Sn, Mn);
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

function [loss, gE, gH] = gradSupConBatch(base, head, tok, chunksT, aIdx, pIdx, maxLen, useFP16)
% Supervised contrastive (NT-Xent) with two positives per "class" (anchor ~ positive)
B = numel(aIdx);
% Re-encode batch texts from chunksT table
batchTexts = [chunksT.text(aIdx); chunksT.text(pIdx)];
[tokenCodes, ~] = encode(tok, batchTexts);  % R2025b: returns cell arrays
% Manually pad sequences to maxLen (R2025b encode doesn't auto-pad)
paddingCode = double(tok.PaddingCode);
numSeqs = numel(tokenCodes);
X = paddingCode * ones(numSeqs, maxLen);  % Pre-fill with padding
for i = 1:numSeqs
    seq = double(tokenCodes{i});
    len = min(numel(seq), maxLen);
    X(i, 1:len) = seq(1:len);
end
M = double(X ~= paddingCode);  % Attention mask: 1 for real tokens, 0 for padding
B2 = size(X,1) - B;
% Select precision: FP16 halves GPU memory usage at slight accuracy cost
if useFP16, castFn = @half; else, castFn = @single; end
% Reshape to 3D (1, maxLen, B) 'CTB' format for BERT sequenceInputLayer (C=1)
X1 = dlarray(gpuArray(castFn(permute(X(1:B,:), [3,2,1]))),'CTB');
M1 = dlarray(gpuArray(castFn(permute(M(1:B,:), [3,2,1]))),'CTB');
X2 = dlarray(gpuArray(castFn(permute(X(B+1:end,:), [3,2,1]))),'CTB');
M2 = dlarray(gpuArray(castFn(permute(M(B+1:end,:), [3,2,1]))),'CTB');
% Segment IDs (all ones for single-segment input; MATLAB embedding uses 1-based indexing)
S1 = dlarray(gpuArray(castFn(ones(1, maxLen, B))),'CTB');
S2 = dlarray(gpuArray(castFn(ones(1, maxLen, B2))),'CTB');

o1 = forward(base, X1, S1, M1); o2 = forward(base, X2, S2, M2);
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
% Uses log-sum-exp trick for numerical stability with small tau
tau = 0.07;
S = (Z.' * Z) / tau;          % cosine/tau since Z is normalized
S = S - inf * eye(size(S));   % mask out self-similarity with -inf so exp(-inf)=0
lossSum = dlarray(0.0);
count = 0;
for i = 1:B
    pos1 = S(i, i+B);
    % log-sum-exp: log(sum(exp(x))) = max(x) + log(sum(exp(x - max(x))))
    row1 = S(i,:);
    mx1 = max(row1);
    logdenom1 = mx1 + log(sum(exp(row1 - mx1)));
    l1 = -(pos1 - logdenom1);

    pos2 = S(i+B, i);
    row2 = S(i+B,:);
    mx2 = max(row2);
    logdenom2 = mx2 + log(sum(exp(row2 - mx2)));
    l2 = -(pos2 - logdenom2);

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

function Z = l2norm(Z)
n = sqrt(sum(Z.^2,1) + 1e-9);
Z = Z ./ n;
end

function [Aout, Pout, Nout] = localMineNegatives(tok, base, head, chunksT, Yboot, A, P, N, maxLen, maxN)
% Mine hard negatives using current encoder: closest items with different labels
Nall = height(chunksT);
subset = 1:Nall;
if Nall > maxN
    subset = sort(randperm(Nall, maxN));
end
Nsub = numel(subset);
texts = string(chunksT.text(subset));

% Mini-batch BERT inference to avoid GPU OOM
mb = 64;
Z_all = [];
for bs = 1:mb:Nsub
    be = min(Nsub, bs+mb-1);
    batchTexts = texts(bs:be);
    [tokenCodes, ~] = encode(tok, batchTexts);
    paddingCode = double(tok.PaddingCode);
    numSeqs = numel(tokenCodes);
    ids = paddingCode * ones(numSeqs, maxLen);
    for i = 1:numSeqs
        seq = double(tokenCodes{i});
        len = min(numel(seq), maxLen);
        ids(i, 1:len) = seq(1:len);
    end
    mask = double(ids ~= paddingCode);
    ids = dlarray(gpuArray(single(permute(ids, [3,2,1]))),'CTB');
    segs = dlarray(gpuArray(single(ones(1, maxLen, numSeqs))),'CTB');
    mask = dlarray(gpuArray(single(permute(mask, [3,2,1]))),'CTB');
    out = predict(base, ids, segs, mask);
    Z = pooled(out);
    Z = predict(head, Z);
    Z = gather(extractdata(Z))';
    nm = vecnorm(Z,2,2); nm(nm==0)=1; Z = Z ./ nm;
    if isempty(Z_all)
        Z_all = zeros(Nsub, size(Z,2), 'single');
    end
    Z_all(bs:be,:) = single(Z);
end

% Compute similarity only over the subset
S_sub = Z_all * Z_all.';

% Precompute label overlap mask using matrix multiply (vectorized, replaces O(Nsub²) loop)
Ysub = Yboot(subset, :);  % Nsub × K
labelOverlap = (Ysub * Ysub') > 0;  % Nsub × Nsub: true if any shared label

% Apply mask: set self-similarity and same-label pairs to -inf
S_sub(logical(eye(Nsub))) = -inf;
S_sub(labelOverlap) = -inf;

Aout = A; Pout = P; Nout = N;
for si = 1:Nsub
    gi = subset(si);
    if ~any(Yboot(gi,:)), continue; end
    [~, ord] = sort(S_sub(si,:),'descend');
    % Filter to valid negatives (score > -inf)
    validNeg = ord(S_sub(si, ord) > -inf);
    if isempty(validNeg), continue; end
    % Assign different hard negatives to each triplet for this anchor
    tripIdx = find(A==gi);
    nTrips = numel(tripIdx);
    nValid = numel(validNeg);
    for ti = 1:nTrips
        Nout(tripIdx(ti)) = subset(validNeg(min(ti, nValid)));
    end
end
end

function metrics = localEvaluate(tok, base, head, textStr, Ylogical, maxLen)
textStr = string(textStr);
N = numel(textStr);
mb = 64;
% Detect projection dimension from head network output layer
projDim = head.Layers(end).OutputSize;
E = zeros(N, projDim, 'single');
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
    out = predict(base, ids, segs, mask);
    Z = pooled(out);
    Z = predict(head, Z);
    Z = gather(extractdata(Z))';
    n = vecnorm(Z,2,2); n(n==0)=1; Z = Z ./ n;
    E(s:e,:) = single(Z);
end
posSets = cell(N,1);
for i=1:N
    labCols = find(Ylogical(i,:));
    pos = find(any(Ylogical(:,labCols),2)); pos(pos==i) = [];
    posSets{i} = pos;
end
[recall10, mAP] = reg.eval_retrieval(E, posSets, 10);
ndcg10 = reg.metrics_ndcg(E, posSets, 10);
metrics = struct('recall10', recall10, 'mAP', mAP, 'ndcg10', ndcg10);
end
