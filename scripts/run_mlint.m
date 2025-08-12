function run_mlint()
%RUN_MLINT Run MATLAB code analyzer on all .m files in repository.
%
% Raises an error when any lint issues are found.
%
% NAME-REGISTRY:FUNCTION run_mlint

filesStruct = dir(fullfile('**', '*.m'));
assert(isstruct(filesStruct), 'Directory search failed');

hasIssues = false;
for iFile = 1:numel(filesStruct)
  filePath = fullfile(filesStruct(iFile).folder, filesStruct(iFile).name);
  fprintf('Linting %s\n', filePath);
  issues = checkcode(filePath, '-id');
  if ~isempty(issues)
    disp(issues);
    hasIssues = true;
  end
end

if hasIssues
  error('Lint issues found');
end

end
