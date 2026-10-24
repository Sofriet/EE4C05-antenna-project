function [xb, yb] = break_wraps(x, y, jump)
%BREAK_WRAPS  Insert NaN where a wrapped phase jumps (no vertical lines in plots).
%
%   [xb, yb] = BREAK_WRAPS(x, y)        breaks where |diff(y)| > 180 deg
%   [xb, yb] = BREAK_WRAPS(x, y, jump)  custom jump threshold

    if nargin < 3, jump = 180; end
    x = x(:).'; y = y(:).';
    idx = find(abs(diff(y)) > jump);
    xb = x; yb = y;
    for k = numel(idx):-1:1
        i  = idx(k);
        xb = [xb(1:i), NaN, xb(i+1:end)];
        yb = [yb(1:i), NaN, yb(i+1:end)];
    end
end
