function P = build_pairs(labelsLogical, varargin)
%BUILD_PAIRS Construct (anchor, positive, negative) indices for contrastive training.
% labelsLogical : [N x K] logical matrix where true means chunk has label k
% Optional name-value:
%   'MinPosPerAnchor' (default 1), 'MaxTriplets' (default 200000), 'Seed' (default 42)
p = inputParser;
addParameter(p,'MinPosPerAnchor',1,@(x)x>=1);
addParameter(p,'MaxTriplets',200000,@(x)x>=1);
addParameter(p,'Seed',42,@(x)isnumeric(x));
parse(p,varargin{:});
R = p.Results;

rng(R.Seed);
N = size(labelsLogical,1);
% Precompute positive sets for each anchor (share at least one label)
posSets = cell(N,1);
for i = 1:N
    labs = labelsLogical(i,:);
    if ~any(labs)
        posSets{i} = []; continue;
    end
    posSets{i} = find(any(labelsLogical(:,labs), 2));
    posSets{i}(posSets{i}==i) = []; % remove self
end

% Negatives: choose rows that share no label with the anchor
% Pre-allocate for performance (avoid array growing in loop)
trip = zeros(3, R.MaxTriplets, 'uint32');
count = 0;
for i = 1:N
    Pset = posSets{i};
    if numel(Pset) < R.MinPosPerAnchor, continue; end
    % pick one positive at random
    pidx = Pset(randi(numel(Pset)));
    % negatives: compute label overlap and keep rows with zero intersection
    overlap = labelsLogical * labelsLogical(i,:)'; % count shared labels
    negCandidates = find(overlap==0);
    negCandidates(negCandidates==i) = [];
    if isempty(negCandidates), continue; end
    nidx = negCandidates(randi(numel(negCandidates)));
    count = count + 1;
    trip(:,count) = uint32([i; pidx; nidx]);
    if count >= R.MaxTriplets, break; end
end
% Trim to actual count
trip = trip(:, 1:count);

% Warn if too few triplets created
if count < 100 && N > 100
    warning('Only %d triplets created from %d items. Check label distribution.', count, N);
end
if count == 0
    error('No triplets created. Labels may be too sparse or all items share all labels.');
end

P.anchor = trip(1,:);
P.positive = trip(2,:);
P.negative = trip(3,:);
end
