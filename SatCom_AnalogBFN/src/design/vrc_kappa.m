function kappa = vrc_kappa(a, b)
%VRC_KAPPA  Coupling angle of the variable-ratio coupler that maximises port 6.
%
%   kappa = VRC_KAPPA(a, b)   [deg, in 0..90]
%
%   a  signal at the VRC top input (after phi5), b at the bottom input.
%   Port 6 = VRC.top = -j cos(k) a - sin(k) b = cos(k) P + sin(k) Q,
%            P = -j a,  Q = -b
%   |port 6|^2 = cos^2(k)|P|^2 + sin^2(k)|Q|^2 + sin(2k) Re(P Q*)
%   is maximal for  2k = atan2( 2 Re(P Q*), |P|^2 - |Q|^2 ).
%   If Re(P Q*) < 0 the best value inside 0..90 deg is an end point.
%
%   For co-phased inputs (phi5 from co_phase) this is the maximal-ratio rule
%       tan(kappa) = |b| / |a|,
%   which leaves nothing for the VRC load: |port 6|^2 = |a|^2 + |b|^2.
%   Power coupling ratio of the VRC: C = sin(kappa)^2.

    P = -1j * a;
    Q = -b;
    k = 0.5 * atan2(2*real(P .* conj(Q)), abs(P).^2 - abs(Q).^2);   % rad
    neg = k < 0;                                  % optimum outside 0..90 deg
    k(neg) = (abs(Q(neg)) > abs(P(neg))) * pi/2;  % pick the better end point
    kappa = k * 180/pi;
end
