function printActiveKnobs(knobsStruct)
%PRINTACTIVEKNOBS Display knob name-value pairs.
%
% Inputs
%   knobsStruct - struct of knob values
%
% Outputs
%   none
%
%% NAME-REGISTRY:FUNCTION printActiveKnobs

arguments
  knobsStruct (1,1) struct
end

% fNames (cell array): knob field names
fNames = fieldnames(knobsStruct);
assert(~isempty(fNames), 'knobsStruct must have fields.');

for i = 1:numel(fNames)
  % name (char): field name
  name = fNames{i};
  % value (any): field value
  value = knobsStruct.(name);
  if isempty(value)
    warning('Knob "%s" has empty value.', name);
  end
  fprintf('%s: %s\n', name, mat2str(value));
end

end
