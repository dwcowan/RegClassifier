% Evaluate model quality on the gold mini-pack and write a PDF report
import mlreportgen.report.*
import mlreportgen.dom.*
% TODO: set random seeds for reproducibility
% reg.set_seeds(42);
G = reg.load_gold("gold");

% Build embeddings (auto-uses fine_tuned_bert.mat or projection_head if present)
C = config();
C.labels = G.labels;  % align label set
chunksT = G.chunks;
E = reg.precompute_embeddings(chunksT.text, C);

% Calculate metrics (overall)
posSets = cell(height(chunksT),1);
for i=1:height(chunksT)
    labs = G.Y(i,:);
    pos = find(any(G.Y(:,labs),2)); pos(pos==i) = [];
    posSets{i} = pos;
end
[recall10, mAP] = reg.eval_retrieval(E, posSets, 10);
ndcg10 = reg.metrics_ndcg(E*E.', posSets, 10);
per = reg.eval_per_label(E, G.Y, 10);

% Report
r = Report('gold_eval_report','pdf');
append(r, TitlePage('Title', 'Gold Mini-Pack Evaluation'));
append(r, TableOfContents);
sec = Section('Overall');
T = table(["Recall@10";"mAP";"nDCG@10"], [recall10; mAP; ndcg10], 'VariableNames', {'Metric','Value'});
append(sec, FormalTable(T));
append(r, sec);

sec2 = Section('Per-Label Recall@10');
tbl = table(G.labels(:), per.RecallAtK, 'VariableNames', {'Label','RecallAt10'});
append(sec2, FormalTable(tbl));
append(r, sec2);

close(r);
fprintf('Wrote gold report: %s\n', r.OutputPath);
