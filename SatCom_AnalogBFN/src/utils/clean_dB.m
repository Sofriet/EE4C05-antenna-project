function x = clean_dB(x)
%CLEAN_DB  Turn round-off "nulls" into exact infinities.
%
%   x = CLEAN_DB(x): values below -200 dB (|v| < 1e-10, numerically zero)
%   become -Inf and values above +200 dB become +Inf, so that tables and
%   statistics do not show platform-dependent numbers such as -309.96 dB.

    x(x < -200) = -Inf;
    x(x >  200) =  Inf;
end
