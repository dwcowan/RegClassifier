function validate_knobs(K)
%VALIDATE_KNOBS Validate hyperparameter values in knobs struct.
%   VALIDATE_KNOBS(K) examines the struct of knob parameters and raises
%   errors when values fall outside supported ranges. Validations include:
%   - Batch sizes are positive integers
%   - Learning rates are within reasonable limits (1e-6 to 1.0)
%   - Sequence lengths are supported by embedding models
%   - Margins are positive
%   - Epochs are positive integers
%   - Dimensions are positive integers
%
%   INPUTS:
%       K - Struct containing hyperparameter configurations (from load_knobs)
%
%   ERRORS:
%       Raises errors for invalid parameter values
%
%   WARNINGS:
%       Issues warnings for suspicious but not invalid values
%
%   EXAMPLE:
%       K = reg.load_knobs('knobs.json');
%       reg.validate_knobs(K);  % Validate before use
%
%   SEE ALSO: reg.load_knobs

if ~isstruct(K)
    error('reg:validate_knobs:InvalidInput', ...
        'Input must be a struct. Got %s.', class(K));
end

% Initialize warning counter
num_warnings = 0;

%% Validate BERT parameters
if isfield(K, 'BERT')
    % MiniBatchSize
    if isfield(K.BERT, 'MiniBatchSize')
        val = K.BERT.MiniBatchSize;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0 || floor(val) ~= val
            error('reg:validate_knobs:InvalidBERTBatchSize', ...
                'BERT.MiniBatchSize must be a positive integer. Got: %s', mat2str(val));
        end
        if val < 1
            error('reg:validate_knobs:BERTBatchSizeTooSmall', ...
                'BERT.MiniBatchSize must be >= 1. Got: %d', val);
        end
        if val > 512
            warning('reg:validate_knobs:BERTBatchSizeLarge', ...
                'BERT.MiniBatchSize (%d) is very large and may cause GPU OOM.', val);
            num_warnings = num_warnings + 1;
        end
    end

    % MaxSeqLength
    if isfield(K.BERT, 'MaxSeqLength')
        val = K.BERT.MaxSeqLength;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0 || floor(val) ~= val
            error('reg:validate_knobs:InvalidBERTSeqLength', ...
                'BERT.MaxSeqLength must be a positive integer. Got: %s', mat2str(val));
        end
        if val > 512
            warning('reg:validate_knobs:BERTSeqLengthExceeds512', ...
                'BERT.MaxSeqLength (%d) exceeds BERT''s 512 token limit.', val);
            num_warnings = num_warnings + 1;
        end
    end
end

%% Validate Projection parameters
if isfield(K, 'Projection')
    % ProjDim
    if isfield(K.Projection, 'ProjDim')
        val = K.Projection.ProjDim;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0 || floor(val) ~= val
            error('reg:validate_knobs:InvalidProjDim', ...
                'Projection.ProjDim must be a positive integer. Got: %s', mat2str(val));
        end
        if val < 32
            warning('reg:validate_knobs:ProjDimTooSmall', ...
                'Projection.ProjDim (%d) is very small and may lose information.', val);
            num_warnings = num_warnings + 1;
        end
        if val > 1024
            warning('reg:validate_knobs:ProjDimLarge', ...
                'Projection.ProjDim (%d) is very large.', val);
            num_warnings = num_warnings + 1;
        end
    end

    % Epochs
    if isfield(K.Projection, 'Epochs')
        val = K.Projection.Epochs;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0 || floor(val) ~= val
            error('reg:validate_knobs:InvalidProjEpochs', ...
                'Projection.Epochs must be a positive integer. Got: %s', mat2str(val));
        end
    end

    % BatchSize
    if isfield(K.Projection, 'BatchSize')
        val = K.Projection.BatchSize;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0 || floor(val) ~= val
            error('reg:validate_knobs:InvalidProjBatchSize', ...
                'Projection.BatchSize must be a positive integer. Got: %s', mat2str(val));
        end
    end

    % LR (Learning Rate)
    if isfield(K.Projection, 'LR')
        val = K.Projection.LR;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0
            error('reg:validate_knobs:InvalidProjLR', ...
                'Projection.LR must be a positive number. Got: %s', mat2str(val));
        end
        if val < 1e-6
            warning('reg:validate_knobs:ProjLRTooSmall', ...
                'Projection.LR (%.2e) is very small and may cause slow convergence.', val);
            num_warnings = num_warnings + 1;
        end
        if val > 1.0
            warning('reg:validate_knobs:ProjLRTooLarge', ...
                'Projection.LR (%.2e) is very large and may cause instability.', val);
            num_warnings = num_warnings + 1;
        end
    end

    % Margin
    if isfield(K.Projection, 'Margin')
        val = K.Projection.Margin;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0
            error('reg:validate_knobs:InvalidProjMargin', ...
                'Projection.Margin must be a positive number. Got: %s', mat2str(val));
        end
        if val > 2.0
            warning('reg:validate_knobs:ProjMarginLarge', ...
                'Projection.Margin (%.2f) is unusually large.', val);
            num_warnings = num_warnings + 1;
        end
    end

    % UseGPU
    if isfield(K.Projection, 'UseGPU')
        val = K.Projection.UseGPU;
        if ~islogical(val) && ~isnumeric(val)
            error('reg:validate_knobs:InvalidProjUseGPU', ...
                'Projection.UseGPU must be logical (true/false). Got: %s', class(val));
        end
    end
end

%% Validate FineTune parameters
if isfield(K, 'FineTune')
    % Loss
    if isfield(K.FineTune, 'Loss')
        val = K.FineTune.Loss;
        if ~ischar(val) && ~isstring(val)
            error('reg:validate_knobs:InvalidFineTuneLoss', ...
                'FineTune.Loss must be a string. Got: %s', class(val));
        end
        val = char(val);
        valid_losses = {'triplet', 'supcon'};
        if ~ismember(lower(val), valid_losses)
            error('reg:validate_knobs:UnsupportedFineTuneLoss', ...
                'FineTune.Loss must be one of: %s. Got: %s', ...
                strjoin(valid_losses, ', '), val);
        end
    end

    % BatchSize
    if isfield(K.FineTune, 'BatchSize')
        val = K.FineTune.BatchSize;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0 || floor(val) ~= val
            error('reg:validate_knobs:InvalidFineTuneBatchSize', ...
                'FineTune.BatchSize must be a positive integer. Got: %s', mat2str(val));
        end
        if val < 8
            warning('reg:validate_knobs:FineTuneBatchSizeSmall', ...
                'FineTune.BatchSize (%d) is small and may cause noisy gradients.', val);
            num_warnings = num_warnings + 1;
        end
    end

    % MaxSeqLength
    if isfield(K.FineTune, 'MaxSeqLength')
        val = K.FineTune.MaxSeqLength;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0 || floor(val) ~= val
            error('reg:validate_knobs:InvalidFineTuneSeqLength', ...
                'FineTune.MaxSeqLength must be a positive integer. Got: %s', mat2str(val));
        end
        if val > 512
            warning('reg:validate_knobs:FineTuneSeqLengthExceeds512', ...
                'FineTune.MaxSeqLength (%d) exceeds BERT''s 512 token limit.', val);
            num_warnings = num_warnings + 1;
        end
    end

    % UnfreezeTopLayers
    if isfield(K.FineTune, 'UnfreezeTopLayers')
        val = K.FineTune.UnfreezeTopLayers;
        if ~isnumeric(val) || ~isscalar(val) || val < 0 || floor(val) ~= val
            error('reg:validate_knobs:InvalidFineTuneUnfreezeLayers', ...
                'FineTune.UnfreezeTopLayers must be a non-negative integer. Got: %s', mat2str(val));
        end
        if val > 12
            warning('reg:validate_knobs:FineTuneUnfreezeLayersExceeds12', ...
                'FineTune.UnfreezeTopLayers (%d) exceeds BERT''s 12 layers.', val);
            num_warnings = num_warnings + 1;
        end
    end

    % Epochs
    if isfield(K.FineTune, 'Epochs')
        val = K.FineTune.Epochs;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0 || floor(val) ~= val
            error('reg:validate_knobs:InvalidFineTuneEpochs', ...
                'FineTune.Epochs must be a positive integer. Got: %s', mat2str(val));
        end
    end

    % EncoderLR
    if isfield(K.FineTune, 'EncoderLR')
        val = K.FineTune.EncoderLR;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0
            error('reg:validate_knobs:InvalidFineTuneEncoderLR', ...
                'FineTune.EncoderLR must be a positive number. Got: %s', mat2str(val));
        end
        if val < 1e-7
            warning('reg:validate_knobs:FineTuneEncoderLRTooSmall', ...
                'FineTune.EncoderLR (%.2e) is very small.', val);
            num_warnings = num_warnings + 1;
        end
        if val > 1e-3
            warning('reg:validate_knobs:FineTuneEncoderLRLarge', ...
                'FineTune.EncoderLR (%.2e) is large for fine-tuning and may cause instability.', val);
            num_warnings = num_warnings + 1;
        end
    end

    % HeadLR
    if isfield(K.FineTune, 'HeadLR')
        val = K.FineTune.HeadLR;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0
            error('reg:validate_knobs:InvalidFineTuneHeadLR', ...
                'FineTune.HeadLR must be a positive number. Got: %s', mat2str(val));
        end
        if val < 1e-6
            warning('reg:validate_knobs:FineTuneHeadLRTooSmall', ...
                'FineTune.HeadLR (%.2e) is very small.', val);
            num_warnings = num_warnings + 1;
        end
        if val > 1.0
            warning('reg:validate_knobs:FineTuneHeadLRTooLarge', ...
                'FineTune.HeadLR (%.2e) is very large.', val);
            num_warnings = num_warnings + 1;
        end
    end

    % Margin
    if isfield(K.FineTune, 'Margin')
        val = K.FineTune.Margin;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0
            error('reg:validate_knobs:InvalidFineTuneMargin', ...
                'FineTune.Margin must be a positive number. Got: %s', mat2str(val));
        end
    end

    % Temperature
    if isfield(K.FineTune, 'Temperature')
        val = K.FineTune.Temperature;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0
            error('reg:validate_knobs:InvalidFineTuneTemperature', ...
                'FineTune.Temperature must be a positive number. Got: %s', mat2str(val));
        end
        if val < 0.01 || val > 1.0
            warning('reg:validate_knobs:FineTuneTemperatureUnusual', ...
                'FineTune.Temperature (%.3f) is outside typical range [0.01, 1.0].', val);
            num_warnings = num_warnings + 1;
        end
    end

    % FP16
    if isfield(K.FineTune, 'FP16')
        val = K.FineTune.FP16;
        if ~islogical(val) && ~isnumeric(val)
            error('reg:validate_knobs:InvalidFineTuneFP16', ...
                'FineTune.FP16 must be logical (true/false). Got: %s', class(val));
        end
    end
end

%% Validate Chunk parameters
if isfield(K, 'Chunk')
    % SizeTokens
    if isfield(K.Chunk, 'SizeTokens')
        val = K.Chunk.SizeTokens;
        if ~isnumeric(val) || ~isscalar(val) || val <= 0 || floor(val) ~= val
            error('reg:validate_knobs:InvalidChunkSize', ...
                'Chunk.SizeTokens must be a positive integer. Got: %s', mat2str(val));
        end
        if val < 50
            warning('reg:validate_knobs:ChunkSizeTooSmall', ...
                'Chunk.SizeTokens (%d) is very small and may fragment documents excessively.', val);
            num_warnings = num_warnings + 1;
        end
        if val > 512
            warning('reg:validate_knobs:ChunkSizeExceeds512', ...
                'Chunk.SizeTokens (%d) exceeds BERT''s 512 token limit.', val);
            num_warnings = num_warnings + 1;
        end
    end

    % Overlap
    if isfield(K.Chunk, 'Overlap')
        val = K.Chunk.Overlap;
        if ~isnumeric(val) || ~isscalar(val) || val < 0 || floor(val) ~= val
            error('reg:validate_knobs:InvalidChunkOverlap', ...
                'Chunk.Overlap must be a non-negative integer. Got: %s', mat2str(val));
        end
        if isfield(K.Chunk, 'SizeTokens') && val >= K.Chunk.SizeTokens
            error('reg:validate_knobs:ChunkOverlapTooLarge', ...
                'Chunk.Overlap (%d) must be less than Chunk.SizeTokens (%d).', ...
                val, K.Chunk.SizeTokens);
        end
    end
end

% Summary
if num_warnings > 0
    fprintf('Knobs validation: %d warning(s) issued. Review above messages.\n', num_warnings);
else
    fprintf('Knobs validation: All parameters valid.\n');
end

end
