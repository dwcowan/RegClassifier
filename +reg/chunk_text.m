function chunksT = chunk_text(docsT, chunkTokens, overlap)
%CHUNK_TEXT Split documents into overlapping token windows
chunk_id = strings(0,1); doc_id = strings(0,1); text = strings(0,1); start_idx = []; end_idx = [];
for i = 1:height(docsT)
    tokens = split(regexprep(docsT.text(i), '\s+', ' ')); tokens(tokens=="") = [];
    L = numel(tokens); s = 1;
    if L==0, continue; end
    while s <= L
        e = min(L, s + chunkTokens - 1);
        chunkTokensStr = strjoin(tokens(s:e), " ");
        chunk_id(end+1,1) = "CH_" + docsT.doc_id(i) + "_" + string(s); %#ok<AGROW>
        doc_id(end+1,1)   = docsT.doc_id(i);
        text(end+1,1)     = string(chunkTokensStr);
        start_idx(end+1,1)= s; end_idx(end+1,1)= e;
        if e == L, break; end
        s = e - overlap + 1;
    end
end
chunksT = table(chunk_id, doc_id, text, start_idx, end_idx);
end
