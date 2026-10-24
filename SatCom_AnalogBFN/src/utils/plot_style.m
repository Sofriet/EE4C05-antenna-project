function st = plot_style()
%PLOT_STYLE  Colours and sizes shared by every figure.
%
%   Blue = source / network A and red = source / network B, as in the
%   assignment figure. Grey is only used for reference curves and bounds.
%   (Colour pairs checked for colour-vision deficiency; every series also has
%   a legend entry or a direct label, so colour never carries meaning alone.)

    st.A     = hex2rgb('#2a78d6');           % blue  - source A / port 5
    st.B     = hex2rgb('#e34948');           % red   - source B / port 6
    st.ref   = hex2rgb('#898781');           % grey  - reference curves, bounds
    st.ink   = hex2rgb('#0b0b0b');           % titles, labels
    st.ink2  = hex2rgb('#52514e');           % axes, annotations
    st.grid  = hex2rgb('#e1e0d9');           % hairline grid
    st.shade = hex2rgb('#f3f2ee');           % background bands
    st.Bramp = [hex2rgb('#ee7d7c');          % ordered B designs, light -> dark
                hex2rgb('#d43d3c');
                hex2rgb('#8f2424')];

    st.lw    = 2.0;                          % data lines
    st.lwRef = 1.3;                          % reference lines
    st.fs    = 13;                           % tick labels, legends
    st.fsLab = 14;                           % axis labels, titles
    st.figW  = 900;                          % default figure size [px]
    st.figH  = 500;
end

function rgb = hex2rgb(h)
    rgb = [hex2dec(h(2:3)), hex2dec(h(4:5)), hex2dec(h(6:7))] / 255;
end
