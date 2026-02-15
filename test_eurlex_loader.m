%TEST_EURLEX_LOADER Quick test of EUR-Lex data loader
% This script tests the EUR-Lex loader and EUROVOC mapping

%% Test 1: Load EUR-Lex data
fprintf('Testing EUR-Lex loader...\n');

eurlexDataPath = "data/eurlex/eurlex_samples.json";
mappingPath = "data/eurovoc_regulatory_mapping.json";

try
    [chunks, labels, metadata] = reg.load_eurlex(eurlexDataPath, mappingPath, ...
        'MaxDocs', 10, ...
        'FilterFinancial', true);

    fprintf('✓ Loader test PASSED\n');
    fprintf('  - Loaded %d documents\n', metadata.num_docs);
    fprintf('  - Generated %d chunks\n', metadata.num_chunks);
    fprintf('  - Labels: %s\n', strjoin(labels.labels, ', '));
    fprintf('  - Label matrix shape: %d x %d\n', size(labels.Y, 1), size(labels.Y, 2));

    % Display label distribution
    fprintf('\nLabel Distribution:\n');
    for i = 1:numel(labels.labels)
        fprintf('  %15s: %d chunks (%.1f%%)\n', ...
            labels.labels{i}, ...
            metadata.label_distribution(i), ...
            100 * metadata.label_distribution(i) / metadata.num_chunks);
    end

    % Display first few chunks
    fprintf('\nFirst 3 chunks:\n');
    for i = 1:min(3, height(chunks))
        fprintf('  [%d] %s (doc %d, chunk %d)\n    %s...\n', ...
            i, chunks.celex_id(i), chunks.doc_id(i), chunks.chunk_id(i), ...
            extractBefore(chunks.text(i), 100));
    end

catch ME
    fprintf('✗ Loader test FAILED: %s\n', ME.message);
    rethrow(ME);
end

fprintf('\n✓ All tests passed!\n');
