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
            %   OUT = RUN(obj, date) calls the underlying sync function and
            %   passes the resulting struct to the view. Equivalent to
            %   invoking `reg_crr_sync`.
            if nargin < 2 || isempty(date)
                date = datestr(now, 'yyyymmdd');
            end
            out = obj.SyncFunction('Date', date);
            obj.View.display(out);
        end
    end
end
