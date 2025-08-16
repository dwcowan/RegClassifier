function data = baseline_load(fname)
%BASELINE_LOAD Load baseline data from fixtures folder.
%   DATA = BASELINE_LOAD(FNAME) reads JSON or CSV data located under
%   +tests/+fixtures/baselines. Files are read-only during tests.

folder = fullfile(fileparts(mfilename('fullpath')), 'baselines');
filePath = fullfile(folder, fname);
if ~isfile(filePath)
    error('tests:fixtures:MissingBaseline', 'Baseline %s not found', fname);
end
[~,~,ext] = fileparts(filePath);
switch lower(ext)
    case '.json'
        data = jsondecode(fileread(filePath));
    case '.csv'
        data = readtable(filePath);
    otherwise
        error('tests:fixtures:UnknownBaseline', 'Unsupported baseline type %s', ext);
end
end
