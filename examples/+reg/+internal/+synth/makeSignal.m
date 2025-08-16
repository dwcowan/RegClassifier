function x = makeSignal(nObs, varargin)
%makeSignal Generate deterministic synthetic signal data.
% input:
%   nObs : double [1x1], >=1  (count prefix n)
% Name-Value:
%   RateHz : double [1x1], >0 (default 100)
%   NoiseStd : double [1x1], >=0 (default 0.05)
%
% Notes
% - Deterministic: rng(0,'twister') unless caller already seeded.
    arguments
        nObs (1,1) double {mustBeGreaterThanOrEqual(nObs,1)}
    end
    arguments (Repeating)
        varargin
    end
    % Pseudocode only in clean-room; real generation in build:
    % - rng(0,'twister');
    % - t = (0:nObs-1).'/RateHz;
    % - x = sin(2*pi*1.0*t) + NoiseStd*randn(size(t));
    error("reg:model:NotImplemented", "Stub only – business logic not allowed");
end
