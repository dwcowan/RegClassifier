function update_baselines()
%UPDATE_BASELINES Guarded baseline regeneration (developer-only; never in CI).
% Usage:
%   setenv('BASELINE_UPDATE','1');  % REQUIRED
%   tests.update_baselines

if ~strcmp(getenv('BASELINE_UPDATE'),'1')
    error('update_baselines:Guard','BASELINE_UPDATE=1 required to regenerate baselines.');
end

repo = fileparts(mfilename('fullpath')); repo = fileparts(repo);
fixtures = fullfile(repo,'tests','+fixtures');
baselines = fullfile(fixtures, 'baselines');
genpkg = fullfile(fixtures, '+gen');

if ~isfolder(genpkg)
    error('update_baselines:NoGen','Missing generators under tests/+fixtures/+gen');
end

% Deterministic RNG
rng(0,'twister');

% Example generation (extend with your project-specific generators)
exampleCsv = fullfile(baselines,'example_signal.csv');
[tSec, x] = tests.fixtures.gen.example_signal(); %#ok<ASGLU>   % implement in tests/+fixtures/+gen/example_signal.m
% Write CSV (developer-only, guarded)
T = table(tSec(:), x(:), 'VariableNames', {'tSec','x'});
writetable(T, exampleCsv);

% TODO: compute sha256 and write back to manifest.json (optional)

fprintf('[update_baselines] Baselines regenerated under %s\n', baselines);
end
