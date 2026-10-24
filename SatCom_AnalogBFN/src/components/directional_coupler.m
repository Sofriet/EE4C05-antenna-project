function [outTop, outBot] = directional_coupler(inTop, inBot, kappa_deg)
%DIRECTIONAL_COUPLER  Ideal (lossless, matched) 2-in / 2-out coupler.
%
%   [outTop, outBot] = DIRECTIONAL_COUPLER(inTop, inBot, kappa_deg)
%
%       outTop = -j*cos(kappa)*inTop -   sin(kappa)*inBot
%       outBot =   -sin(kappa)*inTop - j*cos(kappa)*inBot
%
%   kappa = 45 deg is the 3-dB 90-degree hybrid of Lecture 4 (slide 27):
%       straight path (top->top, bot->bot):  1/sqrt(2) at  -90 deg
%       cross path    (top->bot, bot->top):  1/sqrt(2) at -180 deg
%   i.e. "as combiner": out_top = (A/-90 + B/-180)/sqrt(2),
%                       out_bot = (A/-180 + B/-90)/sqrt(2).
%
%   Any other kappa gives a variable-ratio coupler (VRC) with the same phase
%   behaviour: power fraction on the cross path C = sin(kappa)^2, on the
%   straight path 1 - C = cos(kappa)^2. The 2x2 matrix is unitary for every
%   kappa, so the coupler is lossless.
%
%   Inputs may be arrays of equal size; kappa_deg is a scalar or the same
%   size (element-wise operation).

    c = cosd(kappa_deg);
    s = sind(kappa_deg);
    outTop = -1j .* c .* inTop -       s .* inBot;
    outBot =       -s .* inTop - 1j .* c .* inBot;
end
