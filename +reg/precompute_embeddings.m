function E = precompute_embeddings(textStr, C)
%PRECOMPUTE_EMBEDDINGS Compute base sentence embeddings using config backend.
try
    if ~isfield(C,'knobs'), C.knobs = reg.load_knobs(); end
    if isfield(C,'embeddings_backend') && strcmpi(C.embeddings_backend,'bert')
        if isfield(C.knobs,'BERT')
        args = {};
        if isfield(C.knobs.BERT,'MiniBatchSize'), args = [args, {'MiniBatchSize', C.knobs.BERT.MiniBatchSize}]; end
        if isfield(C.knobs.BERT,'MaxSeqLength'), args = [args, {'MaxSeqLength', C.knobs.BERT.MaxSeqLength}]; end
        E = reg.doc_embeddings_bert_gpu(textStr, args{:});
    else
        E = reg.doc_embeddings_bert_gpu(textStr);
    end
    else
        E = reg.doc_embeddings_fasttext(textStr, C.fasttext);
    end
catch ME
    warning('Embeddings fallback to fastText due to: %s', ME.message);
    E = reg.doc_embeddings_fasttext(textStr, C.fasttext);
end
% Ensure L2-normalized
n = vecnorm(E,2,2); n(n==0)=1; E = E ./ n;
end
