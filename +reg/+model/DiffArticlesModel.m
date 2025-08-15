classdef DiffArticlesModel < reg.mvc.BaseModel
  %DIFFARTICLESMODEL Compute article-level diffs between CRR corpora.
  %   Encapsulates `crr_diff_articles` and exposes `load` and `process`
  %   methods for controllers.

  methods
    function params = load(~, dirA, dirB, outDir)
      %LOAD Prepare parameters for article-level diffing.
      %   params = LOAD(obj, dirA, dirB, outDir) stores the directories to
      %   compare and selects an output directory for diff artefacts.
      %   outDir must be specified by the caller; no default is provided.
      if nargin < 4 || isempty(outDir)
        error("reg:model:NotImplemented", ...
          "outDir must be specified; no default directory is provided.");
      end
      params = struct('dirA', dirA, 'dirB', dirB, 'outDir', outDir);
    end

    function result = process(~, params) %#ok<INUSD>
      %PROCESS Execute article-aware diffing and return results.
      %   RESULT = PROCESS(obj, params) should compare articles between
      %   two directories and emit summary statistics.
      %   Legacy Reference
      %       Equivalent to `reg.crr_diff_articles`.
      %   Pseudocode:
      %       1. Align articles using index.csv files
      %       2. Compute textual differences per article
      %       3. Return struct with diff statistics and artefact paths
      error("reg:model:NotImplemented", ...
        "DiffArticlesModel.process is not implemented.");
    end
  end
end
