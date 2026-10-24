function A = design_A_network(cfg, quantizer)
%DESIGN_A_NETWORK  Phase shifters phi1, phi2, phi3 of the A ("blue") network (Q1).
%
%   A = DESIGN_A_NETWORK(cfg)              continuous phase shifters
%   A = DESIGN_A_NETWORK(cfg, quantizer)   every phase is passed through
%                                          quantizer(phi_deg) as soon as it is
%                                          computed (finite-bit case, Q5)
%
%   Goal: all power of source A (direction thetaA) at port 5.
%   Algorithm, stage by stage on the actual signals (co_phase.m):
%     stage 1  H1 (elements 1,2): phi1 sends all of A to H1.bot (towards H3)
%              H2 (elements 3,4): phi2 sends all of A to H2.bot (towards H3)
%     stage 2  H3 (pair sums)   : phi3 sends all of A to H3.bot = port 5
%   Closed form (ideal), psiA = k d sin(thetaA):
%       phi1 = phi2 = 90 - psiA,    phi3 = 90 - 2*psiA      [deg]
%   Side effect that the B network exploits: the other outputs H1.top,
%   H2.top and H3.top then carry NO signal from A.
%
%   Output: A.phi1, A.phi2, A.phi3 [deg, 0..360), A.settings (for
%   bfn_forward), A.closedForm, A.psiA [deg].

    if nargin < 2 || isempty(quantizer)
        quantizer = @(p) p;
    end
    VA = incident_wave(cfg.thetaA, cfg.N, cfg.d_lambda);      % 4-by-1

    s = neutral_settings();
    % stage 1: co-phase each element pair into the lower hybrid output
    s.phi1 = quantizer(co_phase(VA(2), VA(1), 'top', 'bot'));
    s.phi2 = quantizer(co_phase(VA(4), VA(3), 'top', 'bot'));
    o = bfn_forward(VA, s);
    % stage 2: co-phase the two pair sums into port 5
    s.phi3 = quantizer(co_phase(o.H2bot, o.H1bot, 'top', 'bot'));

    A.phi1     = s.phi1;
    A.phi2     = s.phi2;
    A.phi3     = s.phi3;
    A.settings = s;

    cf = closed_form_design(cfg, cfg.thetaA);
    A.psiA       = cf.psiA;
    A.closedForm = struct('phi1', cf.phi1, 'phi2', cf.phi2, 'phi3', cf.phi3);
end
