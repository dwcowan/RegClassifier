function validate_knobs(K)
%VALIDATE_KNOBS Basic sanity checks for knobs.json values
warns = {};
if isfield(K,'BERT')
    if isfield(K.BERT,'MiniBatchSize') && K.BERT.MiniBatchSize<=0
        warns{end+1} = 'BERT.MiniBatchSize must be > 0'; %#ok<AGROW>
    end
    if isfield(K.BERT,'MaxSeqLength') && (K.BERT.MaxSeqLength<64 || K.BERT.MaxSeqLength>512)
        warns{end+1} = 'BERT.MaxSeqLength should be within [64, 512]';
    end
end
if isfield(K,'Projection')
    if isfield(K.Projection,'BatchSize') && K.Projection.BatchSize<=0
        warns{end+1} = 'Projection.BatchSize must be > 0'; %#ok<AGROW>
    end
end
if isfield(K,'FineTune')
    if isfield(K.FineTune,'BatchSize') && K.FineTune.BatchSize<=0
        warns{end+1} = 'FineTune.BatchSize must be > 0'; %#ok<AGROW>
    end
    if isfield(K.FineTune,'MaxSeqLength') && (K.FineTune.MaxSeqLength<64 || K.FineTune.MaxSeqLength>512)
        warns{end+1} = 'FineTune.MaxSeqLength should be within [64, 512]';
    end
    if isfield(K.FineTune,'EncoderLR') && (K.FineTune.EncoderLR<=0 || K.FineTune.EncoderLR>1e-3)
        warns{end+1} = 'FineTune.EncoderLR looks too large or non-positive';
    end
end
for i = 1:numel(warns)
    warning('Knobs: %s', warns{i});
end
end
