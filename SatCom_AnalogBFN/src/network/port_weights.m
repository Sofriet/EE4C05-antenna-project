function W = port_weights(s, M)
%PORT_WEIGHTS  Element-to-port transfer coefficients (rows of the S-matrix).
%
%   W = PORT_WEIGHTS(s, M) probes the network with one element at a time and
%   returns 4-by-M matrices
%       W.port5(n,m) = S(5,n),   W.port6(n,m) = S(6,n)    for setting column m
%   so that, for any incident wave V, port voltage = W.port5(:,m).' * V(:,m).
%
%   By reciprocity these are also the element excitations in transmit mode
%   (amplitude |W| and phase angle(W)) when port 5 or port 6 is driven - the
%   "Amplitude taper" / "Phase shift" vectors needed later in the Antenna
%   Array Designer (Q6/Q7).

    if nargin < 2, M = 1; end
    I = eye(4);
    W.port5 = zeros(4, M);
    W.port6 = zeros(4, M);
    for n = 1:4
        o = bfn_forward(repmat(I(:, n), 1, M), s);
        W.port5(n, :) = o.port5;
        W.port6(n, :) = o.port6;
    end
end
