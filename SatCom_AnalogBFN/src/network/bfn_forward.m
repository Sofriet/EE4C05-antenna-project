function out = bfn_forward(V, s)
%BFN_FORWARD  Receive-mode signal flow through the analog beamforming network.
%
%   out = BFN_FORWARD(V, s)
%
%   V  4-by-M element signals (one column per incident wave, incident_wave.m)
%   s  network settings (struct), see neutral_settings.m:
%        s.phi1 ... s.phi5   phase shifters [deg]
%        s.kappa             coupling angle of the variable-ratio coupler [deg]
%      Every field is a scalar or a 1-by-M row (one setting per column, e.g. a
%      different B design for every thetaB).
%
%   out  struct of 1-by-M voltages at every node of the network:
%        port5, port6            beam ports A and B
%        load_H4, load_VRC       waves absorbed by the two matched loads
%        H1top ... H4bot         hybrid outputs, VRCin_top / VRCin_bot inputs
%
%   Topology (assignment slide 3; "top" = upper port of a block):
%
%     element 2 -[phi1]-> H1.inTop   element 1 -> H1.inBot     (lower-left 3 dB)
%     element 4 -[phi2]-> H2.inTop   element 3 -> H2.inBot     (upper-left 3 dB)
%     H2.top  ----------> H4.inTop   H1.top -[phi4]-> H4.inBot (red 3 dB)
%     H2.bot  -[phi3]---> H3.inTop   H1.bot ---------> H3.inBot (lower-right 3 dB)
%     H4.top  -[phi5]---> VRC.inTop  H3.top ---------> VRC.inBot
%
%     PORT 5 (A) = H3.bot        load = H4.bot
%     PORT 6 (B) = VRC.top       load = VRC.bot
%
%   All components are ideal, lossless and matched, so waves only travel
%   from the antennas towards the ports (no reflections).

    if size(V, 1) ~= 4
        error('bfn_forward:size', 'The network has 4 element ports: V must be 4-by-M.');
    end

    % stage 1 - element pairs (shared by both networks)
    [out.H1top, out.H1bot] = hybrid_3dB(phase_shifter(V(2,:), s.phi1), V(1,:));
    [out.H2top, out.H2bot] = hybrid_3dB(phase_shifter(V(4,:), s.phi2), V(3,:));

    % stage 2a - A network output hybrid H3 (its lower output is port 5)
    [out.H3top, out.H3bot] = hybrid_3dB(phase_shifter(out.H2bot, s.phi3), out.H1bot);

    % stage 2b - B network hybrid H4 (lower output terminated)
    [out.H4top, out.H4bot] = hybrid_3dB(out.H2top, phase_shifter(out.H1top, s.phi4));

    % stage 3 - variable-ratio coupler (upper output is port 6, lower terminated)
    out.VRCin_top = phase_shifter(out.H4top, s.phi5);
    out.VRCin_bot = out.H3top;
    [out.VRCtop, out.VRCbot] = directional_coupler(out.VRCin_top, out.VRCin_bot, s.kappa);

    % named ports
    out.port5    = out.H3bot;
    out.port6    = out.VRCtop;
    out.load_H4  = out.H4bot;
    out.load_VRC = out.VRCbot;
end
