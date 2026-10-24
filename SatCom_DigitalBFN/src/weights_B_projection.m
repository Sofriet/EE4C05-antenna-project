function wB = weights_B_projection(thetaB, thetaA, steer)
% WEIGHTS_B_PROJECTION: maximum gain towards thetaB with a null towards thetaA.
% Returns NaN if thetaB = thetaA (no solution).

aA = steer(thetaA);
aB = steer(thetaB);
N  = numel(aA);

P = eye(N) - (aA*aA')/(aA'*aA);
v = P*aB;

if norm(v) < 1e-9
    wB = nan(N, 1);
    return
end

wB = v/norm(v);
wB = wB*exp(-1j*angle(wB(1)));       % element 1 real and positive (convention 7)
end
