function p = wrap180(p)
%WRAP180  Wrap phase values [deg] to the interval [-180, 180).
    p = mod(p + 180, 360) - 180;
end
