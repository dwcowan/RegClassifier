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

    function result = process(~, params)
      %PROCESS Execute file-level diffing and return results.
      %   result = PROCESS(obj, params) calls `reg.crr_diff_versions` with
      %   the supplied parameters and returns the diff statistics.
      result = reg.crr_diff_versions(params.dirA, params.dirB, ...
        'OutDir', params.outDir);
    end
  end
end
