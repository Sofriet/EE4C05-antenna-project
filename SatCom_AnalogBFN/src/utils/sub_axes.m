function ax = sub_axes(fig, m, n, k, margins)
%SUB_AXES  Axes k of an m-by-n grid in fig, with fixed margins in inches.
%
%   ax = SUB_AXES(fig, m, n, k)            default margins (room for 15-pt labels)
%   ax = SUB_AXES(fig, m, n, k, margins)   margins = [left right bottom top hgap vgap] (inch)
%
%   k counts row by row, as in subplot. The gaps do not scale with the figure
%   (subplot's do), so the labels get the same room in MATLAB and Octave, and
%   an off-screen figure does not pop up.

    if nargin < 5 || isempty(margins)
        margins = [0.95 0.25 0.75 0.45 1.05 0.85];
    end
    set(fig, 'PaperUnits', 'inches');
    pp = get(fig, 'PaperPosition');  W = pp(3);  H = pp(4);     % exported size (new_figure)
    L = margins(1); R = margins(2); B = margins(3); T = margins(4);
    hg = margins(5); vg = margins(6);
    w = (W - L - R - (n - 1)*hg) / n;            % axes size [inch]
    h = (H - B - T - (m - 1)*vg) / m;
    r = ceil(k / n);  c = k - (r - 1)*n;         % row (from the top), column
    x = L + (c - 1)*(w + hg);
    y = H - T - r*h - (r - 1)*vg;
    ax = axes('Parent', fig, 'Units', 'normalized', ...
              'Position', [x/W, y/H, w/W, h/H]);
end
