%% Initialize
clear; close all; clc;
array_setup

%% Q1: weights w_A
aA = steer(thetaA);
wA = aA / norm(aA);

%% Q2: gain for source A and B at port 5 for varying thetaB
thetaB = 0:0.01:90;
aB  = steer(thetaB);
M   = numel(thetaB);
G5A = abs(wA' * aA).^2;
G5B = abs(wA' * aB).^2;

%% Q3: weights w_B for every theta_B
W = nan(N, M);
for m = 1:M
    W(:, m) = weights_B_projection(thetaB(m), thetaA, steer);
end
valid = ~isnan(W(1, :));                    % no solution (e.g. theta_B = theta_A)

G6A = (abs(W' * aA).^2).';                  % leakage toward theta_A at port 6, should be zero

%% Q4: gain for source B at port 6 for varying thetaB
G6B     = abs(sum(conj(W)     .* aB, 1)).^2;

%% Q5: gain for source A and B at port 6 with uniform amplitude weights
W_uni = exp(1j*angle(W)) / sqrt(N);

G6A_uni = (abs(W_uni' * aA).^2).';
G6B_uni = abs(sum(conj(W_uni) .* aB, 1)).^2;
deltaG  = dB(G6B_uni) - dB(G6B);

%% Q6: dipole elements with the array factor (pattern multiplication)
% dipole designed in the Antenna Designer app, resonant at 9 GHz, along the y-axis
ant = load('dipole_antenna.mat').Design;
dipoleZin    = impedance(ant, f0);

% element gain in the xz-plane (az = 0, el = 90 - theta)
GeB_dB = reshape(pattern(ant, f0, 0, 90 - thetaB, 'Type', 'gain'), 1, []);
GeA_dB = pattern(ant, f0, 0, 90 - thetaA, 'Type', 'gain');

% pattern multiplication: in dB the element gain is added
G5A_dip_dB = dB(G5A)*ones(1, M) + GeA_dB;
G5B_dip_dB = dB(G5B) + GeB_dB;
G6B_dip_dB = dB(G6B) + GeB_dB;

% the null of A at port 6 stays a null (0 times the element gain)
deltaG5A_dip = G5A_dip_dB - dB(G5A);
deltaG5B_dip = G5B_dip_dB - dB(G5B);
deltaG6B_dip = G6B_dip_dB - dB(G6B);

%% Q7: embedded element patterns (mutual coupling)
% dipole array designed in the Antenna Array Designer app
arr = load('dipole_antenna_array.mat').Design;
Zt  = 50;                                        % termination of the other elements (receiver input)
iA  = find(abs(thetaB - thetaA) < 1e-9);

% Create thetaB for -90 to +90 deg
thetaB_full = [-fliplr(thetaB(2:end)), thetaB];
pos = thetaB_full >= 0;                          % crop mask back to thetaB

% Create cartesian coordinates of far-field points (x; y; z)
pts = 100*lambda0 * [sind(thetaB_full); zeros(1, 2*M-1); cosd(thetaB_full)];

% magnitude from the gain, phase from the co-polar far field E_y
% (the common phase from MATLAB centering the array drops out of |w^H g|^2)
GeFull_dB = zeros(N, 2*M-1);
phiE      = zeros(N, 2*M-1);
neg = ~pos;                                       % theta < 0 -> azimuth 180
for i = 1:N
    GeFull_dB(i, pos) = reshape(pattern(arr, f0, 0,   90 - thetaB_full(pos), 'ElementNumber', i, 'Termination', Zt, 'Type', 'gain'), 1, []);
    GeFull_dB(i, neg) = reshape(pattern(arr, f0, 180, 90 + thetaB_full(neg), 'ElementNumber', i, 'Termination', Zt, 'Type', 'gain'), 1, []);
    E = EHfields(arr, f0, pts, 'ElementNumber', i, 'Termination', Zt);
    phiE(i, :) = angle(E(2, :));
end
gEfull = 10.^(GeFull_dB/20) .* exp(1j*phiE);     % embedded "steering vectors", -90..90 deg

% crop to theta = 0..90 deg for the gain calculations
gE = gEfull(:, pos);
gA = gE(:, iA);

% gains with coupled elements, using w_A (Q1) and w_B (Q3)
G5A_emb = abs(wA'*gA)^2 * ones(1, M);
G5B_emb = abs(wA'*gE).^2;
G6B_emb = abs(sum(conj(W).*gE, 1)).^2;
G6A_emb = abs(W'*gA).'.^2;                       % leakage of A at port 6

% change in gain w.r.t. isotropic elements (as in Q6)
deltaG5A_emb = dB(G5A_emb) - dB(G5A);
deltaG5B_emb = dB(G5B_emb) - dB(G5B);
deltaG6B_emb = dB(G6B_emb) - dB(G6B);

GisoFull_dB = GeB_dB([M:-1:2, 1:M]);        % isolated dipole, mirror-symmetric in x