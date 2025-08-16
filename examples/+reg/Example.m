classdef Example
%EXAMPLE Demonstrates clean-room + MonkeyProof-aligned MATLAB conventions.
% 
% Purpose
%   Canonical stub showing contracts, naming, units, and style.
%
% When domain logic goes live:
%   - Replace NotImplemented error with real implementation.
%   - Preserve inputs/outputs and error IDs unless versioned API change.
%
% See also: reg.utils, reg.controllers

    properties (Access=public)
        % samplingRateHz : double [1x1], >0
        samplingRateHz double {mustBePositive} = 1000
        % isEnabled : logical [1x1]
        isEnabled logical = false
    end

    methods (Access=public)
        function obj = Example(varargin)
        %EXAMPLE Construct an Example object.
        % Name–Value pairs:
        %   SamplingRateHz : double [1x1], >0
        %   IsEnabled      : logical [1x1]
            arguments
                varargin{:}
            end
            % Pseudocode only:
            % - Parse Name–Value pairs into properties.
            % - Validate invariants.
            error("reg:model:NotImplemented", "Stub only – business logic not allowed");
        end

        function nObs = estimateObservationCount(obj, durationSec)
        %estimateObservationCount Contract-only, no logic.
        % input:
        %   durationSec : double [1x1], >=0  (units: seconds)
        % output:
        %   nObs        : double [1x1]       (count prefix n)
            arguments
                obj (1,1) reg.Example
                durationSec (1,1) double {mustBeGreaterThanOrEqual(durationSec,0)}
            end
            % Pseudocode:
            % - nObs = round(durationSec * obj.samplingRateHz);
            % - Ensure nObs is finite and nonnegative.
            error("reg:model:NotImplemented", "Stub only – business logic not allowed");
        end
    end
end
