function ax = sub_axes(fig, m, n, k)
%SUB_AXES  subplot(m,n,k) inside fig without making an off-screen figure visible.
    set(0, 'CurrentFigure', fig);
    ax = subplot(m, n, k);
end
