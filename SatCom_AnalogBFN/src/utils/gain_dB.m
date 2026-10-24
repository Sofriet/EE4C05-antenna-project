function G = gain_dB(v)
%GAIN_DB  Gain in dBi from a port voltage.
%
%   G = GAIN_DB(v) = 20*log10(|v|)
%
%   With unit-amplitude plane waves at the elements (incident_wave.m) the
%   port voltage is the gain pattern of Lecture 4 (slides 14, 28, 43):
%   |v| = sqrt(N) = 2 for a perfectly co-phased 4-element beam -> 6.02 dBi.
%   An exact zero gives -Inf (perfect null).

    G = 20 * log10(abs(v));
end
