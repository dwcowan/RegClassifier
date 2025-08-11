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

% Negatives: disjoint labels
negMask = ~labelsLogical;
trip = zeros(3,0,'uint32');
for i = 1:N
    Pset = posSets{i};
    if numel(Pset) < R.MinPosPerAnchor, continue; end
    % pick one positive at random
    pidx = Pset(randi(numel(Pset)));
    % negatives: rows that share no label with the anchor
    negCandidates = find(all(negMask(i,:) | ~negMask, 2)); % rows with all ~labels(i,:)
    % more robust: true negatives are rows where (labelsLogical(i,:) & labelsLogical(j,:))==0
    overlap = labelsLogical * labelsLogical(i,:)';
    negCandidates = find(overlap==0);
    negCandidates(negCandidates==i) = [];
    if isempty(negCandidates), continue; end
    nidx = negCandidates(randi(numel(negCandidates)));
    trip(:,end+1) = uint32([i; pidx; nidx]); %#ok<AGROW>
    if size(trip,2) >= R.MaxTriplets, break; end
end
P.anchor = trip(0+1,:);
P.positive = trip(1+1,:);
P.negative = trip(2+1,:);
end
