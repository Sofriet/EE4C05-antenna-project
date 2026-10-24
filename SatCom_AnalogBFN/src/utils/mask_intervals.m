function iv = mask_intervals(x, mask)
%MASK_INTERVALS  Contiguous runs of a logical mask as [x_start, x_end] rows.
%
%   iv = MASK_INTERVALS(x, mask)   e.g. the thetaB ranges where a condition holds
%   (an empty mask gives a 0-by-2 array).

    x = x(:).';  mask = logical(mask(:).');
    d = diff([false, mask, false]);
    s = find(d == 1);
    e = find(d == -1) - 1;
    iv = [x(s).', x(e).'];
    if isempty(iv), iv = zeros(0, 2); end
end
