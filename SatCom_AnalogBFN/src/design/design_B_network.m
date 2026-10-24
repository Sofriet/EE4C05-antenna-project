function B = design_B_network(cfg, sA, quantizer)
%DESIGN_B_NETWORK  phi4, phi5 and the VRC ratio of the B ("red") network (Q3).
%
%   B = DESIGN_B_NETWORK(cfg, sA)              continuous phase shifters
%   B = DESIGN_B_NETWORK(cfg, sA, quantizer)   finite-bit phase shifters (Q5)
%
%   sA : settings of the (fixed) A network, from design_A_network.
%   One design per angle in cfg.thetaB.
%
%   Why port 6 never sees A: the A network sends ALL of A to port 5, so the
%   three remaining outputs H1.top, H2.top and H3.top are A-free (orthogonal
%   to the A steering vector). The red network only combines these three
%   signals, so port 6 has zero A for ANY phi4, phi5, kappa. These three
%   unknowns can therefore be used purely to maximise B:
%
%     step 1  H4 : phi4 co-phases H1.top with H2.top  -> all B to H4.top,
%                  nothing into the H4 load
%     step 2  VRC: phi5 co-phases H4.top with H3.top
%     step 3  VRC: kappa from the amplitude ratio, tan(kappa) = |H3.top|/|H4.top|
%                  (maximal-ratio combining) -> nothing into the VRC load
%
%   Result: |port 6|^2 = N - |port 5|^2 for source B, the largest B gain any
%   lossless network can reach while keeping an exact null on A.
%
%   With a quantizer, each phase is quantized as soon as it is computed and
%   the next step is designed on the actual (quantized) signals; kappa is then
%   the exact optimum for the quantized phases (vrc_kappa.m).
%
%   Output (1-by-M rows, M = numel(cfg.thetaB)):
%     B.phi4, B.phi5 [deg, 0..360), B.kappa [deg], B.C = sin(kappa)^2
%     B.def4, B.def5, B.defK   false where that setting is irrelevant because
%                 a coupler input carries no B power (e.g. thetaB = thetaA in
%                 the ideal case); the value is then reported as NaN
%     B.defined   all three settings meaningful
%     B.settings  full settings for bfn_forward (A part + B part)

    if nargin < 3 || isempty(quantizer)
        quantizer = @(p) p;
    end
    thB = cfg.thetaB(:).';
    M   = numel(thB);
    VB  = incident_wave(thB, cfg.N, cfg.d_lambda);            % 4-by-M

    s       = sA;                                             % A part (scalars)
    s.phi4  = zeros(1, M);
    s.phi5  = zeros(1, M);
    s.kappa = 45 * ones(1, M);

    tol = 1e-9;      % below this a coupler input is "empty" and its setting irrelevant

    % step 1: H4 (phase shifter on its bottom input, power wanted at the top)
    o      = bfn_forward(VB, s);
    s.phi4 = quantizer(co_phase(o.H2top, o.H1top, 'bot', 'top'));
    def4   = abs(o.H2top) > tol & abs(o.H1top) > tol;
    o      = bfn_forward(VB, s);

    % step 2: VRC phase (phase shifter on its top input, power wanted at the top)
    s.phi5 = quantizer(co_phase(o.H4top, o.H3top, 'top', 'top'));
    def5   = abs(o.H4top) > tol & abs(o.H3top) > tol;
    o      = bfn_forward(VB, s);

    % step 3: VRC ratio for the actual (co-phased) inputs
    s.kappa = vrc_kappa(o.VRCin_top, o.VRCin_bot);
    defK    = abs(o.VRCin_top) > tol | abs(o.VRCin_bot) > tol;

    B.thetaB   = thB;
    B.phi4     = s.phi4;   B.phi4(~def4)  = NaN;
    B.phi5     = s.phi5;   B.phi5(~def5)  = NaN;
    B.kappa    = s.kappa;  B.kappa(~defK) = NaN;
    B.C        = sind(B.kappa).^2;
    B.def4     = def4;
    B.def5     = def5;
    B.defK     = defK;
    B.defined  = def4 & def5 & defK;
    B.settings = s;
end
