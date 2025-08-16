classdef SignalModel
%SignalModel Layered example: model owns contracts/data rules.

    methods (Static)
        function plan = plan(samplingRateHz, durationSec)
        % plan Produce a plan DTO (stub only).
        % input:
        %   samplingRateHz : double [1x1], >0
        %   durationSec    : double [1x1], >=0
        % output:
        %   plan : struct with fields
        %       nObs : double [1x1]
            arguments
                samplingRateHz (1,1) double {mustBePositive}
                durationSec    (1,1) double {mustBeGreaterThanOrEqual(durationSec,0)}
            end
            % Pseudocode:
            % - nObs = round(samplingRateHz * durationSec);
            % - plan = struct('nObs', nObs);
            error("reg:model:NotImplemented", "Stub only – business logic not allowed");
        end
    end
end
