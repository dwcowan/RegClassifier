function P = ft_build_contrastive_dataset(chunksT, Ylogical, varargin)
%FT_BUILD_CONTRASTIVE_DATASET Build triplets for encoder fine-tuning.
% Positives: share at least one label OR same doc section (heuristic via doc_id)
% Negatives: share no labels with anchor
% Optional NV: 'MaxTriplets'(300000), 'Seed'(42), 'MinPosPerAnchor'(1)
p = inputParser;
addParameter(p,'MaxTriplets',300000,@(x)x>=1);
addParameter(p,'Seed',42);
addParameter(p,'MinPosPerAnchor',1);
parse(p,varargin{:});
R = p.Results;

rng(R.Seed);
N = height(chunksT);
labels = logical(Ylogical);
posSets = cell(N,1);

% Build positives: same label or same doc_id (sectional continuity)
for i = 1:N
    labs = labels(i,:);
    pos = find(any(labels(:,labs),2));
    pos(pos==i) = [];
    sameDoc = find(chunksT.doc_id == chunksT.doc_id(i));
    pos = union(pos, sameDoc(sameDoc~=i));
    posSets{i} = pos;
end

% Build negatives: no shared labels
trip = zeros(3,0,'uint32');
for i = 1:N
    pos = posSets{i};
    if numel(pos) < R.MinPosPerAnchor, continue; end
    pidx = pos(randi(numel(pos)));
    overlap = labels * labels(i,:)';
    negCandidates = find(overlap==0 & (1:N)'~=i);
    if isempty(negCandidates), continue; end
    nidx = negCandidates(randi(numel(negCandidates)));
    trip(:,end+1) = uint32([i; pidx; nidx]); %#ok<AGROW>
    if size(trip,2) >= R.MaxTriplets, break; end
end
P.anchor = trip(1,:); P.positive = trip(2,:); P.negative = trip(3,:);
end
