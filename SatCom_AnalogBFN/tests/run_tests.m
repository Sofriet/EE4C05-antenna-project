function nFail = run_tests()
%RUN_TESTS  Self-checks of the network model and the design algorithms.
%
%   Run from any folder (e.g. open this file and press Run): it adds the
%   project root (config.m) and src/ to the path itself.
%   Returns the number of failed checks (0 = all good).

    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(root, genpath(fullfile(root, 'src')));
    cfg = config();

    fprintf('Running self-checks (thetaA = %g deg)\n', cfg.thetaA);
    nFail = 0;
    nFail = nFail + check('3-dB hybrid reproduces the Lecture-4 Butler beam (135/90/45/0 deg)', t_butler());
    nFail = nFail + check('network is lossless for random inputs and settings', t_lossless(cfg));
    nFail = nFail + check('A design: 6.02 dBi at port 5, nothing at port 6 / loads', t_A_design(cfg));
    nFail = nFail + check('A design matches the closed form for thetaA = 0..90 deg', t_A_closed_form(cfg));
    nFail = nFail + check('B design: zero A at port 6 for every thetaB', t_B_null(cfg));
    nFail = nFail + check('B design: |p5|^2 + |p6|^2 = N, no B power in the loads', t_B_power(cfg));
    nFail = nFail + check('B design reaches the projection (null-constrained) bound', t_B_bound(cfg));
    nFail = nFail + check('B design matches the closed forms of phi4, phi5, kappa', t_B_closed_form(cfg));
    nFail = nFail + check('2-bit quantizer: 4 states, error <= 45 deg', t_quantizer());
    nFail = nFail + check('port weights reproduce the forward model', t_weights(cfg));
    nFail = nFail + check('2-bit: the null-keeping phi4/phi5 pairs cancel A exactly', t_two_bit_null(cfg));
    if nFail == 0
        fprintf('All checks passed.\n');
    else
        fprintf('%d check(s) FAILED.\n', nFail);
    end
end

% -------------------------------------------------------------------------
function f = check(name, ok)
    if ok, tag = 'PASS'; else, tag = 'FAIL'; end
    fprintf('  [%s] %s\n', tag, name);
    f = double(~ok);
end

function ok = t_butler()
%   Lecture 4 slides 27-28, transmit mode, beam port A. A vertical coupler is
%   mapped onto directional_coupler with left = "top", right = "bot"
%   (straight path -90 deg, cross path -180 deg). The fixed pi/4 shifter of
%   the Butler matrix is a 45-deg delay, i.e. phi = -45 deg here.
    [oL, oR] = hybrid_3dB(1, 0);                    % lower-left coupler, A at its left input
    [e1, e3] = hybrid_3dB(phase_shifter(oL, -45), 0);   % upper-left coupler -> elements 1, 3
    [e2, e4] = hybrid_3dB(oR, 0);                   % upper-right coupler -> elements 2, 4
    e   = [e1 e2 e3 e4];
    ok  = all(abs(abs(e) - 0.5) < 1e-12) && ...
          all(abs(wrap180(angle(e)*180/pi - [135 90 45 0])) < 1e-9);
end

function ok = t_lossless(cfg)
    rng(1);
    M = 200;
    V = randn(4, M) + 1j*randn(4, M);
    s = neutral_settings(M);
    s.phi1 = 360*rand(1, M); s.phi2 = 360*rand(1, M); s.phi3 = 360*rand(1, M);
    s.phi4 = 360*rand(1, M); s.phi5 = 360*rand(1, M); s.kappa = 90*rand(1, M);
    o = bfn_forward(V, s);
    pin  = sum(abs(V).^2, 1);
    pout = abs(o.port5).^2 + abs(o.port6).^2 + abs(o.load_H4).^2 + abs(o.load_VRC).^2;
    ok = max(abs(pin - pout)) < 1e-10 * max(pin);
end

function ok = t_A_design(cfg)
    A = design_A_network(cfg);
    o = bfn_forward(incident_wave(cfg.thetaA, cfg.N, cfg.d_lambda), A.settings);
    ok = abs(gain_dB(o.port5) - 10*log10(cfg.N)) < 1e-9 && ...
         max(abs([o.H1top o.H2top o.H3top o.port6 o.load_H4 o.load_VRC])) < 1e-12;
end

function ok = t_A_closed_form(cfg)
    ok = true;
    for tA = 0:5:90
        c = cfg; c.thetaA = tA;
        A = design_A_network(c);
        e = wrap180([A.phi1 A.phi2 A.phi3] - [A.closedForm.phi1 A.closedForm.phi2 A.closedForm.phi3]);
        ok = ok && max(abs(e)) < 1e-9;
    end
end

function ok = t_B_null(cfg)
    A  = design_A_network(cfg);
    B  = design_B_network(cfg, A.settings);
    M  = numel(cfg.thetaB);
    oA = bfn_forward(repmat(incident_wave(cfg.thetaA, cfg.N, cfg.d_lambda), 1, M), B.settings);
    ok = max(abs(oA.port6)) < 1e-12;
end

function ok = t_B_power(cfg)
    A  = design_A_network(cfg);
    B  = design_B_network(cfg, A.settings);
    oB = bfn_forward(incident_wave(cfg.thetaB, cfg.N, cfg.d_lambda), B.settings);
    ok = max(abs(abs(oB.port5).^2 + abs(oB.port6).^2 - cfg.N)) < 1e-10 && ...
         max(abs([oB.load_H4 oB.load_VRC])) < 1e-7;
end

function ok = t_B_bound(cfg)
    A  = design_A_network(cfg);
    B  = design_B_network(cfg, A.settings);
    VB = incident_wave(cfg.thetaB, cfg.N, cfg.d_lambda);
    oB = bfn_forward(VB, B.settings);
    a  = incident_wave(cfg.thetaA, cfg.N, cfg.d_lambda);
    bound = sum(abs(VB).^2, 1) - abs(a' * VB).^2 / cfg.N;   % ||P_perp a_B||^2
    ok = max(abs(abs(oB.port6).^2 - bound)) < 1e-10;
end

function ok = t_B_closed_form(cfg)
    ok = true;
    for tA = [0 13 20 37 60 85]
        c = cfg; c.thetaA = tA;
        A  = design_A_network(c);
        B  = design_B_network(c, A.settings);
        cf = closed_form_design(c, c.thetaB);
        ok = ok && max(abs(wrap180(B.phi4(B.def4) - cf.phi4(B.def4)))) < 1e-4 ...
                && max(abs(wrap180(B.phi5(B.def5) - cf.phi5(B.def5)))) < 1e-4 ...
                && max(abs(B.kappa(B.defK) - cf.kappa(B.defK))) < 1e-4;   % deg (round-off grows next to the singular points)
    end
end

function ok = t_quantizer()
    p  = linspace(-720, 720, 20001);
    q  = quantize_phase(p, 2);
    ok = isequal(unique(q), [0 90 180 270]) && max(abs(wrap180(q - p))) <= 45 + 1e-9;
end

function ok = t_two_bit_null(cfg)
%   The rounded blue network keeps phi1 = phi2, so both element pairs leak A
%   in the same way; for the right phi4/phi5 states the two A terms at the
%   VRC inputs are real-proportional and a continuous kappa cancels them.
%   Brute-force check over all 16 state pairs.
    q  = @(p) quantize_phase(p, 2);
    A  = design_A_network(cfg, q);
    VA = incident_wave(cfg.thetaA, cfg.N, cfg.d_lambda);
    nNull = 0;  worst = 0;
    for p4 = 0:90:270
        for p5 = 0:90:270
            s = A.settings;  s.phi4 = p4;  s.phi5 = p5;  s.kappa = 45;
            o = bfn_forward(VA, s);
            P = -1j * o.VRCin_top;  Q = -o.VRCin_bot;
            if abs(P) < 1e-9 && abs(Q) < 1e-9          % rounded A network still exact
                nNull = nNull + 1;  continue
            end
            if abs(Q) < 1e-9, r = Inf; else, r = -P / Q; end
            if isinf(r)
                s.kappa = 90;  o = bfn_forward(VA, s);
                nNull = nNull + 1;  worst = max(worst, abs(o.port6));
            elseif abs(imag(r)) <= 1e-9 * abs(r) && real(r) >= 0
                s.kappa = atand(real(r));
                o = bfn_forward(VA, s);
                nNull = nNull + 1;
                worst = max(worst, abs(o.port6));
            end
        end
    end
    ok = nNull >= 1 && worst < 1e-12;
end

function ok = t_weights(cfg)
    A  = design_A_network(cfg);
    B  = design_B_network(cfg, A.settings);
    M  = numel(cfg.thetaB);
    VB = incident_wave(cfg.thetaB, cfg.N, cfg.d_lambda);
    W  = port_weights(B.settings, M);
    o  = bfn_forward(VB, B.settings);
    ok = max(abs(sum(W.port6 .* VB, 1) - o.port6)) < 1e-12 && ...
         max(abs(sum(W.port5 .* VB, 1) - o.port5)) < 1e-12;
end
