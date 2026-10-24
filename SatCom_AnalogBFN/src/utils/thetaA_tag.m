function s = thetaA_tag(cfg)
%THETAA_TAG  Text such as '\theta_A = 8^{\circ}' for figure titles (TeX markup).
    s = sprintf('\\theta_A = %g^{\\circ}', cfg.thetaA);
end
