classdef CorpusFetchModel < reg.mvc.BaseModel
    %CORPUSFETCHMODEL Retrieve CRR corpora from public sources.
    %   Unified model exposing helper methods for downloading articles from
    %   the EBA Single Rulebook, the consolidated PDF from EUR-Lex and
    %   orchestrating full corpus synchronisation.

    methods
        function params = load(~, date)
            %LOAD Prepare parameters for synchronisation.
            %   params = LOAD(obj, date) records the target snapshot date.
            %   Parameters
            %       date (char): target snapshot date in yyyymmdd format
            %           (must be provided explicitly)
            %   Returns
            %       params (struct): struct with field
            %           date - synchronisation date
            if nargin < 2 || isempty(date)
                error("reg:model:NotImplemented", ...
                    "date must be specified; default current date removed.");
            end
            params = struct('date', date);
        end

        function out = process(obj, params)
            %PROCESS Synchronise local corpus from upstream sources.
            %   out = PROCESS(obj, params) delegates to `sync` and returns
            %   its output.
            out = obj.sync(params);
        end

        function T = fetchEba(~, varargin) %#ok<INUSD>
            %FETCHEBA Download CRR articles from the EBA Single Rulebook.
            %   T = FETCHEBA(obj, Name, Value, ...) retrieves HTML and
            %   plaintext versions of CRR articles.
            %   Returns metadata table mirroring `fetch_crr_eba`.
            %   Pseudocode:
            %       1. Issue HTTP requests for CRR articles
            %       2. Write HTML/plaintext files and index.csv
            %       3. Return table describing downloaded artefacts
            error("reg:model:NotImplemented", ...
                "CorpusFetchModel.fetchEba is not implemented.");
        end

        function T = fetchEbaParsed(~, varargin) %#ok<INUSD>
            %FETCHEBAPARSED Download CRR articles with parsed numbers.
            %   T = FETCHEBAPARSED(obj, Name, Value, ...) augments each
            %   article with a parsed `article_num` identifier.
            %   Pseudocode:
            %       1. Fetch articles as in fetchEba
            %       2. Parse article numbers into `article_num`
            %       3. Return metadata table including `article_num`
            error("reg:model:NotImplemented", ...
                "CorpusFetchModel.fetchEbaParsed is not implemented.");
        end

        function pdfPath = fetchEurlex(~, varargin) %#ok<INUSD>
            %FETCHEURLEX Download consolidated CRR PDF from EUR-Lex.
            %   pdfPath = FETCHEURLEX(obj, Name, Value, ...) retrieves the
            %   consolidated regulation PDF.
            %   Pseudocode:
            %       1. Build download URL from consolidation code
            %       2. Download PDF into data/raw
            %       3. Return absolute file path
            error("reg:model:NotImplemented", ...
                "CorpusFetchModel.fetchEurlex is not implemented.");
        end

        function out = sync(~, params) %#ok<INUSD>
            %SYNC Synchronise local corpus from upstream sources.
            %   out = SYNC(obj, params) should fetch data for params.date.
            %   Returns
            %       out (struct): struct with fields
            %           eba_dir   - directory containing EBA files
            %           eba_index - path to index CSV within eba_dir
            %   Pseudocode:
            %       1. Resolve remote resources for params.date
            %       2. Download and unpack corpus
            %       3. Build index files and return paths
            error("reg:model:NotImplemented", ...
                "CorpusFetchModel.sync is not implemented.");
        end
    end
end
