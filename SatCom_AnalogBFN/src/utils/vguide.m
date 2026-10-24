function h = vguide(ax, x, label, cfg, where)
%VGUIDE  Thin dotted vertical guide (e.g. thetaB = thetaA) with a small label.
%
%   h = VGUIDE(ax, x, label, cfg)          label at the top of the axes
%   h = VGUIDE(ax, x, label, cfg, 'bottom')

    if nargin < 5, where = 'top'; end
    yl = get(ax, 'YLim');
    h  = plot(ax, [x x], yl, ':', 'Color', cfg.style.ink2, 'LineWidth', 1.2);
    if ~isempty(label)
        if strcmp(where, 'top')
            yt = yl(2) - 0.03*diff(yl); va = 'top';
        else
            yt = yl(1) + 0.03*diff(yl); va = 'bottom';
        end
        text(ax, x, yt, ['  ' label], 'VerticalAlignment', va, ...
             'HorizontalAlignment', 'left', 'Color', cfg.style.ink2, ...
             'FontSize', cfg.style.fs - 1);
    end
    set(ax, 'YLim', yl);
end
