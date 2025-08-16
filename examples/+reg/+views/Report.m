classdef Report
%Report Layered example: view concerns formatting/rendering only.

    methods (Static)
        function render(plan)
        % render Produce a human-readable report (stub only).
        % input:
        %   plan.nObs : double [1x1]
            arguments
                plan struct
            end
            % Pseudocode:
            % - fprintf('Planned observations: %d\n', plan.nObs);
            error("reg:view:NotImplemented", "Stub only – business logic not allowed");
        end
    end
end
