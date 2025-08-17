function [tSec, x] = example_signal()
%EXAMPLE_SIGNAL Deterministic synthetic signal generator (clean-room friendly).
% No domain logic beyond simple deterministic math.
% Returns:
%   tSec : double [N x 1] time in seconds
%   x    : double [N x 1] sample values (arbitrary)

rng(0,'twister');               % deterministic
N = 128;                        % tiny, CI-friendly
tSec = (0:N-1)'/N;
% keep simple and transparent
x = 0.0*tSec;                   % placeholder zeros in clean-room
% When domain logic goes live:
%   - replace x with representative waveform (e.g., sin, chirp) and
%     ensure tolerances and spectral expectations are documented.
end
