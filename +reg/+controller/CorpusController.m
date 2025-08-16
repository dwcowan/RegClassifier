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
            arguments (Output)
                obj reg.controller.CorpusController
            end
            % PSEUDOCODE:
            % - invoke superclass constructor with model and view
            % - assign model and view to the controller instance
            error("reg:controller:NotImplemented", ...
                "CorpusController.CorpusController is not implemented.");
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
            arguments (Output)
                T table
            end
            % PSEUDOCODE:
            % - call obj.Model.fetchEba with varargin to obtain table T
            % - if obj.View is configured, forward T to obj.View.display
            error("reg:controller:NotImplemented", ...
                "CorpusController.fetchEba is not implemented.");
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
            arguments (Output)
                T table
            end
            % PSEUDOCODE:
            % - invoke obj.Model.fetchEbaParsed with varargin to get table T
            % - if a view exists, send T to obj.View.display
            error("reg:controller:NotImplemented", ...
                "CorpusController.fetchEbaParsed is not implemented.");
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
            arguments (Output)
                pdfPath (1,1) string
            end
            % PSEUDOCODE:
            % - obtain consolidated PDF path via obj.Model.fetchEurlex
            % - if a view is set, pass pdfPath to obj.View.display
            error("reg:controller:NotImplemented", ...
                "CorpusController.fetchEurlex is not implemented.");
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
            arguments (Output)
                documents table
            end
            % PSEUDOCODE:
            % - convert PDFs by calling obj.Model.ingestPdfs(cfg)
            % - when obj.View is available, display documents via the view
            error("reg:controller:NotImplemented", ...
                "CorpusController.ingestPdfs is not implemented.");
        end

        function persistDocuments(obj, documentsTbl)
            %PERSISTDOCUMENTS Persist document table through the model.
            %   PERSISTDOCUMENTS(obj, documentsTbl) forwards to the model and
            %   displays the input documentsTbl when a view is present.
            arguments
                obj
                documentsTbl table
            end
            arguments (Output)
            end
            % PSEUDOCODE:
            % - delegate persistence of documentsTbl to obj.Model.persistDocuments
            % - if a view exists, call obj.View.display with documentsTbl
            error("reg:controller:NotImplemented", ...
                "CorpusController.persistDocuments is not implemented.");
        end

        function searchIndex = buildIndex(obj, indexInputsStruct)
            %BUILDINDEX Create or update the search index via the model.
            %   searchIndex = BUILDINDEX(obj, indexInputsStruct) calls the model's
            %   buildIndex and forwards the result to the view if available.
            arguments
                obj
                indexInputsStruct struct
                indexInputsStruct.documentsTbl table
                indexInputsStruct.embeddingsMat double
            end
            arguments (Output)
                searchIndex struct
            end
            % PSEUDOCODE:
            % - build or update index by invoking obj.Model.buildIndex(indexInputsStruct)
            % - if obj.View is set, display searchIndex via the view
            error("reg:controller:NotImplemented", ...
                "CorpusController.buildIndex is not implemented.");
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
            arguments (Output)
                results table
            end
            % PSEUDOCODE:
            % - query the index using obj.Model.queryIndex(queryString, alpha, topK)
            % - if a view exists, present results via obj.View.display
            error("reg:controller:NotImplemented", ...
                "CorpusController.queryIndex is not implemented.");
        end

        function out = sync(obj, date)
            %SYNC Execute synchronisation for a given date.
            %   OUT = SYNC(obj, date) orchestrates corpus synchronisation.
            arguments
                obj
                date (1,1) string
            end
            arguments (Output)
                out struct
            end
            % PSEUDOCODE:
            % - load parameters via obj.Model.load(date)
            % - process parameters with obj.Model.process
            % - if a view exists, display out using obj.View.display
            error("reg:controller:NotImplemented", ...
                "CorpusController.sync is not implemented.");
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
            arguments (Output)
                result struct
            end
            % PSEUDOCODE:
            % - switch on lower(mode)
            % - call runArticles, runVersions, runReport or runMethods as appropriate
            % - return the result from the delegated method
            error("reg:controller:NotImplemented", ...
                "CorpusController.run is not implemented.");
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
            arguments (Output)
                result struct
            end
            % PSEUDOCODE:
            % - execute obj.Model.runArticles(dirA, dirB, outDir)
            % - if obj.View exists, display result via obj.View.display
            error("reg:controller:NotImplemented", ...
                "CorpusController.runArticles is not implemented.");
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
            arguments (Output)
                result struct
            end
            % PSEUDOCODE:
            % - invoke obj.Model.runVersions(dirA, dirB, outDir)
            % - if a view is configured, display result via obj.View.display
            error("reg:controller:NotImplemented", ...
                "CorpusController.runVersions is not implemented.");
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
            arguments (Output)
                report struct
            end
            % PSEUDOCODE:
            % - generate report by calling obj.Model.runReport(dirA, dirB, outDir)
            % - if obj.View is set, forward report to obj.View.display
            error("reg:controller:NotImplemented", ...
                "CorpusController.runReport is not implemented.");
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
            arguments (Output)
                result struct
            end
            % PSEUDOCODE:
            % - compute method differences via obj.Model.runMethods(queries, chunksT, config)
            % - if a view exists, display result using obj.View.display
            error("reg:controller:NotImplemented", ...
                "CorpusController.runMethods is not implemented.");
        end
    end
end

