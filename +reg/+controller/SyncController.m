classdef SyncController < reg.mvc.BaseController
    %SYNCCONTROLLER Wrapper for CRR synchronization tasks.
    %   Coordinates corpus updates and forwards results to a view.

    methods
        function obj = SyncController(model, view)
            %SYNCCONTROLLER Construct controller wiring model and view.
            %   OBJ = SYNCCONTROLLER(model, view) prepares a SyncModel and
            %   view for presenting synchronization results. MODEL defaults
            %   to `reg.model.SyncModel()` and VIEW defaults to
            %   `reg.view.ReportView()`.
            if nargin < 1 || isempty(model)
                model = reg.model.SyncModel();
            end
            if nargin < 2 || isempty(view)
                view = reg.view.ReportView();
            end
            obj@reg.mvc.BaseController(model, view);
        end

        function out = run(obj, date) %#ok<INUSD>
            %RUN Execute synchronization for a given date.
            %   OUT = RUN(obj, date) orchestrates corpus synchronization.
            %   Steps:
            %       1. Determine target date
            %       2. Synchronize corpus for the date
            %       3. Display summary via view
            error("reg:controller:NotImplemented", ...
                "SyncController.run is not implemented.");
        end
    end
end
