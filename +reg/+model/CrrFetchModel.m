classdef CrrFetchModel < reg.mvc.BaseModel
    %CRRFETCHMODEL Retrieve CRR corpora from public sources.
    %   Encapsulates helper functions that download Capital Requirements
    %   Regulation (CRR) documents from the EBA Interactive Single Rulebook
    %   and the EUR‑Lex portal. The model exposes convenience methods for
    %   fetching raw HTML/plaintext articles or the consolidated PDF.
    %   Each method mirrors an existing procedural helper whilst providing
    %   a documented entry point for controllers.

    methods
        function T = fetchEba(~, varargin)
            %FETCHEBA Download CRR articles from the EBA Single Rulebook.
            %   T = FETCHEBA(obj, Name, Value, ...) retrieves HTML and
            %   plaintext versions of CRR articles using the legacy helper
            %   `fetch_crr_eba`.
            %   Parameters
            %       'Timeout'     (double)  - HTTP timeout per request in
            %                                  seconds. Default 15.
            %       'MaxArticles' (double)  - Maximum number of articles to
            %                                  download. Default Inf.
            %   Returns
            %       T (table): Metadata with columns `article_id`, `title`,
            %       `url` and `html_file` describing downloaded artefacts.
            %   Side Effects
            %       * Writes HTML and plaintext files under
            %         data/eba_isrb/crr.
            %       * Persists an `index.csv` alongside the files.
            %   Errors
            %       * Network failures or write errors emit warnings and
            %         return any successfully fetched articles.
            %       * Interrupt exceptions are rethrown to allow graceful
            %         termination.
            T = reg.fetch_crr_eba(varargin{:});
        end

        function T = fetchEbaParsed(~, varargin)
            %FETCHEBAPARSED Download CRR articles with parsed article numbers.
            %   T = FETCHEBAPARSED(obj, Name, Value, ...) wraps
            %   `fetch_crr_eba_parsed` which augments each article with a
            %   parsed `article_num` identifier.
            %   Parameters
            %       'OutDir' (string/char) - Output directory for HTML,
            %                               text and index files. Defaults
            %                               to data/eba_isrb/crr.
            %   Returns
            %       T (table): Metadata including `article_id`, `article_num`,
            %       `title`, `url` and `html_file`.
            %   Side Effects
            %       * Creates `OutDir` if it does not exist.
            %       * Writes HTML/plaintext files and an `index.csv`.
            %   Errors
            %       * Download issues generate warnings; rows for failed
            %         articles are omitted from the returned table.
            %       * Directory creation problems propagate as errors.
            T = reg.fetch_crr_eba_parsed(varargin{:});
        end

        function pdfPath = fetchEurlex(~, varargin)
            %FETCHEURLEX Download consolidated CRR PDF from EUR‑Lex.
            %   pdfPath = FETCHEURLEX(obj, Name, Value, ...) wraps
            %   `fetch_crr_eurlex` which retrieves the consolidated CRR
            %   regulation as a single PDF.
            %   Parameters
            %       'Date' (string/char) - Consolidation code in YYYYMMDD
            %                              format identifying the desired
            %                              version. Default 20250629.
            %   Returns
            %       pdfPath (string): Absolute path to the downloaded PDF
            %       saved under data/raw.
            %   Side Effects
            %       * Creates the data/raw directory if needed and writes
            %         the PDF file within it.
            %   Errors
            %       * Any network or file system failure results in an
            %         error being thrown; callers should handle these to
            %         recover or retry.
            pdfPath = reg.fetch_crr_eurlex(varargin{:});
        end
    end
end

