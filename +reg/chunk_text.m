function chunksT = chunk_text(docsT, chunkTokens, overlap)
%CHUNK_TEXT Split documents into overlapping token windows
arguments
    docsT table
    chunkTokens (1,1) double {mustBePositive, mustBeInteger}
    overlap (1,1) double {mustBeNonnegative, mustBeInteger}
end

% Validate overlap < chunkTokens
if overlap >= chunkTokens
    error('reg:chunk_text:InvalidOverlap', ...
        'Overlap (%d) must be less than chunk size (%d)', overlap, chunkTokens);
end

% Estimate total chunks for pre-allocation
estimatedChunks = 0;
for i = 1:height(docsT)
    tokens = split(regexprep(docsT.text(i), '\s+', ' '));
    tokens(tokens=="") = [];
    L = numel(tokens);
    if L > 0
        % Estimate chunks: ceiling of tokens divided by stride
        stride = max(1, chunkTokens - overlap);
        estimatedChunks = estimatedChunks + ceil(L / stride) + 1;
    end
end

% Pre-allocate arrays with estimated size
chunk_id = strings(estimatedChunks, 1);
doc_id = strings(estimatedChunks, 1);
text = strings(estimatedChunks, 1);
start_idx = zeros(estimatedChunks, 1);
end_idx = zeros(estimatedChunks, 1);

idx = 1;
for i = 1:height(docsT)
    tokens = split(regexprep(docsT.text(i), '\s+', ' '));
    tokens(tokens=="") = [];
    L = numel(tokens); s = 1;
    if L==0, continue; end
    while s <= L
        e = min(L, s + chunkTokens - 1);
        chunkTokensStr = strjoin(tokens(s:e), " ");
        chunk_id(idx,1) = "CH_" + docsT.doc_id(i) + "_" + string(s);
        doc_id(idx,1)   = docsT.doc_id(i);
        text(idx,1)     = string(chunkTokensStr);
        start_idx(idx,1)= s;
        end_idx(idx,1)  = e;
        idx = idx + 1;
        if e == L, break; end
        s = e - overlap + 1;
    end
end

% Trim to actual size
chunk_id = chunk_id(1:idx-1);
doc_id = doc_id(1:idx-1);
text = text(1:idx-1);
start_idx = start_idx(1:idx-1);
end_idx = end_idx(1:idx-1);

chunksT = table(chunk_id, doc_id, text, start_idx, end_idx);
end
