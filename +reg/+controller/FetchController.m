classdef FetchController < reg.mvc.BaseController
    %FETCHCONTROLLER Retrieve and synchronise CRR corpora.
    %   Provides high-level methods for downloading articles from the EBA
    %   Single Rulebook, the consolidated PDF from EUR-Lex and for running
    %   full corpus synchronisation. Results may optionally be forwarded to
    %   a view such as `reg.view.ReportView`.

    methods
        function obj = FetchController(model, view)
            %FETCHCONTROLLER Construct controller wiring model and view.
            %   OBJ = FETCHCONTROLLER(model, view) creates a controller
            %   backed by a `reg.model.CorpusFetchModel` and a view for
            %   displaying results. MODEL defaults to
            %   `reg.model.CorpusFetchModel()` and VIEW defaults to
            %   `reg.view.ReportView()`.
            if nargin < 1 || isempty(model)
                model = reg.model.CorpusFetchModel();
            end
            if nargin < 2 || isempty(view)
                view = reg.view.ReportView();
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

        function out = sync(obj, date)
            %SYNC Execute synchronisation for a given date.
            %   OUT = SYNC(obj, date) orchestrates corpus synchronisation.
            params = obj.Model.load(date);
            out = obj.Model.process(params);
            if ~isempty(obj.View)
                obj.View.display(out);
            end
        end
    end
end
