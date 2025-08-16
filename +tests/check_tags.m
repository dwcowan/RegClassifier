function check_tags
%CHECK_TAGS Ensure every test method has TestTags.

import matlab.unittest.TestSuite
suite = TestSuite.fromFolder(fileparts(mfilename('fullpath')), 'IncludeSubfolders', true);
missing = {};
for k = 1:numel(suite)
    if isempty(suite(k).TestTags)
        missing{end+1} = suite(k).Name; %#ok<AGROW>
    end
end
if ~isempty(missing)
    error('tests:MissingTags', 'Missing TestTags for:\n%s', strjoin(missing, '\n'));
end
end
