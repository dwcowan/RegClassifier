function setSeeds(seed)
%SETSEEDS Set random seeds for reproducibility.
%
% Inputs
%   seed (1,1 double) integer seed value
%
% Side Effects
%   Initializes MATLAB RNG and GPU RNG (if available).
%
%% NAME-REGISTRY:FUNCTION setSeeds

arguments
  seed (1,1) double {mustBeInteger}
end

assert(seed >= 0, "setSeeds:NegativeSeed", "Seed must be non-negative");

rng(seed, "twister");

haveGpurng = (exist("gpurng", "file") == 2);
haveGpu = haveGpurng && (gpuDeviceCount > 0);

if haveGpu
  gpurng(seed, "Philox4x32-10");
else
  warning("setSeeds:NoGPU", "GPU not available; skipping gpurng");
end
end
