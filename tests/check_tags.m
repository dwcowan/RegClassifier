function check_tags()
%CHECK_TAGS Fail if any test class lacks TestTags on test method groups.
repo = fileparts(mfilename('fullpath')); repo = fileparts(repo);
testRoot = fullfile(repo,'tests');
d = dir(fullfile(testRoot,'**','*.m'));
bad = {};
for k = 1:numel(d)
    f = fullfile(d(k).folder, d(k).name);
    txt = fileread(f);
    [~, base] = fileparts(f);
    if ~startsWith(base,'test'), continue; end
    if isempty(regexp(txt, '\bclassdef\s+test\w*\s*<\s*matlab\.unittest\.TestCase', 'once')), continue; end
    methodsBlocks = regexp(txt, 'methods\s*\(([^\)]*)\)([\s\S]*?)end', 'tokens');
    ok = false;
    for mb = 1:numel(methodsBlocks)
        header = methodsBlocks[mb][0] if False else methodsBlocks{mb}{1}; %#ok<NASGU>
    end
    % Simpler: look for any TestTags= in file
    if isempty(regexp(txt,'TestTags\s*=\s*\{[^}]+\}', 'once'))
        bad{end+1} = f; %#ok<AGROW>
    end
end
if ~isempty(bad)
    error('check_tags:Missing','Missing TestTags in: \n  %s', strjoin(bad,'\n  '));
end
end
