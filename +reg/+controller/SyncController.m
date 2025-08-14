classdef SyncController < reg.mvc.BaseController
    %SYNCCONTROLLER Wrapper for CRR synchronization tasks.
    %   Provides an interface for invoking reg_crr_sync and forwarding the
    %   results to a view.

    properties
        SyncFunction
    end

    methods
        function obj = SyncController(view, syncFunc)
            %SYNCCONTROLLER Construct controller with optional function and view.
            %   OBJ = SYNCCONTROLLER(view, syncFunc) sets up a wrapper around
            %   the synchronization routine. Equivalent to initialization in
            %   `reg_crr_sync`.
            if nargin < 1 || isempty(view)
                view = reg.view.ReportView();
            end
            if nargin < 2 || isempty(syncFunc)
                syncFunc = @reg_crr_sync;
            end
            obj@reg.mvc.BaseController([], view);
            obj.SyncFunction = syncFunc;
        end

        function out = run(obj, date)
            %RUN Execute synchronization for a given date.
            %   OUT = RUN(obj, date) delegates to a sync routine and
            %   forwards results to the view.
            %
            %   Preconditions
            %       * SyncFunction accepts a 'Date' parameter
            %   Side Effects
            %       * May create or update local files and databases
            %       * Displays summary via view
            %
            %   Legacy mapping: invokes `reg_crr_sync`

            % Step 1: determine target date (defaults to today)
            if nargin < 2 || isempty(date)
                date = datestr(now, 'yyyymmdd');
            end

            % Step 2: perform synchronization via legacy routine
            %   SyncFunction should validate the date format and handle
            %   network or IO errors internally.
            out = obj.SyncFunction('Date', date);

            % Step 3: display sync summary
            obj.View.display(out);
        end
    end
end
