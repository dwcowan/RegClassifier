function results = test_claude_annotator()
%TEST_CLAUDE_ANNOTATOR Validate Claude-as-annotator against gold pack.
%
% This script:
%   1. Loads gold chunks (text only, no labels)
%   2. Loads gold labels as ground truth
%   3. Prepares chunks for Claude annotation (via LLM)
%   4. Compares Claude labels to gold labels
%   5. Computes inter-rater reliability metrics
%
% Returns:
%   results - struct with:
%     .kappa - Overall Cohen's kappa
%     .per_label_metrics - precision, recall, F1 per label
%     .disagreements - table of chunks where Claude != gold
%     .confusion - confusion matrices per label

%% Load gold pack data
gold_dir = 'gold';
chunks_file = fullfile(gold_dir, 'sample_gold_chunks.csv');
labels_file = fullfile(gold_dir, 'sample_gold_labels.json');
ytrue_file = fullfile(gold_dir, 'sample_gold_Ytrue.csv');

% Read chunks
chunks_tbl = readtable(chunks_file, 'TextType', 'string');
fprintf('✅ Loaded %d chunks from %s\n', height(chunks_tbl), chunks_file);

% Read label definitions
labels_json = fileread(labels_file);
labels_data = jsondecode(labels_json);
label_names = labels_data.labels;
synonyms = labels_data.synonyms;

fprintf('✅ Labels: %s\n', strjoin(label_names, ', '));

% Read ground truth (Y_true matrix)
Y_true = readmatrix(ytrue_file);
fprintf('✅ Ground truth: %d chunks × %d labels\n', size(Y_true, 1), size(Y_true, 2));

% Verify dimensions
assert(height(chunks_tbl) == size(Y_true, 1), 'Chunk count mismatch');
assert(length(label_names) == size(Y_true, 2), 'Label count mismatch');

%% Create annotation instructions for Claude
fprintf('\n=== ANNOTATION INSTRUCTIONS FOR CLAUDE ===\n\n');

fprintf('You will annotate %d regulatory text chunks with these labels:\n\n', height(chunks_tbl));

for i = 1:length(label_names)
    label = label_names{i};
    syns = synonyms.(label);
    fprintf('**%s**\n', label);
    fprintf('  Key terms: %s\n', strjoin(syns(1:min(10, length(syns))), ', '));
    fprintf('  Assign 1 if chunk discusses %s, else 0\n\n', label);
end

fprintf('**Multi-label:** A chunk can have 0, 1, or multiple labels.\n');
fprintf('**Noise chunks:** If chunk does not match ANY label, assign all zeros.\n\n');

fprintf('=== CHUNKS TO ANNOTATE ===\n\n');

% Display chunks for annotation
for i = 1:height(chunks_tbl)
    fprintf('--- Chunk %d (ID: %s) ---\n', i, chunks_tbl.chunk_id{i});
    fprintf('%s\n\n', chunks_tbl.text{i});
    fprintf('Labels (IRB, Liquidity_LCR, AML_KYC, Securitisation, LeverageRatio):\n');
    fprintf('[Provide your labels as: 0,1,0,0,0]\n\n');
end

fprintf('=== END CHUNKS ===\n\n');

%% Prepare export for manual annotation
% Create CSV with blank label columns for Claude to fill
annotation_tbl = table(chunks_tbl.chunk_id, chunks_tbl.text, ...
    'VariableNames', {'chunk_id', 'text'});

% Add blank label columns
for i = 1:length(label_names)
    annotation_tbl.(label_names{i}) = nan(height(annotation_tbl), 1);
end

export_file = fullfile(gold_dir, 'chunks_for_claude_annotation.csv');
writetable(annotation_tbl, export_file);

fprintf('✅ Exported annotation template to:\n   %s\n\n', export_file);
fprintf('📋 Next steps:\n');
fprintf('   1. Claude annotates each chunk (fill in 0/1 for each label)\n');
fprintf('   2. Save as: gold/claude_annotations.csv\n');
fprintf('   3. Run: results = compare_claude_vs_gold()\n\n');

% Return data for comparison function
results = struct();
results.chunks = chunks_tbl;
results.Y_true = Y_true;
results.label_names = label_names;
results.synonyms = synonyms;

end
