function cf = closed_form_design(cfg, thetaB)
%CLOSED_FORM_DESIGN  Analytic solution of the ideal network (cross-check).
%
%   cf = CLOSED_FORM_DESIGN(cfg, thetaB)
%
%   With psi = k d sin(theta) (psiA for A, psiB for B) and Delta = psiB - psiA:
%     A network  phi1 = phi2 = 90 - psiA,   phi3 = 90 - 2 psiA
%     B network  phi4 = 90 + 2 psiB
%                phi5 = -90 - psiA - psiB
%                tan(kappa) = 1 + cos(Delta)            (VRC ratio)
%     gains      |port5_A|^2 = N
%                |port5_B|^2 = 4 cos^2(Delta/2) cos^2(Delta)    (A-beam pattern)
%                |port6_B|^2 = N - |port5_B|^2
%   All phases in degrees, wrapped to 0..360. Derivation: backup slides /
%   README. Valid for the 4-element network of the assignment.

    if nargin < 2, thetaB = cfg.thetaB; end
    thetaB = thetaB(:).';
    cf.psiA  = 360*cfg.d_lambda*sind(cfg.thetaA);       % [deg]
    cf.psiB  = 360*cfg.d_lambda*sind(thetaB);           % [deg]
    cf.Delta = cf.psiB - cf.psiA;                       % [deg]

    cf.phi1  = wrap360(90 - cf.psiA);
    cf.phi2  = cf.phi1;
    cf.phi3  = wrap360(90 - 2*cf.psiA);

    cf.phi4  = wrap360(90 + 2*cf.psiB);
    cf.phi5  = wrap360(-90 - cf.psiA - cf.psiB);
    cf.kappa = atand(1 + cosd(cf.Delta));
    cf.C     = sind(cf.kappa).^2;

    cf.G5A_lin = cfg.N;
    cf.G5B_lin = 4 * cosd(cf.Delta/2).^2 .* cosd(cf.Delta).^2;
    cf.G6B_lin = cfg.N - cf.G5B_lin;
end
