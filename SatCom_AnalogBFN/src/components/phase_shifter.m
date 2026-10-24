function out = phase_shifter(in, phi_deg)
%PHASE_SHIFTER  Ideal lossless phase shifter: out = in * exp(+j*phi).
%
%   phi is the phase ADDED to the signal (degrees). That is how Lecture 4
%   writes phase shifts: slide 20 gives -2*pi*(d/lambda)*sin(theta) for the
%   phase shifter that replaces a time delay, and slides 41-43 use
%   delta_n - delta_(n-1) = beta with beta = -k*d*sin(theta0) for a beam at
%   theta0. The fixed "pi/4" block of the Butler example (slides 27-28) only
%   gives the element phases 135/90/45/0 deg if it delays by 45 deg, so in
%   this convention it is phi = -45 deg (see tests/run_tests.m).
%   Read as delays (exp(-j*phi)), every phase value changes sign; the gains
%   stay the same.

    out = in .* exp(1j * phi_deg * pi/180);
end
