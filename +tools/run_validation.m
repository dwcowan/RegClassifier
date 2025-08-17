function run_validation
%RUN_VALIDATION Execute clean-room validator with preflight.
root = fileparts(fileparts(mfilename('fullpath')));
artifacts = fullfile(root, '+tests', 'artifacts');
if ~exist(artifacts,'dir'), mkdir(artifacts); end
try
    tools.validate_clean_room_testing;
catch ME
    fprintf(2, "VALIDATION FAILED: %s\n", ME.message);
    rethrow(ME);
end
end
