classdef DiffArticlesController < reg.mvc.BaseController
    %DIFFARTICLESCONTROLLER Article-aware diff of two CRR corpora.
    %   Wraps `crr_diff_articles` and exposes a controller interface for
    %   comparing two directories produced by `fetch_crr_eba_parsed`.

    properties
        DiffFunction
    end

    methods
        function obj = DiffArticlesController(view, diffFunc)
            %DIFFARTICLESCONTROLLER Construct controller with diff function.
            %   OBJ = DIFFARTICLESCONTROLLER(view, diffFunc) sets the view
            %   and function handle used for article-aware diffing. When
            %   omitted, VIEW defaults to `reg.view.ReportView` and
            %   DIFFFUNC defaults to `@reg.crr_diff_articles`.
            if nargin < 1 || isempty(view)
                view = reg.view.ReportView();
            end
            if nargin < 2 || isempty(diffFunc)
                diffFunc = @reg.crr_diff_articles;
            end
            obj@reg.mvc.BaseController([], view);
            obj.DiffFunction = diffFunc;
        end

        function result = run(obj, dirA, dirB, outDir)
            %RUN Compare CRR corpora by article number.
            %   RESULT = RUN(obj, dirA, dirB, outDir) aligns articles using
            %   the `index.csv` produced by `fetch_crr_eba_parsed` and
            %   writes a CSV summary and a human-readable patch file.
            %   Inputs
            %       dirA, dirB (char/string): Directories each containing an
            %           `index.csv` alongside article text files.
            %       outDir (char/string): Optional directory for diff
            %           artefacts. Default runs/crr_diff_articles.
            %   Returns
            %       result (struct): Counts of added, removed, changed and
            %       same articles plus the output directory.
            %   Errors
            %       * Propagates any errors from the underlying diff
            %         function, e.g. missing `index.csv` or unreadable
            %         files.
            %       * Creates `outDir`; failure to create it raises an
            %         exception.
            if nargin < 4 || isempty(outDir)
                outDir = fullfile('runs', 'crr_diff_articles');
            end
            result = obj.DiffFunction(dirA, dirB, 'OutDir', outDir);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end
    end
end

