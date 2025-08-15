classdef SyncModel < reg.mvc.BaseModel
    %SYNCMODEL Stub model to synchronize CRR corpora.
    %   Handles coordination of remote fetches and local directory
    %   preparation.

    methods
        function params = load(~, date)
            %LOAD Prepare parameters for synchronization.
            %   params = LOAD(obj, date) records the target snapshot date.
            %   Parameters
            %       date (char): target snapshot date in yyyymmdd format
            %           (must be provided explicitly)
            %   Returns
            %       params (struct): struct with field
            %           date - synchronization date
            if nargin < 2 || isempty(date)
                error("reg:model:NotImplemented", ...
                    "date must be specified; default current date removed.");
            end
            params = struct('date', date);
        end

        function out = process(~, params) %#ok<INUSD>
            %PROCESS Synchronize local corpus from upstream sources.
            %   out = PROCESS(obj, params) should fetch data for params.date.
            %   Parameters
            %       params (struct): output of LOAD.
            %   Returns
            %       out (struct): struct with fields
            %           eba_dir   - directory containing EBA files
            %           eba_index - path to index CSV within eba_dir
            %   Side Effects
            %       Creates or updates local files and databases.
            %   Legacy Reference
            %       Equivalent to `reg_crr_sync`.
            %   Pseudocode:
            %       1. Resolve remote resources for params.date
            %       2. Download and unpack corpus
            %       3. Build index files and return paths
            error("reg:model:NotImplemented", ...
                "SyncModel.process is not implemented.");
        end
    end
end
