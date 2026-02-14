function print_active_knobs(C)
%PRINT_ACTIVE_KNOBS Display knob configuration in human-readable format.
%   PRINT_ACTIVE_KNOBS(C) presents the contents of C.knobs in a
%   human-readable form with formatted sections for BERT, Projection,
%   FineTune, and Chunk parameters.
%
%   INPUTS:
%       C - Configuration struct containing .knobs field
%
%   EXAMPLE:
%       C = reg.load_config('pipeline.json', 'knobs.json');
%       reg.print_active_knobs(C);
%
%   SEE ALSO: reg.load_config, reg.validate_knobs

% Validate input
if ~isstruct(C) || ~isfield(C, 'knobs')
    error('reg:print_active_knobs:InvalidInput', ...
        'Input must be a struct with .knobs field.');
end

K = C.knobs;

% Validate knobs first
try
    reg.validate_knobs(K);
catch ME
    warning('reg:print_active_knobs:ValidationFailed', ...
        'Knobs validation failed: %s', ME.message);
end

fprintf('\n');
fprintf('═══════════════════════════════════════════════════════════════\n');
fprintf('                    ACTIVE KNOBS CONFIGURATION                 \n');
fprintf('═══════════════════════════════════════════════════════════════\n');
fprintf('\n');

%% Print BERT parameters
if isfield(K, 'BERT')
    fprintf('┌─────────────────────────────────────────────────────────────┐\n');
    fprintf('│ BERT PARAMETERS                                             │\n');
    fprintf('├─────────────────────────────────────────────────────────────┤\n');

    if isfield(K.BERT, 'MiniBatchSize')
        fprintf('│ MiniBatchSize         : %-35d │\n', K.BERT.MiniBatchSize);
    end
    if isfield(K.BERT, 'MaxSeqLength')
        fprintf('│ MaxSeqLength          : %-35d │\n', K.BERT.MaxSeqLength);
    end

    fprintf('└─────────────────────────────────────────────────────────────┘\n');
    fprintf('\n');
end

%% Print Projection parameters
if isfield(K, 'Projection')
    fprintf('┌─────────────────────────────────────────────────────────────┐\n');
    fprintf('│ PROJECTION HEAD PARAMETERS                                  │\n');
    fprintf('├─────────────────────────────────────────────────────────────┤\n');

    if isfield(K.Projection, 'ProjDim')
        fprintf('│ ProjDim               : %-35d │\n', K.Projection.ProjDim);
    end
    if isfield(K.Projection, 'Epochs')
        fprintf('│ Epochs                : %-35d │\n', K.Projection.Epochs);
    end
    if isfield(K.Projection, 'BatchSize')
        fprintf('│ BatchSize             : %-35d │\n', K.Projection.BatchSize);
    end
    if isfield(K.Projection, 'LR')
        fprintf('│ Learning Rate         : %-35.6f │\n', K.Projection.LR);
    end
    if isfield(K.Projection, 'Margin')
        fprintf('│ Margin                : %-35.3f │\n', K.Projection.Margin);
    end
    if isfield(K.Projection, 'UseGPU')
        gpuStr = ternary(K.Projection.UseGPU, 'true', 'false');
        fprintf('│ UseGPU                : %-35s │\n', gpuStr);
    end

    fprintf('└─────────────────────────────────────────────────────────────┘\n');
    fprintf('\n');
end

%% Print FineTune parameters
if isfield(K, 'FineTune')
    fprintf('┌─────────────────────────────────────────────────────────────┐\n');
    fprintf('│ FINE-TUNING PARAMETERS                                      │\n');
    fprintf('├─────────────────────────────────────────────────────────────┤\n');

    if isfield(K.FineTune, 'Loss')
        fprintf('│ Loss Function         : %-35s │\n', char(K.FineTune.Loss));
    end
    if isfield(K.FineTune, 'BatchSize')
        fprintf('│ BatchSize             : %-35d │\n', K.FineTune.BatchSize);
    end
    if isfield(K.FineTune, 'MaxSeqLength')
        fprintf('│ MaxSeqLength          : %-35d │\n', K.FineTune.MaxSeqLength);
    end
    if isfield(K.FineTune, 'UnfreezeTopLayers')
        fprintf('│ UnfreezeTopLayers     : %-35d │\n', K.FineTune.UnfreezeTopLayers);
    end
    if isfield(K.FineTune, 'Epochs')
        fprintf('│ Epochs                : %-35d │\n', K.FineTune.Epochs);
    end
    if isfield(K.FineTune, 'EncoderLR')
        fprintf('│ Encoder Learning Rate : %-35.8f │\n', K.FineTune.EncoderLR);
    end
    if isfield(K.FineTune, 'HeadLR')
        fprintf('│ Head Learning Rate    : %-35.6f │\n', K.FineTune.HeadLR);
    end
    if isfield(K.FineTune, 'Margin')
        fprintf('│ Margin                : %-35.3f │\n', K.FineTune.Margin);
    end
    if isfield(K.FineTune, 'Temperature')
        fprintf('│ Temperature           : %-35.3f │\n', K.FineTune.Temperature);
    end
    if isfield(K.FineTune, 'FP16')
        fp16Str = ternary(K.FineTune.FP16, 'true', 'false');
        fprintf('│ FP16 Training         : %-35s │\n', fp16Str);
    end

    fprintf('└─────────────────────────────────────────────────────────────┘\n');
    fprintf('\n');
end

%% Print Chunk parameters
if isfield(K, 'Chunk')
    fprintf('┌─────────────────────────────────────────────────────────────┐\n');
    fprintf('│ CHUNKING PARAMETERS                                         │\n');
    fprintf('├─────────────────────────────────────────────────────────────┤\n');

    if isfield(K.Chunk, 'SizeTokens')
        fprintf('│ SizeTokens            : %-35d │\n', K.Chunk.SizeTokens);
    end
    if isfield(K.Chunk, 'Overlap')
        fprintf('│ Overlap               : %-35d │\n', K.Chunk.Overlap);
    end

    fprintf('└─────────────────────────────────────────────────────────────┘\n');
    fprintf('\n');
end

fprintf('═══════════════════════════════════════════════════════════════\n');
fprintf('\n');

end

function result = ternary(condition, trueVal, falseVal)
%TERNARY Simple ternary operator helper
if condition
    result = trueVal;
else
    result = falseVal;
end
end
