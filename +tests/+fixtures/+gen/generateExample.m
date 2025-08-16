function data = generateExample()
%GENERATEEXAMPLE Deterministic data generator for baselines.
%   DATA = GENERATEEXAMPLE() returns a struct with numeric field for
%   baseline demonstration.

rng(0,'twister');
data = struct('Value', rand(1));
end
