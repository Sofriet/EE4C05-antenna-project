function Q1 = q1_A_network(cfg)
%Q1_A_NETWORK  Q1 - phase shifters phi1, phi2, phi3 for the given thetaA.
%
%   Deliverable A1: "write down the phase values".
%   Also returns the port-5 element weights and the A-beam pattern, and
%   draws results/figures/Q1_port5_beam_pattern.png.

    fprintf('\n=== Q1  A network (blue): phi1, phi2, phi3 ===\n');
    A = design_A_network(cfg);

    % ---- cross-check with the closed form ---------------------------------
    num = [A.phi1, A.phi2, A.phi3];
    ana = [A.closedForm.phi1, A.closedForm.phi2, A.closedForm.phi3];
    err = max(abs(wrap180(num - ana)));
    if err > 1e-9
        warning('q1:closedForm', 'Algorithm and closed form differ by %.3g deg.', err);
    end

    % ---- performance for source A -----------------------------------------
    VA = incident_wave(cfg.thetaA, cfg.N, cfg.d_lambda);
    oA = bfn_forward(VA, A.settings);
    W  = port_weights(A.settings, 1);
    Vp = incident_wave(cfg.thetaPattern, cfg.N, cfg.d_lambda);
    op = bfn_forward(Vp, A.settings);

    Q1.A          = A;
    Q1.thetaA     = cfg.thetaA;
    Q1.psiA       = A.psiA;
    Q1.phi        = num;                         % [phi1 phi2 phi3], 0..360 deg
    Q1.G_A5       = gain_dB(oA.port5);           % dBi
    Q1.leakA      = [oA.H1top, oA.H2top, oA.H3top];   % A at the B-network inputs (should be 0)
    Q1.w5         = W.port5;                     % 4x1 element weights of port 5
    Q1.pattern5   = gain_dB(op.port5);           % A-beam pattern on cfg.thetaPattern
    Q1.closedFormError = err;

    % ---- console ------------------------------------------------------------
    fprintf('  thetaA = %g deg,  psiA = k d sin(thetaA) = %.2f deg\n', cfg.thetaA, A.psiA);
    fprintf('  phi1 = %7.2f deg  (= %7.2f deg)   [closed form 90 - psiA]\n',   A.phi1, wrap180(A.phi1));
    fprintf('  phi2 = %7.2f deg  (= %7.2f deg)   [closed form 90 - psiA]\n',   A.phi2, wrap180(A.phi2));
    fprintf('  phi3 = %7.2f deg  (= %7.2f deg)   [closed form 90 - 2 psiA]\n', A.phi3, wrap180(A.phi3));
    fprintf('  algorithm vs closed form: max difference %.1e deg\n', err);
    fprintf('  gain of A at port 5: %.2f dBi (10log10 N = %.2f dBi)\n', Q1.G_A5, 10*log10(cfg.N));
    fprintf('  A left at H1.top / H2.top / H3.top: %.1e / %.1e / %.1e (A-free B-network inputs)\n', abs(Q1.leakA));
    fprintf('  port-5 element weights: |w| = [%s],  angle = [%s] deg\n', ...
            sprintf('%.3f ', abs(Q1.w5)), sprintf('%.1f ', wrap180(angle(Q1.w5)*180/pi)));

    % ---- tables -------------------------------------------------------------
    write_csv(fullfile(cfg.tabDir, 'Q1_A_network_phases.csv'), ...
              {'thetaA_deg', 'psiA_deg', 'phi1_deg', 'phi2_deg', 'phi3_deg', 'G_A5_dBi'}, ...
              [cfg.thetaA, A.psiA, num, Q1.G_A5], '%.4f');
    write_csv(fullfile(cfg.tabDir, 'Q1_port5_element_weights.csv'), ...
              {'element', 'amplitude', 'phase_deg', 'phase_rel_el1_deg'}, ...
              [(1:4).', abs(Q1.w5), wrap180(angle(Q1.w5)*180/pi), ...
               wrap180((angle(Q1.w5) - angle(Q1.w5(1)))*180/pi)], '%.6f');

    % ---- figure: A-beam (port 5) pattern ---------------------------------
    st  = cfg.style;
    fig = new_figure(cfg, 'Q1 - port 5 beam pattern', 900, 420);
    ax  = axes('Parent', fig); hold(ax, 'on');
    yl  = [-30 10];
    e = 0.004 * [180 diff(yl)];            % keep the box lines visible around the band
    patch(ax, [0 90-e(1) 90-e(1) 0], [yl(1)+e(2) yl(1)+e(2) yl(2)-e(2) yl(2)-e(2)], st.shade, ...
          'EdgeColor', 'none');
    for x = 30:30:60                       % the band hides the axes grid: redraw it inside the band
        plot(ax, [x x], yl, '-', 'Color', st.grid, 'LineWidth', 0.8);
    end
    for y = yl(1)+10:10:yl(2)-10
        plot(ax, [0 90], [y y], '-', 'Color', st.grid, 'LineWidth', 0.8);
    end
    if cfg.thetaA <= 45                    % label in the half of the band away from the main lobe
        text(ax, 88, yl(2) - 1.5, 'range of \theta_B', 'HorizontalAlignment', 'right', ...
             'Color', st.ink2, 'FontSize', st.fs - 1);
    else
        text(ax, 2, yl(2) - 1.5, 'range of \theta_B', 'HorizontalAlignment', 'left', ...
             'Color', st.ink2, 'FontSize', st.fs - 1);
    end
    plot(ax, cfg.thetaPattern, max(Q1.pattern5, yl(1) - 10), 'Color', st.A, 'LineWidth', st.lw);
    plot(ax, cfg.thetaA, Q1.G_A5, 'o', 'MarkerSize', 8, ...
         'MarkerFaceColor', st.A, 'MarkerEdgeColor', 'w', 'LineWidth', 1.5);
    text(ax, cfg.thetaA, Q1.G_A5 + 1.2, sprintf('%.2f dBi at \\theta_A', Q1.G_A5), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
         'Color', st.ink, 'FontSize', st.fs - 1);
    set(ax, 'XLim', [-90 90], 'YLim', yl, 'XTick', -90:30:90, 'YTick', -30:10:10);
    style_axes(ax, cfg, '\theta (deg)', 'Gain at port 5 (dBi)', ...
               ['A beam at port 5 (\phi_1 = \phi_2 = ' sprintf('%.1f', A.phi1) ...
                '^{\circ}, \phi_3 = ' sprintf('%.1f', A.phi3) '^{\circ}), ' thetaA_tag(cfg)]);
    % one series: the title names it and the marker carries a direct label, no legend box
    save_figure(cfg, fig, 'Q1_port5_beam_pattern');
end
