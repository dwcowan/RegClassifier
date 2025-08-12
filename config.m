function configStruct = config()
%CONFIG Load configuration from JSON files with overrides.
%
% Outputs
%   configStruct (1,1 struct): merged configuration settings
%
%% NAME-REGISTRY:FUNCTION config

% jsonFilesCell (1x3 cell): configuration files in precedence order
jsonFilesCell = {'pipeline.json', 'knobs.json', 'params.json'};
% configStruct (1x1 struct): merged configuration settings
configStruct = struct();

for idx = 1:numel(jsonFilesCell)
  fileNameStr = jsonFilesCell{idx};
  if exist(fileNameStr, 'file') == 2
    try
      fileTextStr = fileread(fileNameStr);
      fileStruct = jsondecode(fileTextStr);
      assert(isstruct(fileStruct), ...
        'File %s must decode to a struct.', fileNameStr);
      configStruct = mergeStructs(configStruct, fileStruct);
    catch err
      warning('Could not process %s: %s', fileNameStr, err.message);
    end
  else
    warning('Missing configuration file: %s', fileNameStr);
  end
end

assert(~isempty(fieldnames(configStruct)), ...
  'configStruct is empty after reading JSON files.');

try
  reg.validateKnobs(configStruct);
catch err
  warning('validateKnobs failed: %s', err.message);
end

end

function outStruct = mergeStructs(baseStruct, overrideStruct)
%MERGESTRUCTS Merge two structs with override precedence.
%
% Inputs
%   baseStruct (1,1 struct): base configuration
%   overrideStruct (1,1 struct): values to override
%
% Outputs
%   outStruct (1,1 struct): merged configuration

outStruct = baseStruct;
fieldsCell = fieldnames(overrideStruct);
for idx = 1:numel(fieldsCell)
  fieldStr = fieldsCell{idx};
  outStruct.(fieldStr) = overrideStruct.(fieldStr);
end

end
