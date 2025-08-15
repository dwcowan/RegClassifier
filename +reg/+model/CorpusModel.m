classdef CorpusModel < reg.mvc.BaseModel
    %CORPUSMODEL Manage CRR corpus retrieval and comparison.
    %   Unified model exposing helper methods for downloading articles from
    %   the EBA Single Rulebook, the consolidated PDF from EUR-Lex,
    %   orchestrating full corpus synchronisation and running diff
    %   workflows.

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
                "CorpusModel.fetchEba is not implemented.");
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
                "CorpusModel.fetchEbaParsed is not implemented.");
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
                "CorpusModel.fetchEurlex is not implemented.");
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
                "CorpusModel.sync is not implemented.");
        end

        function result = runArticles(~, dirA, dirB, outDir)
            %RUNARTICLES Compare corpora by article number.
            %   RESULT = RUNARTICLES(obj, dirA, dirB, outDir) should align
            %   documents by article identifiers and compute differences.
            %   Legacy Reference
            %       Equivalent to `reg.crr_diff_articles`.
            error("reg:model:NotImplemented", ...
                "CorpusModel.runArticles is not implemented.");
        end

        function diff = runVersions(~, dirA, dirB, outDir)
            %RUNVERSIONS Compute file-level diffs between directories.
            %   DIFF = RUNVERSIONS(obj, dirA, dirB, outDir) should compare
            %   file versions and report line-level changes.
            %   Legacy Reference
            %       Equivalent to `reg.crr_diff_versions`.
            error("reg:model:NotImplemented", ...
                "CorpusModel.runVersions is not implemented.");
        end

        function report = runReport(~, dirA, dirB, outDir)
            %RUNREPORT Produce diff reports for two directories.
            %   REPORT = RUNREPORT(obj, dirA, dirB, outDir) should
            %   generate PDF and HTML artifacts summarising differences.
            %   Legacy Reference
            %       Equivalent to `reg_crr_diff_report` and
            %       `reg_crr_diff_report_html`.
            error("reg:model:NotImplemented", ...
                "CorpusModel.runReport is not implemented.");
        end

        function result = runMethods(~, queries, chunksT, config)
            %RUNMETHODS Compare retrieval across encoder variants.
            %   RESULT = RUNMETHODS(obj, queries, chunksT, config) should
            %   evaluate alternative embedding methods on QUERY strings
            %   against CHUNKST table. CONFIG defaults to an empty struct.
            if nargin < 4
                config = struct();
            end %#ok<NASGU>
            error("reg:model:NotImplemented", ...
                "CorpusModel.runMethods is not implemented.");
        end
    end
end
