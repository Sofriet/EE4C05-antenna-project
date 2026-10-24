function loc = free_corner(busy, cand, fallback)
%FREE_CORNER  First legend location whose x-range does not cover a label.
%
%   loc = FREE_CORNER(busy, cand, fallback)
%   busy     K-by-2 [x_start, x_end] ranges already taken by labels (deg)
%   cand     N-by-2 cell, {location, [x1 x2]} in order of preference,
%            e.g. {'southeast', [60 90]; 'southwest', [0 30]}
%   fallback location used when every candidate is taken (e.g. 'eastoutside')

    loc = fallback;
    for c = 1:size(cand, 1)
        r = cand{c, 2};
        if isempty(busy) || ~any(busy(:, 2) > r(1) & busy(:, 1) < r(2))
            loc = cand{c, 1};
            return
        end
    end
end
