function fig = new_figure(cfg, name, w, h)
%NEW_FIGURE  White figure with a fixed physical size (same layout on every OS).
%
%   fig = NEW_FIGURE(cfg, name, w, h)   w, h in "pixels at 96 dpi"
%   (900 x 500 -> 9.4 x 5.2 inch). The exported PNG is w/96*cfg.dpi pixels
%   wide even if the window on screen is smaller (PaperPosition is fixed).

    if nargin < 3 || isempty(w), w = cfg.style.figW; end
    if nargin < 4 || isempty(h), h = cfg.style.figH; end
    vis = 'on';
    if ~cfg.showFigures, vis = 'off'; end
    wi = w / 96;  hi = h / 96;                    % inches
    fig = figure('Name', name, 'NumberTitle', 'off', 'Color', 'w', 'Visible', vis, ...
                 'Units', 'inches', 'Position', [0.5 0.5 wi hi]);
    set(fig, 'PaperUnits', 'inches', 'PaperPositionMode', 'manual', ...
             'PaperPosition', [0 0 wi hi], 'PaperSize', [wi hi], 'InvertHardcopy', 'off');
end
