function K = load_knobs(jsonPath)
%LOAD_KNOBS Load tunable parameters from JSON configuration file.
%   K = LOAD_KNOBS(jsonPath) returns a struct of knob values read from
%   the given JSON file. Typical fields include BERT, Projection, FineTune
%   and Chunk each containing algorithm-specific parameters.
%
%   INPUTS:
%       jsonPath - Path to JSON file containing knob definitions
%                  (default: 'knobs.json' in current directory)
%
%   OUTPUTS:
%       K - Struct containing hyperparameter configurations with fields:
%           .BERT       - BERT embedding parameters
%           .Projection - Projection head training parameters
%           .FineTune   - Encoder fine-tuning parameters
%           .Chunk      - Text chunking parameters
%
%   EXPECTED KNOBS.JSON STRUCTURE:
%       {
%         "BERT": {
%           "MiniBatchSize": 96,
%           "MaxSeqLength": 256
%         },
%         "Projection": {
%           "ProjDim": 384,
%           "Epochs": 50,
%           "BatchSize": 768,
%           "LR": 0.001,
%           "Margin": 0.5,
%           "UseGPU": true
%         },
%         "FineTune": {
%           "Loss": "triplet",
%           "BatchSize": 32,
%           "MaxSeqLength": 256,
%           "UnfreezeTopLayers": 4,
%           "Epochs": 5,
%           "EncoderLR": 2e-05,
%           "HeadLR": 0.001,
%           "Margin": 0.2,
%           "FP16": false,
%           "Temperature": 0.07
%         },
%         "Chunk": {
%           "SizeTokens": 300,
%           "Overlap": 80
%         }
%       }
%
%   EXAMPLE:
%       K = reg.load_knobs('knobs.json');
%       fprintf('BERT batch size: %d\n', K.BERT.MiniBatchSize);
%       fprintf('Projection learning rate: %.4f\n', K.Projection.LR);
%
%   SEE ALSO: reg.validate_knobs, config

% Default path
if nargin < 1 || isempty(jsonPath)
    jsonPath = 'knobs.json';
end

% Check if file exists
if ~isfile(jsonPath)
    warning('reg:load_knobs:FileNotFound', ...
        'Knobs file not found: %s. Returning default empty struct.', jsonPath);
    K = struct();
    return;
end

% Read and parse JSON file
try
    % Read file contents
    fid = fopen(jsonPath, 'r', 'n', 'UTF-8');
    if fid == -1
        error('reg:load_knobs:CannotOpen', ...
            'Cannot open file: %s', jsonPath);
    end

    try
        jsonText = fread(fid, '*char')';
        fclose(fid);
    catch ME
        fclose(fid);
        rethrow(ME);
    end

    % Parse JSON
    K = jsondecode(jsonText);

    % Validate that we got a struct
    if ~isstruct(K)
        error('reg:load_knobs:InvalidFormat', ...
            'JSON file did not decode to a struct. Check file format.');
    end

catch ME
    warning('reg:load_knobs:ParseError', ...
        'Failed to parse knobs.json: %s. Returning empty struct.', ME.message);
    K = struct();
    return;
end

% Apply defaults for missing sections
K = apply_defaults(K);

end

function K = apply_defaults(K)
%APPLY_DEFAULTS Fill in missing knobs sections with defaults.

    % BERT defaults
    if ~isfield(K, 'BERT')
        K.BERT = struct();
    end
    if ~isfield(K.BERT, 'MiniBatchSize')
        K.BERT.MiniBatchSize = 96;
    end
    if ~isfield(K.BERT, 'MaxSeqLength')
        K.BERT.MaxSeqLength = 256;
    end

    % Projection defaults
    if ~isfield(K, 'Projection')
        K.Projection = struct();
    end
    if ~isfield(K.Projection, 'ProjDim')
        K.Projection.ProjDim = 384;
    end
    if ~isfield(K.Projection, 'Epochs')
        K.Projection.Epochs = 50;
    end
    if ~isfield(K.Projection, 'BatchSize')
        K.Projection.BatchSize = 768;
    end
    if ~isfield(K.Projection, 'LR')
        K.Projection.LR = 0.001;
    end
    if ~isfield(K.Projection, 'Margin')
        K.Projection.Margin = 0.5;
    end
    if ~isfield(K.Projection, 'UseGPU')
        K.Projection.UseGPU = true;
    end

    % FineTune defaults
    if ~isfield(K, 'FineTune')
        K.FineTune = struct();
    end
    if ~isfield(K.FineTune, 'Loss')
        K.FineTune.Loss = 'triplet';
    end
    if ~isfield(K.FineTune, 'BatchSize')
        K.FineTune.BatchSize = 32;
    end
    if ~isfield(K.FineTune, 'MaxSeqLength')
        K.FineTune.MaxSeqLength = 256;
    end
    if ~isfield(K.FineTune, 'UnfreezeTopLayers')
        K.FineTune.UnfreezeTopLayers = 4;
    end
    if ~isfield(K.FineTune, 'Epochs')
        K.FineTune.Epochs = 5;
    end
    if ~isfield(K.FineTune, 'EncoderLR')
        K.FineTune.EncoderLR = 2e-5;
    end
    if ~isfield(K.FineTune, 'HeadLR')
        K.FineTune.HeadLR = 1e-3;
    end
    if ~isfield(K.FineTune, 'Margin')
        K.FineTune.Margin = 0.2;
    end
    if ~isfield(K.FineTune, 'FP16')
        K.FineTune.FP16 = false;
    end
    if ~isfield(K.FineTune, 'Temperature')
        K.FineTune.Temperature = 0.07;
    end

    % Chunk defaults
    if ~isfield(K, 'Chunk')
        K.Chunk = struct();
    end
    if ~isfield(K.Chunk, 'SizeTokens')
        K.Chunk.SizeTokens = 300;
    end
    if ~isfield(K.Chunk, 'Overlap')
        K.Chunk.Overlap = 80;
    end

end
