function results_overview(cfg, Q2, Q4, Q5)
%RESULTS_OVERVIEW  Q2, Q4 and Q5 merged into one figure (results slide).
%
%   Left : ideal phase shifters - A and B at port 5 (Q2) and B at port 6 (Q4).
%          Port 6 gets exactly the B power that port 5 misses.
%   Right: 2-bit phase shifters - change of the B gain at port 6 (Q5) for
%          both 2-bit designs.
%   Draws results/figures/Q2_Q4_Q5_overview.png. The separate figures of
%   each question stay in q2_..., q4_... and q5_....

    st  = cfg.style;
    thB = cfg.thetaB;
    kn  = Q5.keepNull;
    fig = new_figure(cfg, 'Q2, Q4, Q5 - overview', 1129, 374);
    mg  = [0.95 0.2 0.75 0.45 1.0 0];                   % margins [inch], see sub_axes

    % ---- left: ideal network, both ports ---------------------------------------
    ax  = sub_axes(fig, 1, 2, 1, mg); hold(ax, 'on');
    yl  = [-40 10];  lo = yl(1) - 10;  hi = yl(2) + 10;
    set(ax, 'XLim', [0 90], 'YLim', yl, 'XTick', 0:10:90, 'YTick', -40:10:10);
    hB5 = plot(ax, thB, clip_for_plot(Q2.G_B5, lo, hi), 'Color', st.Bramp(1, :), 'LineWidth', st.lwRef);
    hA5 = plot(ax, thB, Q2.G_A5, 'Color', st.A, 'LineWidth', st.lw);
    hB6 = plot(ax, thB, clip_for_plot(Q4.G_B6, lo, hi), 'Color', st.B, 'LineWidth', st.lw);
    vguide(ax, cfg.thetaA, '\theta_B = \theta_A', cfg, 'bottom');
    text(ax, 89, -18, 'A at port 6: -\infty', 'HorizontalAlignment', 'right', ...
         'Color', st.ink2, 'FontSize', st.fs - 1);
    style_axes(ax, cfg, '\theta_B (deg)', 'Gain (dBi)', ['Ideal phase shifters, ' thetaA_tag(cfg)]);
    legend(ax, [hA5 hB5 hB6], {'A at port 5', 'B at port 5', 'B at port 6'}, ...
           'Location', 'southeast', 'Box', 'off');

    % ---- right: change of B at port 6 with 2-bit shifters ----------------------
    ax  = sub_axes(fig, 1, 2, 2, mg); hold(ax, 'on');
    yl  = [-8 6];  lo = yl(1) - 5;  hi = yl(2) + 5;
    set(ax, 'XLim', [0 90], 'YLim', yl, 'XTick', 0:10:90, 'YTick', -8:2:6);
    plot(ax, [0 90], [0 0], '-', 'Color', st.ink2, 'LineWidth', 0.8);
    g3 = plot(ax, thB, clip_for_plot(Q5.dG_B6, lo, hi), '--', 'Color', st.B, 'LineWidth', st.lwRef + 0.4);
    g2 = plot(ax, thB, clip_for_plot(kn.dG_B6, lo, hi), 'Color', st.B, 'LineWidth', st.lw);
    vguide(ax, cfg.thetaA, '', cfg);
    text(ax, cfg.thetaA + 5, yl(2) - 0.4, '+\infty at \theta_A', 'HorizontalAlignment', 'left', ...
         'VerticalAlignment', 'top', 'Color', st.ink2, 'FontSize', st.fs - 1);
    style_axes(ax, cfg, '\theta_B (deg)', '\DeltaG_{B,6} (dB)', ...
               sprintf('%d-bit shifters: change of B at port 6', Q5.nBits));
    legend(ax, [g2 g3], {'keep null (A: -\infty)', 'maximise B (A leaks)'}, ...
           'Location', 'southeast', 'Box', 'off');
    save_figure(cfg, fig, 'Q2_Q4_Q5_overview');
end
