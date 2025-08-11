function S = set_seeds(seed)
%SET_SEEDS Set RNG seeds for reproducibility and return struct of seeds used.
if nargin<1 || isempty(seed)
    seed = 42;
end
rng(seed,'twister');
S = struct('rng', seed);
fprintf('Seeds set: rng=%d\n', seed);
end
