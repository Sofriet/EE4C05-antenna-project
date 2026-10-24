function q = quantize_phase(phi_deg, nBits)
%QUANTIZE_PHASE  Nearest state of an nBits digital phase shifter.
%
%   q = QUANTIZE_PHASE(phi_deg, nBits)   [deg, wrapped to 0..360)
%
%   States 0, LSB, 2*LSB, ..., 360-LSB with LSB = 360/2^nBits.
%   2 bits: 0, 90, 180, 270 deg -> phase error at most +/-45 deg.
%   A value exactly half-way between two states (both equally good) always
%   goes to the upper state, so round-off noise cannot make it flip.

    lsb = 360 / 2^nBits;
    q   = wrap360(round(phi_deg / lsb + 1e-9) * lsb);
end
