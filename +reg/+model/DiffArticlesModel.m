classdef DiffArticlesModel < reg.mvc.BaseModel
  %DIFFARTICLESMODEL Compute article-level diffs between CRR corpora.
  %   Encapsulates `crr_diff_articles` and exposes `load` and `process`
  %   methods for controllers.

  methods
    function params = load(~, dirA, dirB, outDir)
      %LOAD Prepare parameters for article-level diffing.
      %   params = LOAD(obj, dirA, dirB, outDir) stores the directories to
      %   compare and selects an output directory for diff artefacts.
      %   When omitted, outDir defaults to runs/crr_diff_articles.
      if nargin < 4 || isempty(outDir)
        outDir = fullfile('runs', 'crr_diff_articles');
      end
      params = struct('dirA', dirA, 'dirB', dirB, 'outDir', outDir);
    end

    function result = process(~, params)
      %PROCESS Execute article-aware diffing and return results.
      %   result = PROCESS(obj, params) wraps `reg.crr_diff_articles` using
      %   the previously loaded parameters.
      result = reg.crr_diff_articles(params.dirA, params.dirB, ...
        'OutDir', params.outDir);
    end
  end
end
