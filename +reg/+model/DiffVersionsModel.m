classdef DiffVersionsModel < reg.mvc.BaseModel
  %DIFFVERSIONSMODEL Compute file-level diffs between CRR corpora.
  %   Wraps `crr_diff_versions` providing `load` and `process` hooks for
  %   controllers.

  methods
    function params = load(~, dirA, dirB, outDir)
      %LOAD Prepare parameters for file-level diffing.
      %   params = LOAD(obj, dirA, dirB, outDir) records the directories to
      %   compare and the output directory. outDir defaults to runs/crr_diff.
      if nargin < 4 || isempty(outDir)
        outDir = fullfile('runs', 'crr_diff');
      end
      params = struct('dirA', dirA, 'dirB', dirB, 'outDir', outDir);
    end

    function result = process(~, params) %#ok<INUSD>
      %PROCESS Execute file-level diffing and return results.
      %   RESULT = PROCESS(obj, params) should compare directory trees and
      %   report line-level differences.
      %   Legacy Reference
      %       Equivalent to `reg.crr_diff_versions`.
      %   Pseudocode:
      %       1. Align files by relative path
      %       2. Compute line-level diffs and statistics
      %       3. Return struct with summary tables and patch file paths
      error("reg:model:NotImplemented", ...
        "DiffVersionsModel.process is not implemented.");
    end
  end
end
