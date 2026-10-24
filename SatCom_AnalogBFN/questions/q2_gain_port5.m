function Q2 = q2_gain_port5(cfg, Q1)
%Q2_GAIN_PORT5  Q2 - gain of source A and source B at port 5 versus thetaB.
%
%   Deliverable A2. Port 5 is fixed by phi1..phi3 (Q1), so
%     - A always sees the full array gain 10log10(N) = 6.02 dBi;
%     - B sees the A-beam pattern evaluated at thetaB (interference).
%   Draws results/figures/Q2_gain_port5_vs_thetaB.png.

    fprintf('\n=== Q2  gain at port 5 for A and B versus thetaB ===\n');
    thB = cfg.thetaB;
    VB  = incident_wave(thB, cfg.N, cfg.d_lambda);
    oB  = bfn_forward(VB, Q1.A.settings);

    Q2.thetaB = thB;
    Q2.G_A5   = Q1.G_A5 * ones(size(thB));       % independent of thetaB
    Q2.G_B5   = gain_dB(oB.port5);
    Q2.SIR5   = Q2.G_A5 - Q2.G_B5;               % equal-power satellites

    % nulls of the A beam inside the thetaB range: sin(th) = sin(thA) + m/(N d)
    m  = -cfg.N:cfg.N;  m(m == 0) = [];
    u  = sind(cfg.thetaA) + m / (cfg.N * cfg.d_lambda);
    u  = u(u >= sind(thB(1)) - 1e-12 & u <= sind(thB(end)) + 1e-12);
    Q2.nulls = sort(asind(min(max(u, -1), 1)));

    % strongest interference outside the main lobe (|sin th - sin thA| > 1/(N d))
    side = abs(sind(thB) - sind(cfg.thetaA)) > 1/(cfg.N*cfg.d_lambda);
    if any(side)
        [Q2.sidelobe, i] = max(Q2.G_B5(side));
        ts = thB(side);  Q2.sidelobeAt = ts(i);
    else
        Q2.sidelobe = NaN;  Q2.sidelobeAt = NaN;
    end
    [~, i0] = min(abs(thB - 0));   [~, i90] = min(abs(thB - 90));

    % ---- console ------------------------------------------------------------
    fprintf('  A at port 5 : %.2f dBi for every thetaB (network fixed to thetaA)\n', Q1.G_A5);
    fprintf('  B at port 5 : max %.2f dBi at thetaB = thetaA = %g deg (SIR = 0 dB)\n', max(Q2.G_B5), cfg.thetaA);
    fprintf('                %.2f dBi at thetaB = 0 deg, %.2f dBi at 90 deg\n', Q2.G_B5(i0), Q2.G_B5(i90));
    if ~isempty(Q2.nulls)
        fprintf('                nulls (B rejected) at thetaB = %s deg\n', sprintf('%.2f ', Q2.nulls));
    end
    if ~isnan(Q2.sidelobe)
        fprintf('                strongest sidelobe %.2f dBi at %.1f deg (SIR = %.1f dB)\n', ...
                Q2.sidelobe, Q2.sidelobeAt, Q1.G_A5 - Q2.sidelobe);
    end
    print_rows(cfg, thB, [Q2.G_A5; Q2.G_B5; Q2.SIR5], {'G_A5 [dBi]', 'G_B5 [dBi]', 'SIR5 [dB]'});

    write_csv(fullfile(cfg.tabDir, 'Q2_gain_port5.csv'), ...
              {'thetaB_deg', 'G_A5_dBi', 'G_B5_dBi', 'SIR5_dB'}, ...
              [thB(:), Q2.G_A5(:), Q2.G_B5(:), Q2.SIR5(:)], '%.6f');

    % ---- figure ---------------------------------------------------------------
    st  = cfg.style;
    fig = new_figure(cfg, 'Q2 - gain at port 5');
    ax  = axes('Parent', fig); hold(ax, 'on');
    yl  = [-40 10];
    set(ax, 'XLim', [0 90], 'YLim', yl, 'XTick', 0:10:90, 'YTick', -40:10:10);
    hA = plot(ax, thB, Q2.G_A5, 'Color', st.A, 'LineWidth', st.lw);
    hB = plot(ax, thB, max(Q2.G_B5, yl(1) - 10), 'Color', st.B, 'LineWidth', st.lw);
    vguide(ax, cfg.thetaA, '\theta_B = \theta_A', cfg, 'bottom');
    for k = 1:numel(Q2.nulls)
        text(ax, Q2.nulls(k), yl(1) + 4, sprintf('null %.1f^{\\circ}  ', Q2.nulls(k)), ...
             'HorizontalAlignment', 'right', 'Color', st.ink2, 'FontSize', st.fs - 1);
    end
    style_axes(ax, cfg, '\theta_B (deg)', 'Gain at port 5 (dBi)', ...
               ['Port 5: wanted A vs. interfering B, ' thetaA_tag(cfg)]);
    % legend in a bottom corner that is free of the thetaA / null labels
    busy = [cfg.thetaA, cfg.thetaA + 12; Q2.nulls(:) - 15, Q2.nulls(:)];
    cand = {'southeast', [60 90]; 'southwest', [0 30]; 'south', [30 60]};
    legend(ax, [hA hB], {sprintf('A at port 5 (%.2f dBi)', Q1.G_A5), 'B at port 5 (interference)'}, ...
           'Location', free_corner(busy, cand, 'eastoutside'), 'Box', 'off');
    save_figure(cfg, fig, 'Q2_gain_port5_vs_thetaB');
end
