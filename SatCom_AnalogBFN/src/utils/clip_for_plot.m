function y = clip_for_plot(x, lo, hi)
%CLIP_FOR_PLOT  Clamp data to just outside the axes so that lines leave the plot.
%
%   y = CLIP_FOR_PLOT(x, lo, hi)
%   +/-Inf (an exact null, or a change measured against one) becomes lo/hi,
%   so the line visibly runs off the axes. NaN stays NaN and leaves a gap:
%   max(NaN, lo) would silently return lo and draw a false spike.

    y = min(max(x, lo), hi);
    y(isnan(x)) = NaN;
end
