function Q3 = q3_B_network(cfg, Q1)
%Q3_B_NETWORK  Q3 - phi4, phi5 and the variable coupling ratio versus thetaB.
%
%   Deliverable A3 ("determine and plot the unknowns vs thetaB").
%   Algorithm: design_B_network.m (stage-wise co-phasing + maximal-ratio
%   combining on the A-free outputs). Cross-checked with closed_form_design.m.
%   Draws results/figures/Q3_B_network_unknowns_vs_thetaB.png (one panel per unknown).

    fprintf('\n=== Q3  B network (red): phi4, phi5 and VRC ratio versus thetaB ===\n');
    B  = design_B_network(cfg, Q1.A.settings);
    cf = closed_form_design(cfg, cfg.thetaB);
    ok = B.defined;

    Q3.B         = B;
    Q3.thetaB    = B.thetaB;
    Q3.phi4      = B.phi4;
    Q3.phi5      = B.phi5;
    Q3.kappa     = B.kappa;
    Q3.C         = B.C;                                  % power coupling ratio sin^2(kappa)
    Q3.undefined = B.thetaB(~ok);
    Q3.err.phi4  = max(abs(wrap180(B.phi4(B.def4) - cf.phi4(B.def4))));
    Q3.err.phi5  = max(abs(wrap180(B.phi5(B.def5) - cf.phi5(B.def5))));
    Q3.err.kappa = max(abs(B.kappa(B.defK) - cf.kappa(B.defK)));
    Q3.closedForm = cf;
    Q3.C_limitAtA = 0.8;                                 % tan(kappa) -> 2 for thetaB -> thetaA

    % ---- console ------------------------------------------------------------
    fprintf('  closed forms: phi4 = 90 + 2 psiB,  phi5 = -90 - psiA - psiB,  tan(kappa) = 1 + cos(psiB - psiA)\n');
    fprintf('  algorithm vs closed form (max diff): phi4 %.1e deg, phi5 %.1e deg, kappa %.1e deg\n', ...
            Q3.err.phi4, Q3.err.phi5, Q3.err.kappa);
    if ~isempty(Q3.undefined)
        fprintf('  undefined at thetaB = %s deg (B identical to A: no B power reaches the red network)\n', ...
                sprintf('%.1f ', Q3.undefined));
    end
    fprintf('  VRC power coupling C = sin^2(kappa): %.1f %% ... %.1f %% (limit %.0f %% at thetaB -> thetaA)\n', ...
            100*min(B.C), 100*max(B.C), 100*Q3.C_limitAtA);
    print_rows(cfg, B.thetaB, [B.phi4; B.phi5; B.kappa; 100*B.C], ...
               {'phi4 [deg]', 'phi5 [deg]', 'kappa[deg]', 'C [%]'});

    write_csv(fullfile(cfg.tabDir, 'Q3_B_network_vs_thetaB.csv'), ...
              {'thetaB_deg', 'phi4_deg', 'phi5_deg', 'kappa_deg', 'C_power_coupling', 'C_dB', 'through_dB'}, ...
              [B.thetaB(:), B.phi4(:), B.phi5(:), B.kappa(:), B.C(:), ...
               10*log10(B.C(:)), 10*log10(1 - B.C(:))], '%.6f');

    % ---- figure: the three unknowns side by side -----------------------------
    st  = cfg.style;
    fig = new_figure(cfg, 'Q3 - B network unknowns', 1129, 317);
    ylab  = {'\phi_4 (deg)', '\phi_5 (deg)', 'VRC coupling C (%)'};
    ttl   = {'\phi_4: H4 in phase', '\phi_5: VRC inputs in phase', 'C = sin^2\kappa: no B in the loads'};
    data  = {B.phi4, B.phi5, 100*B.C};
    for k = 1:3
        ax = sub_axes(fig, 1, 3, k, [0.95 0.2 0.75 0.45 0.95 0]); hold(ax, 'on');
        if k < 3
            [xb, yb] = break_wraps(B.thetaB, data{k});
            set(ax, 'YLim', [0 360], 'YTick', 0:90:360);
        else
            xb = B.thetaB; yb = data{k};
            set(ax, 'YLim', [0 100], 'YTick', 0:25:100);
        end
        set(ax, 'XLim', [0 90], 'XTick', 0:15:90);
        if k == 3
            plot(ax, [0 90], [50 50], '--', 'Color', st.ref, 'LineWidth', st.lwRef);
            text(ax, 89, 50, '3-dB coupler', 'HorizontalAlignment', 'right', ...
                 'VerticalAlignment', 'bottom', 'Color', st.ink2, 'FontSize', st.fs - 1);
        end
        plot(ax, xb, yb, 'Color', st.B, 'LineWidth', st.lw);
        vguide(ax, cfg.thetaA, '', cfg);
        style_axes(ax, cfg, '\theta_B (deg)', ylab{k}, ttl{k});
        if k == 2                          % where the settings are undefined (B identical to A)
            yl = get(ax, 'YLim');
            text(ax, cfg.thetaA, yl(2) - 0.03*diff(yl), ['  ' thetaA_tag(cfg) ' (undefined)'], ...
                 'VerticalAlignment', 'top', 'Color', st.ink2, 'FontSize', st.fs - 1);
        end
    end
    save_figure(cfg, fig, 'Q3_B_network_unknowns_vs_thetaB');
end
