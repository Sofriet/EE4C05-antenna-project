function st = plot_style()
%PLOT_STYLE  Colours and sizes shared by every figure.
%
%   Blue = source / network A and orange = source / network B (the same
%   colours as the digital-beamformer plots of the group presentation).
%   Grey is only used for reference curves and bounds. (Blue/orange checked
%   for colour-vision deficiency; every series also has a legend entry or a
%   direct label, so colour never carries meaning alone.)

    st.A     = hex2rgb('#1171be');           % blue   - source A / port 5
    st.B     = hex2rgb('#dd5400');           % orange - source B / port 6
    st.ref   = hex2rgb('#898781');           % grey  - reference curves, bounds
    st.ink   = hex2rgb('#0b0b0b');           % titles, labels
    st.ink2  = hex2rgb('#52514e');           % axes, annotations
    st.grid  = hex2rgb('#e1e0d9');           % hairline grid
    st.shade = hex2rgb('#f3f2ee');           % background bands
    st.Bramp = [hex2rgb('#f2a06e');          % ordered B designs, light -> dark
                hex2rgb('#dd5400');
                hex2rgb('#8f3700')];

    % Sizes in points. Each figure is drawn at the size it has on a 16:9 slide
    % (see new_figure), so 15 pt here is also 15 pt in the presentation.
    st.lw    = 2.6;                          % data lines
    st.lwRef = 1.8;                          % reference lines
    st.fs    = 15;                           % tick labels, legends
    st.fsLab = 17;                           % axis labels, titles
    st.figW  = 900;                          % default figure size [px]
    st.figH  = 500;
end

function rgb = hex2rgb(h)
    rgb = [hex2dec(h(2:3)), hex2dec(h(4:5)), hex2dec(h(6:7))] / 255;
end
