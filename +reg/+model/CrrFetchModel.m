classdef CrrFetchModel < reg.mvc.BaseModel
    %CRRFETCHMODEL Retrieve CRR corpora from public sources.
    %   Encapsulates helper functions that download Capital Requirements
    %   Regulation (CRR) documents from the EBA Interactive Single Rulebook
    %   and the EUR‑Lex portal. The model exposes convenience methods for
    %   fetching raw HTML/plaintext articles or the consolidated PDF.
    %   Each method mirrors an existing procedural helper whilst providing
    %   a documented entry point for controllers.

    methods
        function T = fetchEba(~, varargin) %#ok<INUSD>
            %FETCHEBA Download CRR articles from the EBA Single Rulebook.
            %   T = FETCHEBA(obj, Name, Value, ...) retrieves HTML and
            %   plaintext versions of CRR articles.
            %   Returns metadata table mirroring `fetch_crr_eba`.
            %   Legacy Reference
            %       Equivalent to `fetch_crr_eba`.
            %   Pseudocode:
            %       1. Issue HTTP requests for CRR articles
            %       2. Write HTML/plaintext files and index.csv
            %       3. Return table describing downloaded artefacts
            error("reg:model:NotImplemented", ...
                "CrrFetchModel.fetchEba is not implemented.");
        end

        function T = fetchEbaParsed(~, varargin) %#ok<INUSD>
            %FETCHEBAPARSED Download CRR articles with parsed article numbers.
            %   T = FETCHEBAPARSED(obj, Name, Value, ...) augments each
            %   article with a parsed `article_num` identifier.
            %   Legacy Reference
            %       Equivalent to `fetch_crr_eba_parsed`.
            %   Pseudocode:
            %       1. Fetch articles as in fetchEba
            %       2. Parse article numbers into `article_num`
            %       3. Return metadata table including `article_num`
            error("reg:model:NotImplemented", ...
                "CrrFetchModel.fetchEbaParsed is not implemented.");
        end

        function pdfPath = fetchEurlex(~, varargin) %#ok<INUSD>
            %FETCHEURLEX Download consolidated CRR PDF from EUR‑Lex.
            %   pdfPath = FETCHEURLEX(obj, Name, Value, ...) retrieves the
            %   consolidated regulation PDF.
            %   Legacy Reference
            %       Equivalent to `fetch_crr_eurlex`.
            %   Pseudocode:
            %       1. Build download URL from consolidation code
            %       2. Download PDF into data/raw
            %       3. Return absolute file path
            error("reg:model:NotImplemented", ...
                "CrrFetchModel.fetchEurlex is not implemented.");
        end
    end
end

