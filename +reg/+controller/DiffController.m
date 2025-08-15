classdef DiffController < reg.mvc.BaseController
    %DIFFCONTROLLER Unified controller for diff workflows.
    %   Accepts a diff model and view, dispatching to article, version,
    %   report or method diff logic via MODE or dedicated methods.

    methods
        function obj = DiffController(model, view)
            %DIFFCONTROLLER Construct controller wiring model and view.
            %   OBJ = DIFFCONTROLLER(MODEL, VIEW) sets up a diff model and
            %   view. MODEL defaults to `reg.model.DiffModel()` and
            %   VIEW defaults to `reg.view.DiffView()`.
            if nargin < 1 || isempty(model)
                model = reg.model.DiffModel();
            end
            if nargin < 2 || isempty(view)
                view = reg.view.DiffView();
            end
            obj@reg.mvc.BaseController(model, view);
        end

        function result = run(obj, mode, varargin)
            %RUN Dispatch diff operations based on MODE.
            %   RESULT = RUN(obj, MODE, ...) delegates to a specialised
            %   method according to MODE. Supported modes are 'articles',
            %   'versions', 'report' and 'methods'.
            switch lower(mode)
                case 'articles'
                    result = obj.runArticles(varargin{:});
                case 'versions'
                    result = obj.runVersions(varargin{:});
                case 'report'
                    result = obj.runReport(varargin{:});
                case {'methods', 'method'}
                    result = obj.runMethods(varargin{:});
                otherwise
                    error('reg:controller:UnknownMode', ...
                        'Unknown diff mode: %s', mode);
            end
        end

        function result = runArticles(obj, dirA, dirB, outDir)
            %RUNARTICLES Compare corpora by article number.
            %   RESULT = RUNARTICLES(obj, dirA, dirB, outDir) forwards to
            %   the model's diffArticles implementation and displays results.
            result = obj.Model.diffArticles(dirA, dirB, outDir);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end

        function result = runVersions(obj, dirA, dirB, outDir)
            %RUNVERSIONS Diff directories on a file-by-file basis.
            %   RESULT = RUNVERSIONS(obj, dirA, dirB, outDir) delegates to
            %   the model's diffVersions method and displays results.
            result = obj.Model.diffVersions(dirA, dirB, outDir);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end

        function report = runReport(obj, dirA, dirB, outDir)
            %RUNREPORT Produce diff reports for two directories.
            %   REPORT = RUNREPORT(obj, dirA, dirB, outDir) orchestrates
            %   generation of diff artefacts using the model.
            report = obj.Model.generateReport(dirA, dirB, outDir);
            if ~isempty(obj.View)
                obj.View.display(report);
            end
        end

        function result = runMethods(obj, queries, chunksT, config)
            %RUNMETHODS Compare retrieval across encoder variants.
            %   RESULT = RUNMETHODS(obj, queries, chunksT, config) delegates
            %   to the model to compute method diffs. CONFIG defaults to an
            %   empty struct.
            if nargin < 4
                config = struct();
            end
            result = obj.Model.diffMethods(queries, chunksT, config);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end
    end
end
