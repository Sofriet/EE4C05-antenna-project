function V = incident_wave(theta_deg, N, d_lambda)
%INCIDENT_WAVE  Element signals for a unit plane wave arriving from theta.
%
%   V = INCIDENT_WAVE(theta_deg, N, d_lambda) returns an N-by-M matrix,
%   one column per angle in theta_deg (M angles):
%
%       V(n,m) = exp( j*k*x_n*sin(theta_m) ),   x_n = (n-1)*d,  k = 2*pi/lambda0
%
%   theta is measured from the z-axis (array broadside) towards +x, as in the
%   assignment figure. Element 1 sits at x = 0, element 4 at x = 3d; the wave
%   reaches element 4 first, so it has the largest phase (Lecture 4, slide 15:
%   V2+ = 1, V3+ = exp(j k d sin(theta))).

    theta_deg = theta_deg(:).';                 % 1-by-M
    n   = (0:N-1).';                            % N-by-1
    psi = 2*pi*d_lambda*sind(theta_deg);        % k*d*sin(theta), 1-by-M
    V   = exp(1j * n * psi);                    % N-by-M
end
