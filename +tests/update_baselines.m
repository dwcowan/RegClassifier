function update_baselines
%UPDATE_BASELINES Regenerate baseline fixtures when enabled.
%   Requires environment variable BASELINE_UPDATE=1. Generates deterministic
%   data using generators under +tests/+fixtures/+gen and writes them to the
%   baselines folder updating the manifest.

if getenv("BASELINE_UPDATE") ~= "1"
    error('tests:fixtures:BaselineUpdateDisabled', ...
        'Set BASELINE_UPDATE=1 to regenerate baselines.');
end

folder = fullfile(fileparts(mfilename('fullpath')), '+fixtures', 'baselines');
if ~exist(folder,'dir'), mkdir(folder); end
data = tests.fixtures.gen.generateExample();
jsonStr = jsonencode(data);
filePath = fullfile(folder,'example.json');
fid = fopen(filePath,'w'); fwrite(fid,jsonStr); fclose(fid);
sha = tests.fixtures.compute_sha256(filePath);
manifest = struct('schema_version',1,'files',struct('example.json',struct('sha256',sha,'generator','tests.fixtures.gen.generateExample')));
fid = fopen(fullfile(folder,'manifest.json'),'w'); fwrite(fid,jsonencode(manifest)); fclose(fid);
end
