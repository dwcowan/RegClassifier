function head = train_projection_head(Ebase, P, varargin)
%TRAIN_PROJECTION_HEAD Train a small projection head on frozen embeddings.
% Ebase: [N x d] base embeddings (L2-normalized)
% P: struct with fields anchor, positive, negative (uint indices)
% Name-Values: 'ProjDim' (384), 'Epochs'(5), 'BatchSize'(512), 'LR'(1e-3), 'Margin'(0.2), 'UseGPU'(true)
p = inputParser;
addParameter(p,'ProjDim',384);
addParameter(p,'Epochs',5);
addParameter(p,'BatchSize',768);
addParameter(p,'LR',1e-3);
addParameter(p,'Margin',0.2);
addParameter(p,'UseGPU',true);
parse(p,varargin{:});
R = p.Results;

[N,d] = size(Ebase);
projDim = R.ProjDim;

% Define a tiny MLP head: d -> 512 -> projDim (ReLU), then L2 norm at inference
layers = [
    featureInputLayer(d, 'Normalization','none','Name','in')
    fullyConnectedLayer(512,'Name','fc1')
    reluLayer('Name','relu1')
    fullyConnectedLayer(projDim,'Name','fc2')
];
lgraph = layerGraph(layers);
head = dlnetwork(lgraph);

% Training setup
if R.UseGPU && canUseGPU, exec = 'gpu'; else, exec = 'cpu'; end
mb = R.BatchSize;
numTrip = numel(P.anchor);
itersPerEpoch = ceil(numTrip / mb);
trailingAvg = []; trailingAvgSq = [];
gradClip = 1.0;

for epoch = 1:R.Epochs
    idx = randperm(numTrip);
    lossEpoch = 0;
    for it = 1:itersPerEpoch
        s = (it-1)*mb + 1; e = min(numTrip, it*mb);
        a = double(P.anchor(idx(s:e)));
        p = double(P.positive(idx(s:e)));
        n = double(P.negative(idx(s:e)));
        Xa = Ebase(a,:); Xp = Ebase(p,:); Xn = Ebase(n,:);
        if exec=="gpu"
            Xa = gpuArray(single(Xa)); Xp = gpuArray(single(Xp)); Xn = gpuArray(single(Xn));
        else
            Xa = single(Xa); Xp = single(Xp); Xn = single(Xn);
        end
        [L, gradients] = dlfeval(@modelGradients, head, Xa, Xp, Xn, R.Margin);
        [head, trailingAvg, trailingAvgSq] = adamupdate(head, gradients, trailingAvg, trailingAvgSq, it + (epoch-1)*itersPerEpoch, R.LR, 0.9, 0.999);
        lossEpoch = lossEpoch + double(gather(extractdata(L)));
    end
    fprintf('Epoch %d/%d - loss: %.4f\n', epoch, R.Epochs, lossEpoch / itersPerEpoch);
end
end

function [loss, gradients] = modelGradients(net, Xa, Xp, Xn, margin)
% Forward
Za = forward(net, dlarray(Xa','CB'));  % [projDim x B]
Zp = forward(net, dlarray(Xp','CB'));
Zn = forward(net, dlarray(Xn','CB'));

% L2 normalize
Za = l2norm(Za); Zp = l2norm(Zp); Zn = l2norm(Zn);

% Cosine distances
dap = 1 - sum(Za .* Zp, 1);  % 1 - cosine
dan = 1 - sum(Za .* Zn, 1);

% Triplet loss
L = max(0, dap - dan + margin);
loss = mean(L, 'all');

% Gradients
gradients = dlgradient(loss, net.Learnables);
end

function Z = l2norm(Z)
% Normalize columns to unit length
n = sqrt(sum(Z.^2,1) + 1e-9);
Z = Z ./ n;
end
