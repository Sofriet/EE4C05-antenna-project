function p = wrap360(p)
%WRAP360  Wrap phase values [deg] to the interval [0, 360).
    p = mod(p, 360);
    p(abs(p - 360) < 1e-9) = 0;      % avoid printing 360.00 for round-off
end
