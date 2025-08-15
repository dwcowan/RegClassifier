classdef CorpusController < reg.mvc.BaseController
    %CORPUSCONTROLLER Retrieve and compare CRR corpora.
    %   Provides high-level methods for downloading articles from the EBA
    %   Single Rulebook, the consolidated PDF from EUR-Lex, running full
    %   corpus synchronisation and executing diff workflows. Results may be
    %   forwarded to a view such as `reg.view.DiffView`.

    methods
        function obj = CorpusController(model, view)
            %CORPUSCONTROLLER Construct controller wiring model and view.
            %   OBJ = CORPUSCONTROLLER(model, view) creates a controller
            %   backed by a `reg.model.CorpusModel` and a view for
            %   displaying results. MODEL defaults to
            %   `reg.model.CorpusModel()` and VIEW defaults to
            %   `reg.view.DiffView()`.
            if nargin < 1 || isempty(model)
                model = reg.model.CorpusModel();
            end
            if nargin < 2 || isempty(view)
                view = reg.view.DiffView();
            end
            obj@reg.mvc.BaseController(model, view);
        end

        function T = fetchEba(obj, varargin)
            %FETCHEBA Download CRR articles from EBA Single Rulebook.
            %   T = FETCHEBA(obj, Name, Value, ...) invokes the underlying
            %   model to retrieve HTML/plaintext articles. The metadata
            %   table T mirrors the output of `fetch_crr_eba`.
            T = obj.Model.fetchEba(varargin{:});
            if ~isempty(obj.View)
                obj.View.display(T);
            end
        end

        function T = fetchEbaParsed(obj, varargin)
            %FETCHEBAPARSED Download CRR articles with parsed numbers.
            %   T = FETCHEBAPARSED(obj, Name, Value, ...) retrieves
            %   articles and augments metadata with a parsed `article_num`
            %   column. The table is forwarded to the configured view when
            %   present.
            T = obj.Model.fetchEbaParsed(varargin{:});
            if ~isempty(obj.View)
                obj.View.display(T);
            end
        end

        function pdfPath = fetchEurlex(obj, varargin)
            %FETCHEURLEX Download consolidated CRR PDF from EUR-Lex.
            %   pdfPath = FETCHEURLEX(obj, Name, Value, ...) downloads the
            %   consolidated regulation PDF and returns the file path. The
            %   path is forwarded to the view if one is configured.
            pdfPath = obj.Model.fetchEurlex(varargin{:});
            if ~isempty(obj.View)
                obj.View.display(pdfPath);
            end
        end

        function documents = ingestPdfs(obj, cfg)
            %INGESTPDFS Convert PDFs to a document table via the model.
            %   documents = INGESTPDFS(obj, cfg) delegates to the model's
            %   ingestPdfs method and displays the resulting table when a
            %   view is configured.
            documents = obj.Model.ingestPdfs(cfg);
            if ~isempty(obj.View)
                obj.View.display(documents);
            end
        end

        function persistDocuments(obj, documents)
            %PERSISTDOCUMENTS Persist document structs through the model.
            %   PERSISTDOCUMENTS(obj, documents) forwards to the model and
            %   displays the input documents when a view is present.
            obj.Model.persistDocuments(documents);
            if ~isempty(obj.View)
                obj.View.display(documents);
            end
        end

        function searchIndex = buildIndex(obj, indexInputs)
            %BUILDINDEX Create or update the search index via the model.
            %   searchIndex = BUILDINDEX(obj, indexInputs) calls the model's
            %   buildIndex and forwards the result to the view if available.
            searchIndex = obj.Model.buildIndex(indexInputs);
            if ~isempty(obj.View)
                obj.View.display(searchIndex);
            end
        end

        function results = queryIndex(obj, queryString, alpha, topK)
            %QUERYINDEX Retrieve ranked documents from the model's index.
            %   results = QUERYINDEX(obj, queryString, alpha, topK) forwards
            %   to the model and displays results when a view is configured.
            results = obj.Model.queryIndex(queryString, alpha, topK);
            if ~isempty(obj.View)
                obj.View.display(results);
            end
        end

        function out = sync(obj, date)
            %SYNC Execute synchronisation for a given date.
            %   OUT = SYNC(obj, date) orchestrates corpus synchronisation.
            params = obj.Model.load(date);
            out = obj.Model.process(params);
            if ~isempty(obj.View)
                obj.View.display(out);
            end
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
            %   the model's runArticles implementation and displays results.
            result = obj.Model.runArticles(dirA, dirB, outDir);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end

        function result = runVersions(obj, dirA, dirB, outDir)
            %RUNVERSIONS Diff directories on a file-by-file basis.
            %   RESULT = RUNVERSIONS(obj, dirA, dirB, outDir) delegates to
            %   the model's runVersions method and displays results.
            result = obj.Model.runVersions(dirA, dirB, outDir);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end

        function report = runReport(obj, dirA, dirB, outDir)
            %RUNREPORT Produce diff reports for two directories.
            %   REPORT = RUNREPORT(obj, dirA, dirB, outDir) orchestrates
            %   generation of diff artefacts using the model.
            report = obj.Model.runReport(dirA, dirB, outDir);
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
            result = obj.Model.runMethods(queries, chunksT, config);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end
    end
end

