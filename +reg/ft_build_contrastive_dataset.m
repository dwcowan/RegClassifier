function P = ft_build_contrastive_dataset(chunksT, Ylogical, varargin)
%FT_BUILD_CONTRASTIVE_DATASET Build triplets for encoder fine-tuning.
% Positives: share at least one label OR same doc section (heuristic via doc_id)
% Negatives: share no labels with anchor (or different doc_id as fallback)
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
hasLabels = any(labels, 2);  % which chunks have any label at all
posSets = cell(N,1);

% Build positives: same label or same doc_id (sectional continuity)
for i = 1:N
    labs = labels(i,:);
    if any(labs)
        pos = find(any(labels(:,labs),2));
    else
        pos = [];
    end
    pos(pos==i) = [];
    if ismember('doc_id', chunksT.Properties.VariableNames)
        sameDoc = find(chunksT.doc_id == chunksT.doc_id(i));
        pos = union(pos, sameDoc(sameDoc~=i));
    end
    posSets{i} = pos;
end

% Build negatives: no shared labels (fallback: different doc_id)
% Pre-allocate for performance (avoid array growing in loop)
trip = zeros(3, R.MaxTriplets, 'uint32');
count = 0;
for i = 1:N
    pos = posSets{i};
    if numel(pos) < R.MinPosPerAnchor, continue; end
    pidx = pos(randi(numel(pos)));

    % Try to find negative: no shared labels with anchor
    if any(labels(i,:))
        overlap = labels * labels(i,:)';
        negCandidates = find(overlap==0 & (1:N)'~=i);
    else
        negCandidates = [];
    end

    % Fallback: if no strict negatives, use chunks from different documents
    if isempty(negCandidates) && ismember('doc_id', chunksT.Properties.VariableNames)
        diffDoc = find(chunksT.doc_id ~= chunksT.doc_id(i));
        diffDoc(diffDoc == i) = [];
        negCandidates = diffDoc;
    end

    % Fallback: any chunk that is not the anchor or positive
    if isempty(negCandidates)
        allIdx = (1:N)';
        allIdx([i; pidx]) = [];
        if ~isempty(allIdx)
            negCandidates = allIdx;
        end
    end

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
    warning('Only %d triplets created from %d chunks. Check label distribution.', count, N);
end
if count == 0
    error('No triplets created. Labels may be too sparse or all items share all labels.');
end

P.anchor = trip(1,:); P.positive = trip(2,:); P.negative = trip(3,:);
end
