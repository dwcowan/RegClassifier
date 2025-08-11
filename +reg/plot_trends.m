function pngPath = plot_trends(csvPath, pngPath)
%PLOT_TRENDS Read runs/metrics.csv and produce trend lines for Recall@10, mAP, nDCG@10
T = readtable(csvPath);
% Keep only desired metrics
keep = ismember(T.metric, {'RecallAt10','mAP','nDCG@10','recallAt10','ndcg','nDCG'});
T = T(keep,:);
% Normalize metric names
T.metric = strrep(T.metric, 'recallAt10','RecallAt10');
T.metric = strrep(T.metric, 'nDCG','nDCG@10');
T.metric = strrep(T.metric, 'ndcg','nDCG@10');

fig = figure('Visible','off');
hold on;
uVar = unique(T.variant,'stable');
markers = {'o','x','s','d','^','v','>','<','p','h'};
mk = 1;
for v = 1:numel(uVar)
    for m = ["RecallAt10","mAP","nDCG@10"]
        mask = T.variant==uVar(v) & T.metric==m;
        if ~any(mask), continue; end
        x = T.epoch(mask);
        y = T.value(mask);
        plot(x, y, '-', 'DisplayName', sprintf('%s - %s', uVar(v), m), 'Marker', markers{mk});
        mk = mk + 1; if mk>numel(markers), mk=1; end
    end
end
xlabel('Epoch / Checkpoint'); ylabel('Metric value');
title('Retrieval Metrics Over Time');
legend('Location','bestoutside');
hold off;
exportgraphics(fig, pngPath);
close(fig);
end
