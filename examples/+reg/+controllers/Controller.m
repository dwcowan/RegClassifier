classdef Controller
%Controller Layered example: controller orchestrates only.
%
% When domain logic goes live:
%   - Keep orchestration only; delegate rules to models.
%   - Preserve contracts and error IDs.

    methods (Static)
        function runPipeline(opts)
        % runPipeline Orchestrator entry.
        % input:
        %   opts.samplingRateHz : double [1x1], >0
        %   opts.durationSec    : double [1x1], >=0
            arguments
                opts struct
            end
            % Pseudocode:
            % - call reg.models.SignalModel.plan(...)
            % - call reg.views.Report.render(...)
            error("reg:controller:NotImplemented", "Stub only – business logic not allowed");
        end
    end
end
