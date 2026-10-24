function style_axes(ax, cfg, xlab, ylab, ttl)
%STYLE_AXES  Recessive hairline grid, consistent fonts and labels.
%
%   STYLE_AXES(ax, cfg, xlabel, ylabel, title)   (empty strings are skipped)

    st = cfg.style;
    set(ax, 'FontSize', st.fs, 'Box', 'on', 'LineWidth', 0.8, ...
            'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '-', ...
            'GridColor', st.grid, 'GridAlpha', 1, ...
            'XColor', st.ink2, 'YColor', st.ink2, 'TickDir', 'out');
    if nargin >= 3 && ~isempty(xlab)
        xlabel(ax, xlab, 'FontSize', st.fsLab, 'Color', st.ink);
    end
    if nargin >= 4 && ~isempty(ylab)
        ylabel(ax, ylab, 'FontSize', st.fsLab, 'Color', st.ink);
    end
    if nargin >= 5 && ~isempty(ttl)
        title(ax, ttl, 'FontSize', st.fsLab, 'Color', st.ink, 'FontWeight', 'bold');
    end
end
