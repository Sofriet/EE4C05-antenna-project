function [outTop, outBot] = hybrid_3dB(inTop, inBot)
%HYBRID_3DB  Ideal 3-dB 90-degree hybrid (branch-line), Lecture 4 slide 27.
%
%   [outTop, outBot] = HYBRID_3DB(inTop, inBot)
%       outTop = ( inTop/-90deg  + inBot/-180deg ) / sqrt(2)
%       outBot = ( inTop/-180deg + inBot/-90deg  ) / sqrt(2)
%
%   Special case kappa = 45 deg of directional_coupler.m.

    [outTop, outBot] = directional_coupler(inTop, inBot, 45);
end
