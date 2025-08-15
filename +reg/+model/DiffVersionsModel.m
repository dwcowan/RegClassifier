classdef DiffVersionsModel < reg.mvc.BaseModel
  %DIFFVERSIONSMODEL Compute file-level diffs between CRR corpora.
  %   Wraps `crr_diff_versions` providing `load` and `process` hooks for
  %   controllers.

  methods
    function params = load(~, dirA, dirB, outDir)
      %LOAD Prepare parameters for file-level diffing.
      %   params = LOAD(obj, dirA, dirB, outDir) records the directories to
      %   compare and the output directory. Caller must supply outDir.
      if nargin < 4 || isempty(outDir)
        error("reg:model:NotImplemented", ...
          "outDir must be specified; no default directory is provided.");
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

    function diff = compare(obj, dirA, dirB, outDir)
      %COMPARE Orchestrate file-level diffing between two directories.
      %   diff = COMPARE(obj, dirA, dirB, outDir) prepares parameters and
      %   delegates processing to compute differences. Caller must supply
      %   OUTDIR.
      params = obj.load(dirA, dirB, outDir);
      diff = obj.process(params);
    end
  end
end
