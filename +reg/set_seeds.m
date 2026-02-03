function S = set_seeds(seed)
%SET_SEEDS Establish reproducible random seeds for CPU and GPU.
%   S = SET_SEEDS(seed) initializes MATLAB's random number generators
%   using the provided seed and returns a struct describing the seeds
%   applied.
%
%   This function seeds:
%   - CPU random number generator (rng)
%   - GPU random number generator (gpurng) if GPU is available
%
%   IMPORTANT NOTES ON REPRODUCIBILITY:
%   - parfor loops may still introduce non-determinism due to execution
%     order variability. For full reproducibility, use regular for loops
%     or set UseParallel=false in configuration.
%   - Some GPU operations are inherently non-deterministic for performance
%     reasons (e.g., atomicAdd operations in CUDA).
%   - Deep learning training on GPU may have slight variations due to
%     floating-point arithmetic order.
%
%   INPUTS:
%       seed - Integer seed value (default: 42)
%
%   OUTPUTS:
%       S - Struct with fields:
%           .cpu_seed      - Seed applied to CPU RNG
%           .cpu_generator - Generator type used
%           .gpu_seed      - Seed applied to GPU RNG (if available)
%           .gpu_generator - GPU generator type (if available)
%           .gpu_available - Boolean indicating GPU availability
%           .warnings      - Cell array of reproducibility warnings
%
%   EXAMPLE:
%       S = reg.set_seeds(42);
%       fprintf('CPU seeded with: %d (%s)\n', S.cpu_seed, S.cpu_generator);
%       if S.gpu_available
%           fprintf('GPU seeded with: %d (%s)\n', S.gpu_seed, S.gpu_generator);
%       end

% Default seed
if nargin < 1 || isempty(seed)
    seed = 42;
end

% Validate input
if ~isnumeric(seed) || ~isscalar(seed) || seed < 0 || floor(seed) ~= seed
    error('reg:set_seeds:InvalidSeed', ...
        'Seed must be a non-negative integer scalar.');
end

% Initialize output struct
S = struct();
S.cpu_seed = seed;
S.gpu_available = false;
S.warnings = {};

% Set CPU random number generator
% Use 'twister' (Mersenne Twister) for good statistical properties
try
    rng(seed, 'twister');
    S.cpu_generator = 'twister';
catch ME
    warning('reg:set_seeds:CPUFailed', ...
        'Failed to set CPU RNG seed: %s', ME.message);
    S.warnings{end+1} = sprintf('CPU RNG seeding failed: %s', ME.message);
end

% Set GPU random number generator if available
try
    if gpuDeviceCount > 0
        % Check if a GPU is already selected
        try
            g = gpuDevice();
            S.gpu_available = true;

            % Seed GPU RNG
            % 'Philox4x32-10' is a good choice for reproducibility
            gpurng(seed, 'Philox4x32-10');
            S.gpu_seed = seed;
            S.gpu_generator = 'Philox4x32-10';
            S.gpu_device = g.Name;
            S.gpu_index = g.Index;

        catch ME_inner
            warning('reg:set_seeds:GPUSelectFailed', ...
                'GPU detected but failed to select: %s', ME_inner.message);
            S.warnings{end+1} = sprintf('GPU selection failed: %s', ME_inner.message);
        end
    else
        % No GPU available
        S.gpu_available = false;
        S.warnings{end+1} = 'No GPU available for seeding';
    end
catch ME
    warning('reg:set_seeds:GPUCheckFailed', ...
        'Failed to check GPU availability: %s', ME.message);
    S.warnings{end+1} = sprintf('GPU check failed: %s', ME.message);
end

% Add general reproducibility warnings
S.warnings{end+1} = 'parfor loops may introduce non-determinism due to execution order';
S.warnings{end+1} = 'Some GPU operations are non-deterministic for performance';
S.warnings{end+1} = 'For full reproducibility, disable parallel processing';

end
