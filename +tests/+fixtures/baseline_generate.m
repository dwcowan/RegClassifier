function data = baseline_generate(name)
%BASELINE_GENERATE Deterministic baseline generator stub.
%   DATA = BASELINE_GENERATE(NAME) creates synthetic data structures for
%   regression testing. Generators are deterministic and live under
%   +tests/+fixtures/+gen.

rng(0,'twister'); %#ok<NASGU>
data = struct('Name', name); % Placeholder structure
end
