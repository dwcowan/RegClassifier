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
            %   displaying results.
            arguments
                model reg.model.CorpusModel = reg.model.CorpusModel()
                view reg.view.DiffView = reg.view.DiffView()
            end
            obj@reg.mvc.BaseController(model, view);
        end

        function T = fetchEba(obj, varargin)
            %FETCHEBA Download CRR articles from EBA Single Rulebook.
            %   T = FETCHEBA(obj, Name, Value, ...) invokes the underlying
            %   model to retrieve HTML/plaintext articles. The metadata
            %   table T mirrors the output of `fetch_crr_eba`.
            arguments
                obj
                varargin (1,:) cell
            end
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
            arguments
                obj
                varargin (1,:) cell
            end
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
            arguments
                obj
                varargin (1,:) cell
            end
            pdfPath = obj.Model.fetchEurlex(varargin{:});
            if ~isempty(obj.View)
                obj.View.display(pdfPath);
            end
        end

        function documents = ingestPdfs(obj, cfg)
            %INGESTPDFS Convert PDFs to a document table via the model.
            %   DOCUMENTS = INGESTPDFS(obj, cfg) delegates to the model's
            %   ingestPdfs method and displays the resulting table when a
            %   view is configured.
            arguments
                obj
                cfg struct
                cfg.inputDir (1,1) string
            end
            documents = obj.Model.ingestPdfs(cfg);
            if ~isempty(obj.View)
                obj.View.display(documents);
            end
        end

        function persistDocuments(obj, documents)
            %PERSISTDOCUMENTS Persist document table through the model.
            %   PERSISTDOCUMENTS(obj, documents) forwards to the model and
            %   displays the input documents when a view is present.
            arguments
                obj
                documents table
            end
            obj.Model.persistDocuments(documents);
            if ~isempty(obj.View)
                obj.View.display(documents);
            end
        end

        function searchIndex = buildIndex(obj, indexInputs)
            %BUILDINDEX Create or update the search index via the model.
            %   searchIndex = BUILDINDEX(obj, indexInputs) calls the model's
            %   buildIndex and forwards the result to the view if available.
            arguments
                obj
                indexInputs struct
                indexInputs.documentsTbl table
                indexInputs.embeddingsMat double
            end
            searchIndex = obj.Model.buildIndex(indexInputs);
            if ~isempty(obj.View)
                obj.View.display(searchIndex);
            end
        end

        function results = queryIndex(obj, queryString, alpha, topK)
            %QUERYINDEX Retrieve ranked documents from the model's index.
            %   RESULTS = QUERYINDEX(obj, queryString, alpha, topK) forwards
            %   to the model and displays results when a view is configured.
            arguments
                obj
                queryString (1,1) string
                alpha (1,1) double
                topK (1,1) double
            end
            results = obj.Model.queryIndex(queryString, alpha, topK);
            if ~isempty(obj.View)
                obj.View.display(results);
            end
        end

        function out = sync(obj, date)
            %SYNC Execute synchronisation for a given date.
            %   OUT = SYNC(obj, date) orchestrates corpus synchronisation.
            arguments
                obj
                date (1,1) string
            end
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
            arguments
                obj
                mode (1,1) string
                varargin (1,:) cell
            end
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
            arguments
                obj
                dirA (1,1) string
                dirB (1,1) string
                outDir (1,1) string
            end
            result = obj.Model.runArticles(dirA, dirB, outDir);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end

        function result = runVersions(obj, dirA, dirB, outDir)
            %RUNVERSIONS Diff directories on a file-by-file basis.
            %   RESULT = RUNVERSIONS(obj, dirA, dirB, outDir) delegates to
            %   the model's runVersions method and displays results.
            arguments
                obj
                dirA (1,1) string
                dirB (1,1) string
                outDir (1,1) string
            end
            result = obj.Model.runVersions(dirA, dirB, outDir);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end

        function report = runReport(obj, dirA, dirB, outDir)
            %RUNREPORT Produce diff reports for two directories.
            %   REPORT = RUNREPORT(obj, dirA, dirB, outDir) orchestrates
            %   generation of diff artefacts using the model.
            arguments
                obj
                dirA (1,1) string
                dirB (1,1) string
                outDir (1,1) string
            end
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
            arguments
                obj
                queries (:,1) string
                chunksT table
                config struct = struct()
            end
            result = obj.Model.runMethods(queries, chunksT, config);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end
    end
end

