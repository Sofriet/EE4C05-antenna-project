function cfg = config()
%CONFIG  Settings for the analog SatCom receive beamformer (Student #2).
%
%   cfg = CONFIG() returns the settings struct used by main.m and by every
%   function in src/ and questions/.
%
%   EE4C05 Electromagnetics - Antennas & Beamforming Fundamentals track
%   Assignment "SatCom receiver beamformer", Student #2 (analog beamforming).

    % ---- thetaA from the student number (assignment, slide 4) -------------
    %  thetaA = xx if xx <= 90, thetaA = xx - 90 if xx > 90, with xx the last
    %  two digits of the student number. Mine end in 98, so thetaA = 8 deg.
    cfg.studentDigits = 98;
    cfg.thetaA        = thetaA_from_digits(cfg.studentDigits);   % [deg]

    % ---- Array (assignment, slide 4) --------------------------------------
    cfg.N        = 4;                     % number of isotropic elements (fixed by the network)
    cfg.d_lambda = 0.5;                   % element spacing d / lambda0

    % ---- Angle grids [deg] ------------------------------------------------
    cfg.thetaB          = 0:0.1:90;       % sweep of satellite B (row vector)
    cfg.thetaPattern    = -90:0.1:90;     % angles for full beam patterns
    cfg.thetaB_patterns = [0 45 75];      % B designs drawn in the port-6 pattern plot
    cfg.thetaB_table    = 0:10:90;        % angles printed in the console / tables

    % ---- Phase-shifter resolution (Q5) ------------------------------------
    cfg.nBits          = 2;               % 2 bits -> states 0, 90, 180, 270 deg
    cfg.nBitsSweep     = 1:6;             % backup: resolution study
    cfg.excludeAroundA = 5;               % [deg] |thetaB - thetaA| left out of Q5 statistics

    % ---- Output -----------------------------------------------------------
    cfg.rootDir     = fileparts(mfilename('fullpath'));
    cfg.outDir      = fullfile(cfg.rootDir, 'results');
    cfg.saveFigures = true;
    cfg.figFormats  = {'png'};            % add 'fig' (MATLAB only) and/or 'pdf'
    cfg.dpi         = 200;
    cfg.showFigures = true;               % false: draw off-screen (batch runs)
end

function thetaA = thetaA_from_digits(xx)
%THETAA_FROM_DIGITS  Assignment rule: thetaA = xx, or xx - 90 if xx > 90.
    if xx > 90
        thetaA = xx - 90;
    else
        thetaA = xx;
    end
end
