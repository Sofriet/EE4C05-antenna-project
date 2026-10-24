function Q4 = q4_gain_port6(cfg, Q1, Q3)
%Q4_GAIN_PORT6  Q4 - gain of source B at port 6 versus thetaB.
%
%   Deliverable A4. For every thetaB the red network is set as in Q3.
%   Also verifies that source A gives exactly zero at port 6 and that no B
%   power is lost in the two loads. Draws
%     results/figures/Q4_gain_port6_vs_thetaB.png
%     results/figures/Q4b_port6_beam_patterns.png   (backup)

    fprintf('\n=== Q4  gain at port 6 for B versus thetaB ===\n');
    thB = cfg.thetaB;  M = numel(thB);
    s   = Q3.B.settings;
    VB  = incident_wave(thB, cfg.N, cfg.d_lambda);
    VA  = repmat(incident_wave(cfg.thetaA, cfg.N, cfg.d_lambda), 1, M);
    oB  = bfn_forward(VB, s);
    oA  = bfn_forward(VA, s);

    Q4.thetaB  = thB;
    Q4.G_B6    = clean_dB(gain_dB(oB.port6));             % -Inf at thetaB = thetaA
    Q4.G_B5    = clean_dB(gain_dB(oB.port5));
    Q4.G_A6    = clean_dB(gain_dB(oA.port6));             % -Inf (exact null)
    Q4.maxA6   = max(abs(oA.port6));                      % numerical zero
    Q4.lossB   = abs(oB.load_H4).^2 + abs(oB.load_VRC).^2;  % B power in the loads
    Q4.powerErr = max(abs(abs(oB.port5).^2 + abs(oB.port6).^2 - cfg.N));
    Q4.bound   = 10*log10(cfg.N);                          % all received power

    % reference: best possible B gain with an exact null on A (projection bound)
    sA = incident_wave(cfg.thetaA, cfg.N, cfg.d_lambda);
    proj = sum(abs(VB).^2, 1) - abs(sA' * VB).^2 / real(sA' * sA);
    Q4.boundErr = max(abs(abs(oB.port6).^2 - proj));

    [~, i0] = min(abs(thB - 0));  [~, i90] = min(abs(thB - 90));
    Q4.fullGainAt = closest_peaks(thB, Q4.G_B6, Q4.bound);   % where G_B6 reaches 10log10(N)

    % ---- console ------------------------------------------------------------
    fprintf('  max |A at port 6| = %.1e  ->  A rejected completely (gain -Inf dB) for all thetaB\n', Q4.maxA6);
    fprintf('  max B power lost in the loads = %.1e,  max | |p5|^2 + |p6|^2 - N | = %.1e\n', max(Q4.lossB), Q4.powerErr);
    fprintf('  |port 6|^2 equals the projection bound N - |a_A^H a_B|^2/N (max diff %.1e)\n', Q4.boundErr);
    fprintf('  B at port 6: %.2f dBi at 0 deg, %.2f dBi at 90 deg, -> -Inf at thetaB = thetaA\n', ...
            Q4.G_B6(i0), Q4.G_B6(i90));
    if ~isempty(Q4.fullGainAt)
        fprintf('  full %.2f dBi exactly where the A beam has a null (thetaB = %s deg)\n', Q4.bound, ...
                sprintf('%.1f ', Q4.fullGainAt));
    end
    print_rows(cfg, thB, [Q4.G_B6; Q4.G_B5], {'G_B6 [dBi]', 'G_B5 [dBi]'});

    write_csv(fullfile(cfg.tabDir, 'Q4_gain_port6.csv'), ...
              {'thetaB_deg', 'G_B6_dBi', 'G_B5_dBi', 'G_A6_dBi', 'B_power_in_loads'}, ...
              [thB(:), Q4.G_B6(:), Q4.G_B5(:), Q4.G_A6(:), Q4.lossB(:)], '%.6g');   % -Inf = exact null

    % port-6 element weights (= Tx excitations) for every thetaB - kept for Q6/Q7
    W = port_weights(s, M);
    Q4.w6 = W.port6;
    write_csv(fullfile(cfg.tabDir, 'Q4_port6_element_weights_vs_thetaB.csv'), ...
              {'thetaB_deg', 'amp1', 'amp2', 'amp3', 'amp4', ...
               'phase1_deg', 'phase2_deg', 'phase3_deg', 'phase4_deg'}, ...
              [thB(:), abs(W.port6.'), wrap180(angle(W.port6.')*180/pi)], '%.6f');

    % ---- main figure -----------------------------------------------------------
    st  = cfg.style;
    fig = new_figure(cfg, 'Q4 - gain at port 6');
    ax  = axes('Parent', fig); hold(ax, 'on');
    yl  = [-40 10];
    set(ax, 'XLim', [0 90], 'YLim', yl, 'XTick', 0:10:90, 'YTick', -40:10:10);
    hN = plot(ax, [0 90], Q4.bound*[1 1], '--', 'Color', st.ref, 'LineWidth', st.lwRef);
    h5 = plot(ax, thB, max(Q4.G_B5, yl(1) - 10), 'Color', st.ref, 'LineWidth', st.lwRef);
    h6 = plot(ax, thB, max(Q4.G_B6, yl(1) - 10), 'Color', st.B, 'LineWidth', st.lw);
    vguide(ax, cfg.thetaA, '\theta_B = \theta_A', cfg, 'bottom');
    text(ax, 45, 8.4, 'A at port 6: exact null (-\infty dB) for every \theta_B', ...
         'HorizontalAlignment', 'center', 'Color', st.ink2, 'FontSize', st.fs - 1);
    style_axes(ax, cfg, '\theta_B (deg)', 'Gain (dBi)', ['Port 6: wanted B with A nulled, ' thetaA_tag(cfg)]);
    % legend in a bottom corner away from the thetaB = thetaA label
    busy = [cfg.thetaA - 1, cfg.thetaA + 14];
    cand = {'southeast', [55 90]; 'southwest', [0 35]};
    legend(ax, [h6 h5 hN], {'B at port 6', 'B at port 5 (Q2)', ...
           sprintf('10log_{10}N = %.2f dBi', Q4.bound)}, ...
           'Location', free_corner(busy, cand, 'eastoutside'), 'Box', 'off');
    save_figure(cfg, fig, 'Q4_gain_port6_vs_thetaB');

    % ---- backup figure: port-6 beam patterns for a few B designs -------------
    Vp  = incident_wave(cfg.thetaPattern, cfg.N, cfg.d_lambda);
    op5 = bfn_forward(Vp, Q1.A.settings);
    fig = new_figure(cfg, 'Q4b - port 6 beam patterns', 1150, 500);
    ax  = axes('Parent', fig); hold(ax, 'on');
    yl  = [-30 10];
    set(ax, 'XLim', [-90 90], 'YLim', yl, 'XTick', -90:30:90, 'YTick', -30:10:10);
    h   = plot(ax, cfg.thetaPattern, max(gain_dB(op5.port5), yl(1) - 10), 'Color', st.A, 'LineWidth', st.lwRef);
    lab = {'Port 5 (A beam)'};
    for k = 1:numel(cfg.thetaB_patterns)
        tb = cfg.thetaB_patterns(k);
        [~, j] = min(abs(thB - tb));
        sj = column_settings(s, j);
        op = bfn_forward(Vp, sj);
        col = st.Bramp(min(k, size(st.Bramp, 1)), :);
        h(end+1) = plot(ax, cfg.thetaPattern, max(gain_dB(op.port6), yl(1) - 10), ...
                        'Color', col, 'LineWidth', st.lw); %#ok<AGROW>
        plot(ax, thB(j), Q4.G_B6(j), 'o', 'MarkerSize', 8, 'MarkerFaceColor', col, ...
             'MarkerEdgeColor', 'w', 'LineWidth', 1.5);
        lab{end+1} = sprintf('Port 6, designed for \\theta_B = %g^{\\circ}', thB(j)); %#ok<AGROW>
    end
    vguide(ax, cfg.thetaA, '\theta_A: null of every port-6 beam', cfg, 'top');
    style_axes(ax, cfg, '\theta (deg)', 'Gain (dBi)', ['Beam patterns (dots: gain towards B), ' thetaA_tag(cfg)]);
    legend(ax, h, lab, 'Location', 'eastoutside', 'Box', 'off');
    save_figure(cfg, fig, 'Q4b_port6_beam_patterns');
end

function t = closest_peaks(thB, G, level)
%CLOSEST_PEAKS  Local maxima of G that reach 'level' within 0.01 dB.
    t = [];
    for i = 2:numel(G) - 1
        if G(i) >= G(i-1) && G(i) >= G(i+1) && G(i) > level - 0.01
            t(end+1) = thB(i); %#ok<AGROW>
        end
    end
    if G(end) > level - 0.01 && G(end) >= G(end-1), t(end+1) = thB(end); end
    if G(1)   > level - 0.01 && G(1)   >= G(2),     t = [thB(1), t];     end
end

function sj = column_settings(s, j)
%COLUMN_SETTINGS  Settings of design number j (scalar fields).
    f = fieldnames(s);
    sj = s;
    for k = 1:numel(f)
        v = s.(f{k});
        if numel(v) > 1, sj.(f{k}) = v(j); end
    end
end
