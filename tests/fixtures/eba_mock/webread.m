function html = webread(url)
%WEBREAD Mock replacement for network calls in tests.
%   Returns canned HTML for known URLs and logs calls in a global variable.
%   This function resides in tests/fixtures/eba_mock and is placed on the
%   path by the test case when needed.

% Record the call for later inspection
% (global so tests can access the log)
global WEBREAD_CALLS
if isempty(WEBREAD_CALLS)
    WEBREAD_CALLS = strings(0,1);
end
WEBREAD_CALLS(end+1,1) = string(url);

rootDir = fileparts(mfilename('fullpath'));
if endsWith(url, "interactive-single-rulebook/12674")
    html = fileread(fullfile(rootDir, 'root.html'));
elseif endsWith(url, "interactive-single-rulebook/art1")
    html = fileread(fullfile(rootDir, 'art1.html'));
elseif endsWith(url, "interactive-single-rulebook/art2")
    html = fileread(fullfile(rootDir, 'art2.html'));
else
    error("Mock webread: URL not recognized: %s", url);
end
end
