function write_summary(cfg, res)
%WRITE_SUMMARY  results/summary.txt (+ summary.json) with every number used in the presentation.

    Q1 = res.Q1; Q2 = res.Q2; Q3 = res.Q3; Q4 = res.Q4; Q5 = res.Q5;
    file = fullfile(cfg.outDir, 'summary.txt');
    fid  = fopen(file, 'w');
    p = @(varargin) fprintf(fid, varargin{:});

    p('SatCom receiver - analog beamforming network (Student #2)\n');
    p('Run of %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM'));
    p('thetaA = %g deg  (student number ends in %02d)\n', cfg.thetaA, cfg.studentDigits);
    p('N = %d, d = %.2f lambda0, thetaB = %g..%g deg, isotropic elements, lossless BFN\n', ...
      cfg.N, cfg.d_lambda, cfg.thetaB(1), cfg.thetaB(end));
    p('Conventions: hybrid straight path -90 deg, cross path -180 deg (Lecture 4);\n');
    p('             phase shifter multiplies by exp(+j*phi); gain = 20log10|port voltage| (dBi)\n\n');

    p('Q1  psiA = k d sin(thetaA) = %.2f deg\n', Q1.psiA);
    p('    phi1 = %.2f deg, phi2 = %.2f deg, phi3 = %.2f deg  (= %.2f / %.2f / %.2f deg)\n', ...
      Q1.phi, wrap180(Q1.phi));
    p('    port-5 weights: amplitude %s, phase %s deg\n', ...
      sprintf('%.3f ', abs(Q1.w5)), sprintf('%.1f ', wrap180(angle(Q1.w5)*180/pi)));

    p('\nQ2  G_A5 = %.2f dBi for all thetaB\n', Q1.G_A5);
    p('    G_B5: max %.2f dBi at thetaB = thetaA; %.2f dBi at 0 deg; %.2f dBi at 90 deg\n', ...
      max(Q2.G_B5), Q2.G_B5(1), Q2.G_B5(end));
    p('    nulls of G_B5 at thetaB = %s deg\n', sprintf('%.2f ', Q2.nulls));
    p('    strongest sidelobe %.2f dBi at %.1f deg\n', Q2.sidelobe, Q2.sidelobeAt);

    p('\nQ3  phi4 = 90 + 2psiB, phi5 = -90 - psiA - psiB, tan(kappa) = 1 + cos(psiB - psiA)\n');
    p('    VRC power coupling C: %.1f%% .. %.1f%% (limit 80%% at thetaB -> thetaA)\n', ...
      100*min(Q3.C), 100*max(Q3.C));
    p('    max |algorithm - closed form|: phi4 %.1e, phi5 %.1e, kappa %.1e deg\n', ...
      Q3.err.phi4, Q3.err.phi5, Q3.err.kappa);
    p('    thetaB   phi4    phi5   kappa   C[%%]\n');
    for t = cfg.thetaB_table
        [d, i] = min(abs(Q3.thetaB - t));
        if d < 1e-6
            p('    %5.1f  %6.1f  %6.1f  %6.2f  %5.1f\n', Q3.thetaB(i), Q3.phi4(i), Q3.phi5(i), Q3.kappa(i), 100*Q3.C(i));
        end
    end

    p('\nQ4  max |A at port 6| = %.1e (exact null); B lost in loads <= %.1e\n', Q4.maxA6, max(Q4.lossB));
    p('    G_B6 = 10log10(N - |port5_B|^2): %.2f dBi at 0 deg, %.2f dBi at 90 deg, -Inf at thetaA\n', ...
      Q4.G_B6(1), Q4.G_B6(end));
    p('    full 10log10(N) = %.2f dBi where the A beam has its null(s): thetaB = %s deg\n', ...
      Q4.bound, sprintf('%.1f ', Q4.fullGainAt));

    S5 = Q5.stats;  kn = Q5.keepNull;
    p('\nQ5  %d-bit phase shifters, states %s deg (VRC ratio continuous)\n', Q5.nBits, sprintf('%g ', Q5.states));
    p('    phi1..phi3 -> %g / %g / %g deg; G_A5 = %.2f dBi (%+.2f dB), both designs\n', ...
      Q5.A.phi1, Q5.A.phi2, Q5.A.phi3, Q5.G_A5, S5.dG_A5);
    p('    Design 1, keep the exact null on A (meets the port-6 requirement):\n');
    if isempty(kn.combos)
        p('      no 2-bit phi4/phi5 pair can cancel A exactly for this thetaA\n');
    else
        for c = 1:size(kn.combos, 1)
            p('      pair %d: phi4 = %g, phi5 = %g deg, kappa = %.2f deg (C = %.1f %%)\n', c, ...
              kn.combos(c, 1), kn.combos(c, 2), kn.combos(c, 3), 100*sind(kn.combos(c, 3))^2);
        end
        p('      A at port 6: -Inf (numerically %.0f dB); best pair changes at thetaB = %s deg\n', ...
          max(kn.G_A6), sprintf('%.1f ', kn.switchAt));
        p('      change of G_B6 vs Q4 for |thetaB-thetaA| >= %g deg: %+.2f .. %+.2f dB (mean %+.2f dB)\n', ...
          cfg.excludeAroundA, S5.kn_dG_min, S5.kn_dG_max, S5.kn_dG_mean);
    end
    p('    Design 2, maximise B (Q3 algorithm with rounded phases, A may leak):\n');
    p('      change of G_B6 for |thetaB-thetaA| >= %g deg: %+.2f .. %+.2f dB (mean %+.2f dB)\n', ...
      cfg.excludeAroundA, S5.dG_min, S5.dG_max, S5.dG_mean);
    iv = S5.gainIntervals;
    if ~isempty(iv)
        p('      higher than ideal for thetaB in %s deg (close to A this only means the null left thetaA)\n', ...
          strjoin(arrayfun(@(k) sprintf('%.1f-%.1f', iv(k,1), iv(k,2)), 1:size(iv,1), 'UniformOutput', false), ', '));
    end
    iv = S5.lossIntervals;
    if ~isempty(iv)
        p('      lower than ideal for thetaB in %s deg (loss %.2f .. %.2f dB)\n', ...
          strjoin(arrayfun(@(k) sprintf('%.1f-%.1f', iv(k,1), iv(k,2)), 1:size(iv,1), 'UniformOutput', false), ', '), ...
          S5.lossRange);
    end
    p('      A leakage at port 6: %.1f .. %.1f dBi (max %.1f dBi for |thetaB-thetaA| >= %g deg)\n', ...
      S5.A6_min, S5.A6_max, S5.A6_max_far, cfg.excludeAroundA);
    p('      SIR at port 6 away from thetaA: %.1f .. %.1f dB (0 dB at thetaB = thetaA)\n', ...
      S5.SIR6_min_far, S5.SIR6_max_far);
    p('      only phi4/phi5 rounded: %+.2f .. %+.2f dB, no A leakage\n', S5.onlyB_dG_min, S5.onlyB_dG_max);
    p('      exhaustive phi4/phi5 search: up to %+.2f dB more B gain than nearest-state rounding\n', ...
      Q5.exhaustive.maxGain);
    iv = S5.useIntervals;
    p('    Where B is usable (ideal G_B6 >= 0 dBi: thetaB in %s deg):\n', ...
      strjoin(arrayfun(@(k) sprintf('%.1f-%.1f', iv(k,1), iv(k,2)), 1:size(iv,1), 'UniformOutput', false), ', '));
    p('      keep null : B change %+.2f .. %+.2f dB (mean %+.2f dB), A -Inf\n', S5.use_kn_dG, S5.use_kn_mean);
    p('      maximise B: B change %+.2f .. %+.2f dB, A at port 6 %.1f .. %.1f dBi, SIR %.1f .. %.1f dB\n', ...
      S5.use_dG, S5.use_A6, S5.use_SIR6);
    p('    Resolution sweep (B: where ideal G_B6 >= 0 dBi; A: |thetaB-thetaA| >= %g deg)\n', cfg.excludeAroundA);
    p('    bits | design 2: worst B loss | rms change | worst A at port 6 | worst SIR6 | design 1: worst B loss (pairs)\n');
    for k = 1:numel(Q5.sweep.bits)
        p('    %4d | %9.2f dB | %8.2f dB | %10.1f dBi | %7.1f dB | %9.2f dB (%d)\n', Q5.sweep.bits(k), ...
          Q5.sweep.lossMax(k), Q5.sweep.dG_rms(k), Q5.sweep.A6_max(k), Q5.sweep.SIR_min(k), ...
          Q5.sweep.knLossMax(k), Q5.sweep.knPairs(k));
    end
    fclose(fid);
    fprintf('\n  summary -> %s\n', file);

    % machine-readable copy of the same numbers
    try
        S = struct('thetaA', cfg.thetaA, ...
                   'psiA', Q1.psiA, 'phi123', Q1.phi, 'G_A5', Q1.G_A5, ...
                   'w5_amp', abs(Q1.w5).', 'w5_phase', wrap180(angle(Q1.w5).'*180/pi), ...
                   'Q2_nulls', Q2.nulls, 'Q2_sidelobe', [Q2.sidelobe Q2.sidelobeAt], ...
                   'Q2_GB5_0_90', [Q2.G_B5(1) Q2.G_B5(end)], ...
                   'Q3_C_range', 100*[min(Q3.C) max(Q3.C)], ...
                   'Q4_GB6_0_90', [Q4.G_B6(1) Q4.G_B6(end)], 'Q4_maxA6', Q4.maxA6, ...
                   'Q5_phi123', [Q5.A.phi1 Q5.A.phi2 Q5.A.phi3], 'Q5_G_A5', Q5.G_A5, ...
                   'Q5_stats', Q5.stats, 'Q5_exhaustive', Q5.exhaustive.maxGain, ...
                   'Q5_keepNull_pairs', Q5.keepNull.combos, 'Q5_keepNull_switchAt', Q5.keepNull.switchAt, ...
                   'Q5_sweep', Q5.sweep);
        fid = fopen(fullfile(cfg.outDir, 'summary.json'), 'w');
        fprintf(fid, '%s', jsonencode(S));
        fclose(fid);
    catch err
        fprintf('  (summary.json skipped: %s)\n', err.message);
    end
end
