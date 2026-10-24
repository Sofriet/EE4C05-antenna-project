function Q5 = q5_two_bit(cfg, Q1, Q3, Q4)
%Q5_TWO_BIT  Q5 - how the port-6 result of Q4 changes with 2-bit phase shifters.
%
%   Deliverable A5 ("plot the change in the gain of B at port 6 vs thetaB").
%   All five phase shifters only have the states 0/90/180/270 deg; the VRC
%   ratio stays continuous. phi1..phi3 are the Q1 values rounded to the
%   nearest state. The rounded blue network no longer sends ALL of A to
%   port 5, so some A now reaches the red network, which then has to choose:
%
%   Design 1 - "keep the null" (meets the port-6 requirement):
%       try all 4 x 4 states of phi4/phi5, keep the pairs for which a coupling
%       angle kappa exists that cancels A exactly at port 6, and use the pair
%       with the most B gain for every thetaB (null_keeping_design).
%   Design 2 - "maximise B" (requirement relaxed):
%       the Q3 algorithm with every phase rounded as soon as it is computed
%       (the next stage is designed on the signals that are really there),
%       kappa re-optimised for B; A then leaks into port 6.
%
%   Backup: where the change of design 2 comes from (rounding the A network
%   or the B network), an exhaustive phi4/phi5 search, and a 1...6-bit sweep.
%   Figures: Q5_2bit_gain_port6.png, Q5b_breakdown.png,
%            Q5c_phase_resolution_sweep.png

    fprintf('\n=== Q5  %d-bit phase shifters ===\n', cfg.nBits);
    thB  = cfg.thetaB;  M = numel(thB);
    VB   = incident_wave(thB, cfg.N, cfg.d_lambda);
    VA1  = incident_wave(cfg.thetaA, cfg.N, cfg.d_lambda);
    VA   = repmat(VA1, 1, M);
    far  = abs(thB - cfg.thetaA) >= cfg.excludeAroundA;   % statistics away from thetaA
    nb   = cfg.nBits;
    q    = @(p) quantize_phase(p, nb);
    Q5.nBits  = nb;
    Q5.states = (0:2^nb-1) * 360/2^nb;

    % ---- design 2: Q3 algorithm with rounded phases (maximise B) -------------
    r = quantized_design(cfg, q, VB, VA, VA1);
    Q5.A      = r.A;                         % rounded phi1..phi3 (both designs)
    Q5.B      = r.B;                         % rounded phi4, phi5, re-optimised kappa
    Q5.G_A5   = r.G_A5;
    Q5.G_B6   = r.G_B6;
    Q5.G_A6   = r.G_A6;
    Q5.G_B5   = r.G_B5;
    Q5.dG_B6  = clean_dB(r.G_B6) - clean_dB(Q4.G_B6);   % change w.r.t. Q4
    Q5.SIR6   = r.G_B6 - r.G_A6;             % equal-power satellites

    % ---- design 1: keep the exact null on A ------------------------------------
    kn = null_keeping_design(cfg, r.A.settings, Q5.states, VB, VA1);
    kn.dG_B6 = clean_dB(kn.G_B6) - clean_dB(Q4.G_B6);
    Q5.keepNull = kn;

    % ---- breakdown: only the B-network shifters (phi4, phi5) rounded ----------
    rb = quantized_design(cfg, q, VB, VA, VA1, Q1.A.settings);
    Q5.onlyB.G_B6  = rb.G_B6;
    Q5.onlyB.G_A6  = rb.G_A6;
    Q5.onlyB.dG_B6 = clean_dB(rb.G_B6) - clean_dB(Q4.G_B6);

    % ---- best possible B gain with 2-bit phi4/phi5 (exhaustive, A ignored) ----
    best = -Inf(1, M);
    for p4 = Q5.states
        for p5 = Q5.states
            s = r.A.settings;
            s.phi4 = p4 * ones(1, M);  s.phi5 = p5 * ones(1, M);  s.kappa = 45 * ones(1, M);
            o = bfn_forward(VB, s);
            s.kappa = vrc_kappa(o.VRCin_top, o.VRCin_bot);
            o = bfn_forward(VB, s);
            best = max(best, gain_dB(o.port6));
        end
    end
    Q5.exhaustive.G_B6    = best;
    Q5.exhaustive.maxGain = max(best - r.G_B6);

    % ---- statistics (away from thetaA, where the ideal gain is -Inf) --------
    Q5.stats = q5_stats(thB, far, Q1, Q4, Q5);

    % ---- console ------------------------------------------------------------
    S = Q5.stats;
    fprintf('  states: %s deg (max phase error %g deg); VRC ratio continuous\n', sprintf('%g ', Q5.states), 180/2^nb);
    fprintf('  A network: phi1 = %g, phi2 = %g, phi3 = %g deg   (ideal %.1f, %.1f, %.1f)\n', ...
            r.A.phi1, r.A.phi2, r.A.phi3, Q1.phi);
    fprintf('  A at port 5: %.2f dBi (ideal %.2f, change %+.2f dB) - same for both designs\n', ...
            Q5.G_A5, Q1.G_A5, S.dG_A5);
    fprintf('  DESIGN 1, keep the null on A:\n');
    if isempty(kn.combos)
        fprintf('    no 2-bit phi4/phi5 pair can cancel A exactly for this thetaA\n');
    else
        for c = 1:size(kn.combos, 1)
            fprintf('    null-keeping pair %d: phi4 = %g, phi5 = %g deg, kappa = %.2f deg (C = %.1f %%)\n', ...
                    c, kn.combos(c, 1), kn.combos(c, 2), kn.combos(c, 3), 100*sind(kn.combos(c, 3))^2);
        end
        fprintf('    A at port 6: max %.1f dB (exact null); B change vs Q4: %+.2f ... %+.2f dB, mean %+.2f dB\n', ...
                max(clean_dB(kn.G_A6)), S.kn_dG_min, S.kn_dG_max, S.kn_dG_mean);
        if ~isempty(kn.switchAt)
            fprintf('    the better pair changes at thetaB = %s deg\n', sprintf('%.1f ', kn.switchAt));
        end
    end
    fprintf('  DESIGN 2, maximise B (Q3 algorithm, rounded):\n');
    fprintf('    B change vs Q4 (|thetaB - thetaA| >= %g deg): %+.2f ... %+.2f dB, mean %+.2f dB\n', ...
            cfg.excludeAroundA, S.dG_min, S.dG_max, S.dG_mean);
    fprintf('    A leaks into port 6: %.1f ... %.1f dBi (%.1f dBi max away from thetaA)\n', ...
            S.A6_min, S.A6_max, S.A6_max_far);
    fprintf('    SIR at port 6 (|thetaB - thetaA| >= %g deg): %.1f ... %.1f dB; 0 dB at thetaB = thetaA\n', ...
            cfg.excludeAroundA, S.SIR6_min_far, S.SIR6_max_far);
    fprintf('    only phi4/phi5 rounded: %+.2f ... %+.2f dB, A stays nulled\n', S.onlyB_dG_min, S.onlyB_dG_max);
    fprintf('    exhaustive phi4/phi5 search: at most %+.2f dB more B gain than rounding\n', Q5.exhaustive.maxGain);
    fprintf('  WHERE B IS USABLE (ideal G_B6 >= 0 dBi: thetaB in %s deg):\n', interval_text(S.useIntervals));
    fprintf('    keep null : B change %+.2f ... %+.2f dB (mean %+.2f dB), A -Inf\n', S.use_kn_dG, S.use_kn_mean);
    fprintf('    maximise B: B change %+.2f ... %+.2f dB, A at port 6 %.1f ... %.1f dBi, SIR %.1f ... %.1f dB\n', ...
            S.use_dG, S.use_A6, S.use_SIR6);
    print_rows(cfg, thB, [clean_dB(Q4.G_B6); clean_dB(kn.G_B6); kn.dG_B6; Q5.G_B6; Q5.dG_B6; Q5.G_A6], ...
               {'ideal G_B6', 'keepNull', 'change', 'maxB G_B6', 'change', 'maxB G_A6'});

    write_csv(fullfile(cfg.tabDir, sprintf('Q5_%dbit_results.csv', nb)), ...
              {'thetaB_deg', 'G_B6_ideal_dBi', ...
               'G_B6_keepNull_dBi', 'dG_keepNull_dB', 'G_A6_keepNull_dBi', ...
               'phi4_keepNull_deg', 'phi5_keepNull_deg', 'kappa_keepNull_deg', ...
               'G_B6_maxB_dBi', 'dG_maxB_dB', 'G_A6_maxB_dBi', 'SIR6_maxB_dB', ...
               'phi4_maxB_deg', 'phi5_maxB_deg', 'kappa_maxB_deg', ...
               'G_B6_onlyB_dBi', 'G_B6_exhaustive_dBi'}, ...
              [thB(:), clean_dB(Q4.G_B6(:)), ...
               clean_dB(kn.G_B6(:)), kn.dG_B6(:), clean_dB(kn.G_A6(:)), ...
               kn.phi4(:), kn.phi5(:), kn.kappa(:), ...
               clean_dB(Q5.G_B6(:)), Q5.dG_B6(:), clean_dB(Q5.G_A6(:)), Q5.SIR6(:), ...
               Q5.B.phi4(:), Q5.B.phi5(:), Q5.B.kappa(:), ...
               clean_dB(Q5.onlyB.G_B6(:)), clean_dB(best(:))], '%.6f');
    write_csv(fullfile(cfg.tabDir, sprintf('Q5_%dbit_A_network.csv', nb)), ...
              {'phi1_q_deg', 'phi2_q_deg', 'phi3_q_deg', 'G_A5_q_dBi'}, ...
              [r.A.phi1, r.A.phi2, r.A.phi3, Q5.G_A5], '%.4f');

    % ---- resolution sweep (backup) ------------------------------------------
    %  B metrics where B is usable with ideal shifters (ideal G_B6 >= 0 dBi),
    %  A leakage / SIR away from thetaA (|thetaB - thetaA| >= excludeAroundA).
    use  = Q4.G_B6 >= 0;
    bits = cfg.nBitsSweep;
    sw.bits = bits;
    for k = 1:numel(bits)
        qk = @(p) quantize_phase(p, bits(k));
        rk = quantized_design(cfg, qk, VB, VA, VA1);
        d  = rk.G_B6 - Q4.G_B6;
        sw.lossMax(k) = max([0, -d(use)]);               % worst B-gain loss, design 2 [dB]
        sw.dG_rms(k)  = sqrt(mean(d(use).^2));           % rms change, design 2 [dB]
        sw.A6_max(k)  = max(rk.G_A6(far));               % worst A leakage, design 2 [dBi]
        sw.SIR_min(k) = min(rk.G_B6(far) - rk.G_A6(far));
        sw.G_A5(k)    = rk.G_A5;
        kk = null_keeping_design(cfg, rk.A.settings, (0:2^bits(k)-1) * 360/2^bits(k), VB, VA1);
        sw.knPairs(k) = size(kk.combos, 1);              % pairs that keep the exact null
        dk = kk.G_B6 - Q4.G_B6;
        sw.knLossMax(k) = max([0, -dk(use)]);            % worst B-gain loss, design 1 [dB]
    end
    Q5.sweep = sw;
    fprintf('  resolution sweep (B: where ideal G_B6 >= 0 dBi; A: |thetaB - thetaA| >= %g deg):\n', cfg.excludeAroundA);
    fprintf('    bits | design 2: worst B loss | rms B change | worst A at port 6 | worst SIR6 | design 1: worst B loss (pairs) | G_A5\n');
    for k = 1:numel(bits)
        fprintf('    %4d | %9.2f dB | %9.2f dB | %10.1f dBi | %7.1f dB | %9.2f dB (%d) | %5.2f dBi\n', ...
                bits(k), sw.lossMax(k), sw.dG_rms(k), sw.A6_max(k), sw.SIR_min(k), ...
                sw.knLossMax(k), sw.knPairs(k), sw.G_A5(k));
    end
    write_csv(fullfile(cfg.tabDir, 'Q5_resolution_sweep.csv'), ...
              {'bits', 'maxB_worst_B_loss_dB', 'maxB_rms_B_change_dB', 'maxB_worst_G_A6_dBi', ...
               'maxB_worst_SIR6_dB', 'keepNull_worst_B_loss_dB', 'keepNull_pairs', 'G_A5_dBi'}, ...
              [bits(:), sw.lossMax(:), sw.dG_rms(:), sw.A6_max(:), sw.SIR_min(:), ...
               sw.knLossMax(:), sw.knPairs(:), sw.G_A5(:)], '%.6f');

    plot_q5(cfg, Q4, Q5);
end

% =========================================================================
function kn = null_keeping_design(cfg, sAq, states, VB, VA1)
%NULL_KEEPING_DESIGN  Best phi4/phi5 states (+ continuous kappa) with an exact null on A.
%   For a state pair (phi4, phi5) the A signals at the VRC inputs are a (top,
%   after phi5) and b (bottom). Port 6 = cos(k) P + sin(k) Q with P = -j a,
%   Q = -b, so A cancels for tan(k) = -P/Q: possible only if -P/Q is real and
%   >= 0 (k in 0..90 deg). A pair where A does not reach the VRC at all leaves
%   kappa free (then optimised for B). Per thetaB the null-keeping pair with
%   the largest B gain is used.
    M   = numel(cfg.thetaB);
    tol = 1e-9;
    combos = zeros(0, 3);                                % [phi4 phi5 kappa], NaN = free
    for p4 = states
        for p5 = states
            s = sAq;  s.phi4 = p4;  s.phi5 = p5;  s.kappa = 45;
            o = bfn_forward(VA1, s);
            P = -1j * o.VRCin_top;   Q = -o.VRCin_bot;
            if abs(P) < tol && abs(Q) < tol
                combos(end+1, :) = [p4 p5 NaN];          %#ok<AGROW> A absent: kappa free
            elseif abs(Q) < tol
                combos(end+1, :) = [p4 p5 90];           %#ok<AGROW>
            elseif abs(P) < tol
                combos(end+1, :) = [p4 p5 0];            %#ok<AGROW>
            else
                ratio = -P / Q;
                if abs(imag(ratio)) <= 1e-9 * abs(ratio) && real(ratio) >= 0
                    combos(end+1, :) = [p4 p5 atand(real(ratio))]; %#ok<AGROW>
                end
            end
        end
    end
    kn.combos = combos;
    nC = size(combos, 1);
    if nC == 0
        kn.G_B6 = NaN(1, M); kn.G_A6 = NaN(1, M);
        kn.phi4 = NaN(1, M); kn.phi5 = NaN(1, M); kn.kappa = NaN(1, M);
        kn.choice = zeros(1, M); kn.switchAt = [];
        return
    end
    G = zeros(nC, M);  K = zeros(nC, M);
    for c = 1:nC
        s = sAq;  s.phi4 = combos(c, 1) * ones(1, M);  s.phi5 = combos(c, 2) * ones(1, M);
        if isnan(combos(c, 3))
            s.kappa = 45 * ones(1, M);
            o = bfn_forward(VB, s);
            s.kappa = vrc_kappa(o.VRCin_top, o.VRCin_bot);
        else
            s.kappa = combos(c, 3) * ones(1, M);
        end
        o = bfn_forward(VB, s);
        G(c, :) = gain_dB(o.port6);
        K(c, :) = s.kappa;
    end
    [kn.G_B6, idx] = max(G, [], 1);
    kn.choice = idx;
    kn.phi4   = combos(idx, 1).';
    kn.phi5   = combos(idx, 2).';
    kn.kappa  = K(sub2ind(size(K), idx, 1:M));
    s = sAq;  s.phi4 = kn.phi4;  s.phi5 = kn.phi5;  s.kappa = kn.kappa;
    oA = bfn_forward(repmat(VA1, 1, M), s);
    kn.G_A6 = gain_dB(oA.port6);
    kn.switchAt = cfg.thetaB(find(diff(idx) ~= 0) + 1);
end

% =========================================================================
function S = q5_stats(thB, far, Q1, Q4, Q5)
%   far: |thetaB - thetaA| >= cfg.excludeAroundA (the ideal gain is -Inf at thetaA)
%   use: where B is usable with ideal shifters (ideal G_B6 >= 0 dBi)
    S.dG_A5        = Q5.G_A5 - Q1.G_A5;
    % design 2 (maximise B)
    S.dG_min       = min(Q5.dG_B6(far));
    S.dG_max       = max(Q5.dG_B6(far));
    S.dG_mean      = mean(Q5.dG_B6(far));
    S.A6_max       = max(Q5.G_A6);           % includes thetaB = thetaA
    S.A6_min       = min(Q5.G_A6);
    S.A6_max_far   = max(Q5.G_A6(far));
    S.SIR6_min_far = min(Q5.SIR6(far));
    S.SIR6_max_far = max(Q5.SIR6(far));
    S.onlyB_dG_min = min(Q5.onlyB.dG_B6(far));
    S.onlyB_dG_max = max(Q5.onlyB.dG_B6(far));
    S.gainIntervals = mask_intervals(thB, Q5.dG_B6 > 0);   % thetaB ranges with a higher B gain
    S.lossIntervals = mask_intervals(thB, Q5.dG_B6 < 0);   % thetaB ranges with a lower B gain
    lossy = far & Q5.dG_B6 < 0;
    S.lossRange = range_or_nan(-Q5.dG_B6(lossy));
    % design 1 (keep the null)
    d = Q5.keepNull.dG_B6(far);
    d = d(isfinite(d));
    S.kn_pairs   = size(Q5.keepNull.combos, 1);
    S.kn_dG_min  = min([d, NaN]);
    S.kn_dG_max  = max([d, NaN]);
    S.kn_dG_mean = mean(d);
    % both designs where B is usable (ideal G_B6 >= 0 dBi)
    use = Q4.G_B6 >= 0;
    S.useIntervals = mask_intervals(thB, use);
    S.use_dG       = range_or_nan(Q5.dG_B6(use));
    S.use_A6       = range_or_nan(Q5.G_A6(use));
    S.use_SIR6     = range_or_nan(Q5.SIR6(use));
    S.use_kn_dG    = range_or_nan(Q5.keepNull.dG_B6(use));
    S.use_kn_mean  = mean(Q5.keepNull.dG_B6(use));
end

% =========================================================================
function r = range_or_nan(x)
    x = x(isfinite(x));
    if isempty(x), r = [NaN NaN]; else, r = [min(x), max(x)]; end
end

function t = interval_text(iv)
    if isempty(iv), t = 'none'; return; end
    t = strjoin(arrayfun(@(k) sprintf('%.1f-%.1f', iv(k, 1), iv(k, 2)), 1:size(iv, 1), ...
                'UniformOutput', false), ', ');
end

% =========================================================================
function r = quantized_design(cfg, q, VB, VA, VA1, sAfixed)
%QUANTIZED_DESIGN  Design 2 with quantizer q; optional fixed (ideal) A network.
    if nargin >= 6
        r.A = struct('phi1', sAfixed.phi1, 'phi2', sAfixed.phi2, 'phi3', sAfixed.phi3, ...
                     'settings', sAfixed);
    else
        r.A = design_A_network(cfg, q);
    end
    r.B    = design_B_network(cfg, r.A.settings, q);
    s      = r.B.settings;
    oB     = bfn_forward(VB, s);
    oA     = bfn_forward(VA, s);
    oA1    = bfn_forward(VA1, r.A.settings);
    r.G_A5 = gain_dB(oA1.port5);
    r.G_B6 = gain_dB(oB.port6);
    r.G_B5 = gain_dB(oB.port5);
    r.G_A6 = gain_dB(oA.port6);
end

% =========================================================================
function plot_q5(cfg, Q4, Q5)
    st  = cfg.style;
    thB = cfg.thetaB;
    tag = sprintf('%d-bit', Q5.nBits);
    kn  = Q5.keepNull;
    busy = [cfg.thetaA - 1, cfg.thetaA + 14];           % the thetaA label at the bottom
    corners = {'southeast', [55 90]; 'southwest', [0 35]};

    % ---- main figure: gains at port 6 (left) + change versus ideal (right) ---
    fig = new_figure(cfg, 'Q5 - 2-bit phase shifters', 1129, 374);
    mg  = [0.95 0.2 0.75 0.45 1.0 0];                   % margins [inch], see sub_axes
    ax  = sub_axes(fig, 1, 2, 1, mg); hold(ax, 'on');
    yl  = [-40 10];  lo = yl(1) - 10;  hi = yl(2) + 10;
    set(ax, 'XLim', [0 90], 'YLim', yl, 'XTick', 0:10:90, 'YTick', -40:10:10);
    h1 = plot(ax, thB, clip_for_plot(Q4.G_B6, lo, hi), 'Color', st.ref, 'LineWidth', st.lwRef);
    h3 = plot(ax, thB, clip_for_plot(Q5.G_B6, lo, hi), '--', 'Color', st.B, 'LineWidth', st.lwRef + 0.4);
    h4 = plot(ax, thB, clip_for_plot(Q5.G_A6, lo, hi), 'Color', st.A, 'LineWidth', st.lw);
    h2 = plot(ax, thB, clip_for_plot(kn.G_B6, lo, hi), 'Color', st.B, 'LineWidth', st.lw);
    vguide(ax, cfg.thetaA, '\theta_B = \theta_A', cfg, 'bottom');
    style_axes(ax, cfg, '\theta_B (deg)', 'Gain at port 6 (dBi)', ...
               [tag ' shifters (0/90/180/270^{\circ}), ' thetaA_tag(cfg)]);
    legend(ax, [h2 h3 h4 h1], {'B, null kept (A: -\infty)', 'B, maximise B', ...
           'A, maximise B (leak)', 'B, ideal (Q4)'}, ...
           'Location', free_corner(busy, corners, 'eastoutside'), 'Box', 'off');

    ax  = sub_axes(fig, 1, 2, 2, mg); hold(ax, 'on');
    yl  = [-6 8];  lo = yl(1) - 5;  hi = yl(2) + 5;
    set(ax, 'XLim', [0 90], 'YLim', yl, 'XTick', 0:10:90, 'YTick', -6:2:8);
    plot(ax, [0 90], [0 0], '-', 'Color', st.ink2, 'LineWidth', 0.8);
    g3 = plot(ax, thB, clip_for_plot(Q5.dG_B6, lo, hi), '--', 'Color', st.B, 'LineWidth', st.lwRef + 0.4);
    g2 = plot(ax, thB, clip_for_plot(kn.dG_B6, lo, hi), 'Color', st.B, 'LineWidth', st.lw);
    vguide(ax, cfg.thetaA, '', cfg);
    if cfg.thetaA <= 60                      % label the +inf spike on the side with more room
        xl = cfg.thetaA + 5;  ha = 'left';   txt = [cfg.thetaA - 6, cfg.thetaA + 30];
    else
        xl = cfg.thetaA - 5;  ha = 'right';  txt = [cfg.thetaA - 30, cfg.thetaA + 6];
    end
    text(ax, xl, yl(2) - 0.5, 'maximise B: +\infty at \theta_B = \theta_A', ...
         'HorizontalAlignment', ha, 'VerticalAlignment', 'top', 'Color', st.ink2, 'FontSize', st.fs - 1);
    style_axes(ax, cfg, '\theta_B (deg)', '\DeltaG_{B,6} (dB)', ...
               ['Change of B at port 6: ' tag ' minus ideal']);
    % top corners: both changes stay well below +4 dB away from thetaA
    legend(ax, [g2 g3], {'null on A kept', 'maximise B'}, ...
           'Location', free_corner(txt, {'northeast', [65 90]; 'northwest', [0 25]}, 'eastoutside'), ...
           'Box', 'off');
    save_figure(cfg, fig, sprintf('Q5_%dbit_gain_port6', Q5.nBits));

    % ---- backup: breakdown of design 2 ---------------------------------------
    fig = new_figure(cfg, 'Q5b - breakdown', 787, 442);
    ax  = sub_axes(fig, 1, 1, 1, [0.95 0.3 0.75 0.5 0 0]); hold(ax, 'on');   % fixed margins [inch]
    yl  = [-4 8];  lo = yl(1) - 5;  hi = yl(2) + 5;
    set(ax, 'XLim', [0 90], 'YLim', yl, 'XTick', 0:10:90, 'YTick', -4:2:8);
    plot(ax, [0 90], [0 0], '-', 'Color', st.ink2, 'LineWidth', 0.8);
    hb = plot(ax, thB, clip_for_plot(Q5.onlyB.dG_B6, lo, hi), 'Color', st.ref, 'LineWidth', st.lw);
    ha = plot(ax, thB, clip_for_plot(Q5.dG_B6, lo, hi), 'Color', st.B, 'LineWidth', st.lw);
    he = plot(ax, thB, clip_for_plot(Q5.exhaustive.G_B6 - Q4.G_B6, lo, hi), ':', ...
              'Color', st.B, 'LineWidth', st.lwRef);
    vguide(ax, cfg.thetaA, '\theta_B = \theta_A', cfg, 'bottom');
    style_axes(ax, cfg, '\theta_B (deg)', '\DeltaG_{B,6} (dB)', ...
               ['Maximise-B design: where the change comes from, ' thetaA_tag(cfg)]);
    near = [cfg.thetaA - 8, cfg.thetaA + 8];             % the +inf spike around thetaA
    legend(ax, [ha hb he], {['all 5 shifters ' tag], ['only \phi_4, \phi_5 ' tag ' (A network ideal)'], ...
           ['best ' tag ' \phi_4/\phi_5 (exhaustive search)']}, ...
           'Location', free_corner(near, {'northeast', [45 90]; 'northwest', [0 45]}, 'eastoutside'), 'Box', 'off');
    save_figure(cfg, fig, 'Q5b_breakdown');

    % ---- backup: resolution sweep, both designs ------------------------------
    sw  = Q5.sweep;
    xlb = [sw.bits(1) - 0.3, sw.bits(end) + 0.3];
    fig = new_figure(cfg, 'Q5c - resolution sweep', 1129, 374);
    ax  = sub_axes(fig, 1, 2, 1, mg); hold(ax, 'on');
    hk = plot(ax, sw.bits, sw.knLossMax, '-o', 'Color', st.B, 'LineWidth', st.lw, ...
              'MarkerFaceColor', st.B, 'MarkerEdgeColor', 'w', 'MarkerSize', 10);
    hm = plot(ax, sw.bits, sw.lossMax, '--o', 'Color', st.B, 'LineWidth', st.lwRef + 0.4, ...
              'MarkerFaceColor', 'w', 'MarkerEdgeColor', st.B, 'MarkerSize', 9);
    ytop = max(2, 2*ceil(max([sw.lossMax, sw.knLossMax]) / 2) + 2);
    set(ax, 'XLim', xlb, 'XTick', sw.bits, 'YLim', [0 ytop]);
    style_axes(ax, cfg, 'phase-shifter bits', 'worst B loss (dB)', 'B at port 6 (where ideal \geq 0 dBi)');
    nb = numel(sw.bits);  k2 = min(2, nb);                % legend in the emptier top corner
    left  = max([sw.lossMax(1:k2), sw.knLossMax(1:k2)]);
    right = max([sw.lossMax(nb-k2+1:nb), sw.knLossMax(nb-k2+1:nb)]);
    loc = 'northwest';  if right < left, loc = 'northeast'; end
    legend(ax, [hk hm], {'null on A kept', 'maximise B'}, 'Location', loc, 'Box', 'off');

    ax  = sub_axes(fig, 1, 2, 2, mg); hold(ax, 'on');
    plot(ax, sw.bits, sw.A6_max, '--o', 'Color', st.A, 'LineWidth', st.lwRef + 0.4, ...
         'MarkerFaceColor', 'w', 'MarkerEdgeColor', st.A, 'MarkerSize', 9);
    yl = [10*floor(min(sw.A6_max)/10) - 5, max(5, 5*ceil(max(sw.A6_max)/5) + 5)];
    set(ax, 'XLim', xlb, 'XTick', sw.bits, 'YLim', yl);
    text(ax, sw.bits(1) + 0.2, sw.A6_max(1), 'maximise B', 'HorizontalAlignment', 'left', ...
         'VerticalAlignment', 'bottom', 'Color', st.ink2, 'FontSize', st.fs - 1);
    text(ax, xlb(2) - 0.1, yl(2) - 0.04*diff(yl), {'null on A kept:', '-\infty at every resolution'}, ...
         'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'Color', st.ink2, 'FontSize', st.fs - 1);
    style_axes(ax, cfg, 'phase-shifter bits', 'worst G_{A,6} (dBi)', ...
               sprintf('A leaking into port 6 (|\\theta_B-\\theta_A| \\geq %g^{\\circ})', cfg.excludeAroundA));
    save_figure(cfg, fig, 'Q5c_phase_resolution_sweep');
end
