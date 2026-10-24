function print_banner(cfg)
%PRINT_BANNER  Console header with the run parameters.
    fprintf('==============================================================\n');
    fprintf(' SatCom receiver - analog beamforming network (Student #2)\n');
    fprintf(' N = %d isotropic elements, d = %.2f lambda0, lossless network\n', cfg.N, cfg.d_lambda);
    fprintf(' thetaA = %g deg   (student number ends in %02d)\n', cfg.thetaA, cfg.studentDigits);
    fprintf(' thetaB = %g ... %g deg (%d points)\n', cfg.thetaB(1), cfg.thetaB(end), numel(cfg.thetaB));
    if cfg.isOctave
        fprintf(' running in GNU Octave %s\n', OCTAVE_VERSION);
    else
        fprintf(' running in MATLAB %s\n', version);
    end
    fprintf('==============================================================\n');
end
