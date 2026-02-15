function [chunks, labels, metadata] = load_eurlex(dataPath, mappingPath, options)
%LOAD_EURLEX Load EUR-Lex dataset and map EUROVOC labels to regulatory topics.
%
%   [chunks, labels, metadata] = load_eurlex(dataPath, mappingPath)
%   [chunks, labels, metadata] = load_eurlex(__, Name, Value)
%
%   Loads EUR-Lex documents in JSON/JSONL format and converts EUROVOC labels
%   to RegClassifier regulatory topic labels (IRB, Liquidity_LCR, AML_KYC,
%   Securitisation, LeverageRatio).
%
%   INPUTS:
%       dataPath      - Path to EUR-Lex data file (JSON or JSONL format)
%       mappingPath   - Path to EUROVOC mapping file (JSON)
%
%   NAME-VALUE PAIRS:
%       MaxDocs       - Maximum number of documents to load (default: Inf)
%       ChunkSize     - Tokens per chunk (default: 300)
%       ChunkOverlap  - Overlapping tokens between chunks (default: 80)
%       MinConfidence - Minimum confidence for label assignment (default: 0.5)
%       FilterFinancial - Only load documents with financial EUROVOC codes (default: true)
%
%   OUTPUTS:
%       chunks        - Table with columns: text, doc_id, chunk_id, celex_id
%       labels        - Struct array with label names
%       metadata      - Struct with dataset statistics and mapping info
%
%   EXAMPLE:
%       mappingPath = 'data/eurovoc_regulatory_mapping.json';
%       dataPath = 'data/eurlex/eurlex_samples.json';
%       [chunks, labels] = reg.load_eurlex(dataPath, mappingPath, 'MaxDocs', 100);
%
%   See also: reg.chunk_text, reg.weak_rules

arguments
    dataPath (1,1) string
    mappingPath (1,1) string
    options.MaxDocs (1,1) double = Inf
    options.ChunkSize (1,1) double = 300
    options.ChunkOverlap (1,1) double = 80
    options.MinConfidence (1,1) double = 0.5
    options.FilterFinancial (1,1) logical = true
end

% Load EUROVOC mapping
fprintf('Loading EUROVOC mapping from: %s\n', mappingPath);
mappingData = jsondecode(fileread(mappingPath));

% Parse mapping structure
labelNames = fieldnames(mappingData.mapping);
labelMapping = containers.Map();
for i = 1:numel(labelNames)
    labelName = labelNames{i};
    codes = mappingData.mapping.(labelName).eurovoc_codes;
    labelMapping(labelName) = codes;
end

% Get general financial codes for filtering
financialCodes = cellfun(@(x) x.code, ...
    mappingData.general_financial_codes.codes, 'UniformOutput', false);

% Load EUR-Lex data
fprintf('Loading EUR-Lex data from: %s\n', dataPath);
if endsWith(dataPath, '.jsonl') || endsWith(dataPath, '.jsonl.gz')
    docs = load_jsonl(dataPath, options.MaxDocs);
else
    rawData = jsondecode(fileread(dataPath));
    if isstruct(rawData)
        docs = rawData;
    elseif iscell(rawData)
        docs = [rawData{:}];
    else
        docs = rawData;
    end
end

if ~isstruct(docs)
    error('Unexpected data format. Expected struct array or cell array of structs.');
end

% Limit number of documents
if options.MaxDocs < numel(docs)
    docs = docs(1:options.MaxDocs);
end

fprintf('Loaded %d documents\n', numel(docs));

% Process documents
allChunks = cell(numel(docs), 1);
allLabels = cell(numel(docs), 1);
chunkDocMap = [];  % Track which document each chunk belongs to
docCount = 0;
globalChunkIdx = 1;

for i = 1:numel(docs)
    doc = docs(i);

    % Extract fields with fallbacks
    text = get_field(doc, 'text', '');
    docLabels = get_field(doc, 'labels', []);
    celexId = get_field(doc, 'celex_id', sprintf('doc_%d', i));

    if isempty(text) || strlength(text) < 100
        continue;  % Skip empty/short documents
    end

    % Convert labels to string array if cell
    if iscell(docLabels)
        docLabels = string(docLabels);
    elseif isnumeric(docLabels)
        docLabels = string(docLabels);
    end

    % Filter financial documents if requested
    if options.FilterFinancial
        hasFinancial = any(ismember(docLabels, financialCodes));
        if ~hasFinancial
            continue;
        end
    end

    % Map EUROVOC codes to regulatory labels
    regLabels = map_eurovoc_to_labels(docLabels, labelMapping, labelNames);

    % Skip if no relevant labels found
    if isempty(regLabels)
        continue;
    end

    % Chunk the document text
    chunks_cell = reg.chunk_text(text, 'size_tokens', options.ChunkSize, ...
        'overlap', options.ChunkOverlap);

    if isempty(chunks_cell)
        continue;
    end

    % Create chunk table
    numChunks = numel(chunks_cell);
    chunkTable = table();
    chunkTable.text = chunks_cell(:);
    chunkTable.doc_id = repmat(docCount + 1, numChunks, 1);
    chunkTable.chunk_id = (1:numChunks)';
    chunkTable.celex_id = repmat(string(celexId), numChunks, 1);

    allChunks{docCount + 1} = chunkTable;
    allLabels{docCount + 1} = regLabels;

    % Track chunk-to-document mapping
    chunkDocMap = [chunkDocMap; repmat(docCount + 1, numChunks, 1)]; %#ok<AGROW>

    docCount = docCount + 1;
    globalChunkIdx = globalChunkIdx + numChunks;
end

chunkCount = globalChunkIdx - 1;

% Combine results
if docCount == 0
    warning('No documents matched the filter criteria');
    chunks = table();
    labels = struct('labels', {{}});
    metadata = struct('num_docs', 0, 'num_chunks', 0);
    return;
end

% Combine all chunks
chunks = vertcat(allChunks{1:docCount});

% Create labels struct
labels = struct();
labels.labels = labelNames;
labels.Y = create_label_matrix(allLabels(1:docCount), labelNames, chunkDocMap);

% Create metadata
metadata = struct();
metadata.num_docs = docCount;
metadata.num_chunks = chunkCount;
metadata.label_names = labelNames;
metadata.mapping_file = mappingPath;
metadata.data_file = dataPath;
metadata.label_distribution = sum(labels.Y, 1);

fprintf('Processed %d documents into %d chunks\n', docCount, chunkCount);
fprintf('Label distribution:\n');
for i = 1:numel(labelNames)
    fprintf('  %s: %d chunks\n', labelNames{i}, metadata.label_distribution(i));
end

end

%% Helper functions

function docs = load_jsonl(filepath, maxDocs)
%LOAD_JSONL Load JSONL file line by line
    if endsWith(filepath, '.gz')
        error('Compressed JSONL not yet supported. Please decompress first.');
    end

    fid = fopen(filepath, 'r', 'n', 'UTF-8');
    if fid == -1
        error('Could not open file: %s', filepath);
    end

    docs = [];
    count = 0;
    try
        while ~feof(fid) && count < maxDocs
            line = fgetl(fid);
            if ischar(line) && ~isempty(line)
                doc = jsondecode(line);
                if isempty(docs)
                    docs = doc;
                else
                    docs(end+1) = doc; %#ok<AGROW>
                end
                count = count + 1;
            end
        end
    catch ME
        fclose(fid);
        rethrow(ME);
    end
    fclose(fid);
end

function val = get_field(s, field, default)
%GET_FIELD Safely get field from struct with default
    if isfield(s, field)
        val = s.(field);
    else
        val = default;
    end
end

function regLabels = map_eurovoc_to_labels(eurovocCodes, labelMapping, labelNames)
%MAP_EUROVOC_TO_LABELS Map EUROVOC codes to regulatory labels
    regLabels = {};
    for i = 1:numel(labelNames)
        labelName = labelNames{i};
        mappedCodes = labelMapping(labelName);

        % Check if any EUROVOC code matches
        if any(ismember(eurovocCodes, mappedCodes))
            regLabels{end+1} = labelName; %#ok<AGROW>
        end
    end
end

function Y = create_label_matrix(docLabels, labelNames, chunkDocMap)
%CREATE_LABEL_MATRIX Create binary label matrix for all chunks
%   docLabels - Cell array of labels for each document
%   labelNames - String array of all possible labels
%   chunkDocMap - Vector mapping chunk index to document index

    numChunks = numel(chunkDocMap);
    numLabels = numel(labelNames);
    Y = zeros(numChunks, numLabels);

    % For each chunk, assign the labels of its parent document
    for chunkIdx = 1:numChunks
        docIdx = chunkDocMap(chunkIdx);
        labels = docLabels{docIdx};

        % Set label flags for this chunk
        for j = 1:numel(labels)
            labelIdx = find(strcmp(labelNames, labels{j}), 1);
            if ~isempty(labelIdx)
                Y(chunkIdx, labelIdx) = 1;
            end
        end
    end
end
