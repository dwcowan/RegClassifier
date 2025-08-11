function pngPath = plot_coretrieval_heatmap(M, labels, pngPath)
%PLOT_CORETRIEVAL_HEATMAP Save a heatmap of label co-retrieval matrix (rows sum to 1)
fig = figure('Visible','off');
imagesc(M);
axis tight; colorbar;
title('Label Co-Retrieval (Top-K)');
xlabel('Retrieved Label'); ylabel('Query Label');
set(gca,'XTick',1:numel(labels),'XTickLabel',labels,'XTickLabelRotation',45);
set(gca,'YTick',1:numel(labels),'YTickLabel',labels);
exportgraphics(fig, pngPath);
close(fig);
end
