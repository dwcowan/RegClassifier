function print_active_knobs(C)
%PRINT_ACTIVE_KNOBS Pretty-print active knobs at the start of a run
fprintf("\n=== Active Knobs ===\n");
    if isfield(C,'knobs') && ~isempty(C.knobs), try, reg.validate_knobs(C.knobs); end, end
if isfield(C,'knobs') && ~isempty(C.knobs)
    K = C.knobs;
    if isfield(K,'BERT')
        fprintf("BERT: MiniBatchSize=%s, MaxSeqLength=%s\n", ...
            getf(K.BERT,'MiniBatchSize'), getf(K.BERT,'MaxSeqLength'));
    end
    if isfield(K,'Projection')
        fprintf("Projection: ProjDim=%s, BatchSize=%s, Epochs=%s, LR=%s, Margin=%s\n", ...
            getf(K.Projection,'ProjDim'), getf(K.Projection,'BatchSize'), ...
            getf(K.Projection,'Epochs'), getf(K.Projection,'LR'), getf(K.Projection,'Margin'));
    end
    if isfield(K,'FineTune')
        fprintf("FineTune: Loss=%s, BatchSize=%s, Epochs=%s, MaxSeqLength=%s, UnfreezeTopLayers=%s, EncoderLR=%s, HeadLR=%s\n", ...
            getf(K.FineTune,'Loss'), getf(K.FineTune,'BatchSize'), getf(K.FineTune,'Epochs'), ...
            getf(K.FineTune,'MaxSeqLength'), getf(K.FineTune,'UnfreezeTopLayers'), ...
            getf(K.FineTune,'EncoderLR'), getf(K.FineTune,'HeadLR'));
    end
    if isfield(K,'Chunk')
        fprintf("Chunk: SizeTokens=%s, Overlap=%s\n", ...
            getf(K.Chunk,'SizeTokens'), getf(K.Chunk,'Overlap'));
    end
else
    fprintf("(no knobs.json loaded)\n");
end
fprintf("====================\n\n");
end

function v = getf(S, field)
if isstruct(S) && isfield(S, field)
    val = S.(field);
    if isnumeric(val), v = num2str(val);
    elseif isstring(val) || ischar(val), v = char(val);
    else, v = "<struct>";
    end
else
    v = "-";
end
end
