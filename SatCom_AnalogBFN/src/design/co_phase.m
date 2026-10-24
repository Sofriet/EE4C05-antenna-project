function phi = co_phase(a, b, psAt, target)
%CO_PHASE  Phase-shifter value that makes two coupler inputs add up at one output.
%
%   phi = CO_PHASE(a, b, psAt, target)   [deg, wrapped to 0..360)
%
%   a, b    signals at the top / bottom coupler input, taken BEFORE the
%           phase shifter (arrays of equal size)
%   psAt    'top' or 'bot' - the input that carries the phase shifter
%   target  'top' or 'bot' - the output that must collect the power
%
%   Coupler model (directional_coupler.m):
%       outTop = -j cos(k) a -   sin(k) b
%       outBot =   -sin(k) a - j cos(k) b
%   The two terms at the target output are in phase when
%       psAt = top, target = bot :  phi = arg(b) - arg(a) + 90
%       psAt = bot, target = top :  phi = arg(a) - arg(b) + 90
%       psAt = top, target = top :  phi = arg(b) - arg(a) - 90
%       psAt = bot, target = bot :  phi = arg(a) - arg(b) - 90
%   (independent of kappa). For a 3-dB hybrid with |a| = |b| this sends ALL
%   power to the target output and nothing to the other one.

    da = angle(a) * 180/pi;
    db = angle(b) * 180/pi;
    key = [lower(psAt) '>' lower(target)];
    switch key
        case 'top>bot', phi = db - da + 90;
        case 'bot>top', phi = da - db + 90;
        case 'top>top', phi = db - da - 90;
        case 'bot>bot', phi = da - db - 90;
        otherwise
            error('co_phase:args', 'psAt and target must be ''top'' or ''bot''.');
    end
    phi = wrap360(phi);
end
