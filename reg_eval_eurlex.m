%REG_EVAL_EURLEX Evaluate model on EUR-Lex benchmark dataset
%
%   Evaluates the RegClassifier system on EUR-Lex financial regulation
%   documents with EUROVOC labels mapped to regulatory topics.
%
%   WORKFLOW:
%   1. Load EUR-Lex data with EUROVOC-to-regulatory mapping
%   2. Generate embeddings (auto-detects best available model)
%   3. Evaluate retrieval metrics (Recall@K, mAP, nDCG)
%   4. Generate PDF report with per-label breakdowns
%
%   REQUIREMENTS:
%   - EUR-Lex data file (JSON/JSONL) in data/eurlex/
%   - EUROVOC mapping: data/eurovoc_regulatory_mapping.json
%
%   CONFIGURATION:
%   Edit paths below to point to your EUR-Lex data file.
%
%   OUTPUTS:
%   - eurlex_eval_report.pdf - Evaluation report with metrics
%   - Console output with summary statistics
%
%   See also: reg.load_eurlex, reg_eval_gold, reg.eval_retrieval

import mlreportgen.report.*
import mlreportgen.dom.*

%% Configuration
% Path to EUR-Lex data (update this to your data file)
eurlexDataPath = "data/eurlex/eurlex_samples.json";
mappingPath = "data/eurovoc_regulatory_mapping.json";

% Evaluation parameters
maxDocs = 100;  % Limit for testing (set to Inf for full dataset)
K = 10;  % Top-K for retrieval metrics

fprintf('=== EUR-Lex Benchmark Evaluation ===\n\n');

%% 1. Load EUR-Lex data
fprintf('[1/4] Loading EUR-Lex data...\n');

if ~isfile(eurlexDataPath)
    error(['EUR-Lex data file not found: %s\n' ...
           'Please download EUR-Lex data or update eurlexDataPath variable.\n' ...
           'See: https://huggingface.co/datasets/nlpaueb/multi_eurlex'], ...
           eurlexDataPath);
end

if ~isfile(mappingPath)
    error('EUROVOC mapping file not found: %s', mappingPath);
end

[chunksT, labels, metadata] = reg.load_eurlex(eurlexDataPath, mappingPath, ...
    'MaxDocs', maxDocs, ...
    'ChunkSize', 300, ...
    'ChunkOverlap', 80, ...
    'FilterFinancial', true);

fprintf('  ✓ Loaded %d chunks from %d documents\n', ...
    metadata.num_chunks, metadata.num_docs);
fprintf('  ✓ Labels: %s\n', strjoin(labels.labels, ', '));

%% 2. Generate embeddings
fprintf('[2/4] Generating embeddings...\n');

C = config();
C.labels = labels.labels;  % Use EUR-Lex labels

E = reg.precompute_embeddings(chunksT.text, C);

fprintf('  ✓ Embeddings shape: %d x %d\n', size(E, 1), size(E, 2));

%% 3. Evaluate retrieval metrics
fprintf('[3/4] Evaluating retrieval metrics...\n');

% Build positive sets for each chunk (chunks with same labels)
posSets = cell(height(chunksT), 1);
for i = 1:height(chunksT)
    labs = labels.Y(i, :);
    if sum(labs) == 0
        posSets{i} = [];  % No labels for this chunk
        continue;
    end

    % Find all other chunks that share at least one label
    pos = find(any(labels.Y(:, labs), 2));
    pos(pos == i) = [];  % Exclude self
    posSets{i} = pos;
end

% Calculate retrieval metrics
[recall10, mAP] = reg.eval_retrieval(E, posSets, K);
ndcg10 = reg.metrics_ndcg(E * E.', posSets, K);

% Per-label evaluation
per = reg.eval_per_label(E, labels.Y, K);

fprintf('  ✓ Overall Metrics:\n');
fprintf('    - Recall@%d: %.4f\n', K, recall10);
fprintf('    - mAP:       %.4f\n', mAP);
fprintf('    - nDCG@%d:   %.4f\n', K, ndcg10);

%% 4. Generate report
fprintf('[4/4] Generating PDF report...\n');

r = Report('eurlex_eval_report', 'pdf');
append(r, TitlePage('Title', 'EUR-Lex Benchmark Evaluation', ...
    'Subtitle', sprintf('Evaluated on %d documents, %d chunks', ...
    metadata.num_docs, metadata.num_chunks)));
append(r, TableOfContents);

% Overall metrics section
sec1 = Section('Overall Retrieval Metrics');
overallTable = table(...
    ["Recall@10"; "mAP"; "nDCG@10"], ...
    [recall10; mAP; ndcg10], ...
    'VariableNames', {'Metric', 'Value'});
append(sec1, FormalTable(overallTable));

% Add comparison to gold pack thresholds
para1 = Paragraph(sprintf(...
    'Gold pack thresholds: Recall@10 ≥ 0.80, mAP ≥ 0.60, nDCG@10 ≥ 0.60'));
append(sec1, para1);

passStatus = table(...
    ["Recall@10"; "mAP"; "nDCG@10"], ...
    [recall10 >= 0.80; mAP >= 0.60; ndcg10 >= 0.60], ...
    'VariableNames', {'Metric', 'Passes_Threshold'});
append(sec1, FormalTable(passStatus));
append(r, sec1);

% Per-label metrics
sec2 = Section('Per-Label Recall@10');
perLabelTable = table(...
    labels.labels(:), ...
    per.RecallAtK, ...
    metadata.label_distribution(:), ...
    'VariableNames', {'Label', 'Recall_at_10', 'Num_Chunks'});
append(sec2, FormalTable(perLabelTable));
append(r, sec2);

% Dataset statistics
sec3 = Section('Dataset Statistics');
statsTable = table(...
    ["Total Documents"; "Total Chunks"; "Avg Chunks per Doc"; ...
     "Embedding Dimension"; "K (Top-K)"], ...
    [metadata.num_docs; metadata.num_chunks; ...
     metadata.num_chunks / metadata.num_docs; ...
     size(E, 2); K], ...
    'VariableNames', {'Statistic', 'Value'});
append(sec3, FormalTable(statsTable));

% Label distribution
para3 = Paragraph('Label Distribution Across Chunks:');
append(sec3, para3);
for i = 1:numel(labels.labels)
    pct = 100 * metadata.label_distribution(i) / metadata.num_chunks;
    para = Paragraph(sprintf('  %s: %d chunks (%.1f%%)', ...
        labels.labels{i}, metadata.label_distribution(i), pct));
    append(sec3, para);
end
append(r, sec3);

% Metadata section
sec4 = Section('Configuration');
configTable = table(...
    ["Data File"; "Mapping File"; "Max Documents"; "Chunk Size"; ...
     "Chunk Overlap"; "Min Confidence"], ...
    [string(eurlexDataPath); string(mappingPath); ...
     string(maxDocs); "300"; "80"; "0.5"], ...
    'VariableNames', {'Parameter', 'Value'});
append(sec4, FormalTable(configTable));
append(r, sec4);

close(r);
fprintf('  ✓ Report saved: %s\n', r.OutputPath);

%% Summary
fprintf('\n=== Evaluation Complete ===\n');
fprintf('Overall Performance:\n');
fprintf('  Recall@%d: %.4f %s\n', K, recall10, ...
    ternary(recall10 >= 0.80, '✓ PASS', '✗ FAIL'));
fprintf('  mAP:       %.4f %s\n', mAP, ...
    ternary(mAP >= 0.60, '✓ PASS', '✗ FAIL'));
fprintf('  nDCG@%d:   %.4f %s\n', K, ndcg10, ...
    ternary(ndcg10 >= 0.60, '✓ PASS', '✗ FAIL'));

fprintf('\nPer-Label Recall@%d:\n', K);
for i = 1:numel(labels.labels)
    fprintf('  %15s: %.4f (%d chunks)\n', labels.labels{i}, ...
        per.RecallAtK(i), metadata.label_distribution(i));
end

fprintf('\nReport: %s\n', r.OutputPath);

%% Helper function
function result = ternary(condition, trueVal, falseVal)
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end
