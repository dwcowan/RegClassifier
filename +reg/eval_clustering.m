function S = eval_clustering(E, labelsLogical, Kclusters)
%EVAL_CLUSTERING k-means clustering + purity and silhouette score (approx)
% labelsLogical: [N x L] -> turn into single label by argmax for purity proxy
N = size(E,1);
if nargin<3, Kclusters = max(2, round(sqrt(N/10))); end
[idx, ~] = kmeans(E, Kclusters, 'MaxIter',200, 'Replicates',3, 'Distance','cosine');

% Purity (approx): assign each cluster its most common label (by argmax of labels)
[~, y] = max(labelsLogical, [], 2);  % choose a single label (ties arbitrary)
purity = 0;
for k = 1:Kclusters
    members = find(idx==k);
    if isempty(members), continue; end
    yk = y(members);
    maj = mode(yk);
    purity = purity + sum(yk==maj);
end
purity = purity / N;

% Silhouette (cosine) -- can be slow for big N; use subset if needed
try
    s = silhouette(E, idx, 'cosine');
    sil = mean(s);
catch
    sil = NaN;
end

S = struct('purity',purity,'silhouette',sil,'idx',idx);
end
