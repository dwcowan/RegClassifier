function outPathStr = crrDiffReport(diffStruct)
%CRRDIFFREPORT Generate placeholder report for CRR diffs.
%   outPathStr = crrDiffReport(diffStruct) returns the path to a placeholder
%   report file summarizing differences in the CRR corpus.
%
% Inputs
%   diffStruct (struct, optional): diff details.
%
% Outputs
%   outPathStr (string): path to the generated report (placeholder).
%
%% NAME-REGISTRY:FUNCTION crrDiffReport
if nargin < 1
  diffStruct = struct();
end
assert(isstruct(diffStruct), 'diffStruct must be a struct.');

outPathStr = string(fullfile(tempdir, 'crr_diff_report_placeholder.txt'));
warning('crrDiffReport:noOp', 'crrDiffReport is a no-op.');
end
