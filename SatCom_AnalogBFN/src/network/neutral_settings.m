function s = neutral_settings(M)
%NEUTRAL_SETTINGS  Settings struct for bfn_forward with all shifters at 0 deg.
%
%   s = NEUTRAL_SETTINGS()   scalar fields
%   s = NEUTRAL_SETTINGS(M)  1-by-M rows (one setting per column of V)
%
%   phi1..phi5 = 0 deg, kappa = 45 deg (the VRC behaves as a 3-dB hybrid).

    if nargin < 1, M = 1; end
    s.phi1  = zeros(1, M);
    s.phi2  = zeros(1, M);
    s.phi3  = zeros(1, M);
    s.phi4  = zeros(1, M);
    s.phi5  = zeros(1, M);
    s.kappa = 45 * ones(1, M);
end
