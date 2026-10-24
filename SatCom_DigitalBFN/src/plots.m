%% Run main.m (all calculations)
% clears the workspace, runs array_setup and Q1-Q5
main

%% Q1 + Q2: weights w_A and gains at port 5
for i = 1:N
    fprintf('w_A,%d = %.3f * exp(j %7.2f deg)\n', i, abs(wA(i)), rad2deg(angle(wA(i))));
end
fprintf('G5,A = %.2f dB\n', dB(G5A));

f = figure('Position', [100 100 700 400]); hold on;
plot(thetaB, dB(G5A)*ones(size(thetaB)), 'SeriesIndex', 1, 'LineWidth', 2);
plot(thetaB, dB(G5B), 'SeriesIndex', 2, 'LineWidth', 2);
xline(thetaA, '--k', 'LineWidth', 1.2);
ylim([-40 10]); styleAx(gca);
xlabel('\theta_B (deg)'); ylabel('G_5 (dB)'); title('Gain at port 5');
legend('A, iso: |w_A^H a(\theta_A)|^2', 'B, iso: |w_A^H a(\theta_B)|^2', ...
    sprintf('\\theta_A = %g^\\circ', thetaA), 'Location', 'southeast');
savePng(f, 'q2_port5_gain');

%% Q3: weights w_B(theta_B)
fprintf('theta_B without a solution: %s deg\n', mat2str(thetaB(~valid)));
fprintf('max G6,A (leakage, should be 0): %.1f (dimensionless ratio)\n', max(G6A(valid)));

styles = {'-', '-', '--', '--'};          % |w_1| = |w_4| and |w_2| = |w_3|: dashed keeps both visible
f = figure('Position', [100 100 700 400]);
tiledlayout(2, 1, 'TileSpacing', 'compact');
ax1 = nexttile; hold on;
for i = 1:N
    plot(thetaB, abs(W(i, :)), styles{i}, 'SeriesIndex', i, 'LineWidth', 2.2);
end
yline(1/sqrt(N), ':k', '1/\surdN', 'LineWidth', 1.2);
xline(thetaA, '--k', 'LineWidth', 1.2);
ylim([0.2 0.7]); ylabel('|w_{B,n}|'); styleAx(ax1);
legend('n = 1', 'n = 2', 'n = 3', 'n = 4', 'Location', 'northeast', 'NumColumns', 4);
title('Weights w_B(\theta_B)');
ax2 = nexttile; hold on;
for i = 1:N
    ph = rad2deg(angle(W(i, :)));
    ph([false, abs(diff(ph)) > 180]) = NaN;     % no vertical line where the phase wraps
    plot(thetaB, ph, styles{i}, 'SeriesIndex', i, 'LineWidth', 2.2);
end
xline(thetaA, '--k', 'LineWidth', 1.2);
ylim([-180 180]); yticks(-180:90:180);
ylabel('arg w_{B,n} (deg)'); xlabel('\theta_B (deg)'); styleAx(ax2);
savePng(f, 'q3_weights_B');

%% Q4 + Q5: gain at port 6
[Gmax, iMax] = max(G6B);
fprintf('Q4: max G6,B = %.2f dB at theta_B = %.2f deg\n', dB(Gmax), thetaB(iMax));
fprintf('Q5: change in G6,B: %+.2f .. %+.2f dB\n', min(deltaG), max(deltaG));
fprintf('Q5: leakage of A:   %.1f .. %.1f dB\n', dB(min(G6A_uni)), dB(max(G6A_uni)));

f1 = figure('Position', [100 100 700 400]); hold on;
plot(thetaB, dB(G6B),     '-',  'SeriesIndex', 2, 'LineWidth', 2);
plot(thetaB, dB(G6B_uni), '--', 'SeriesIndex', 5, 'LineWidth', 2);
plot(thetaB, dB(G6A_uni), '-',  'SeriesIndex', 1, 'LineWidth', 2);
yline(dB(N), '-.k', 'LineWidth', 1.2);
xline(thetaA, '--k', 'LineWidth', 1.2);
ylim([-40 10]); styleAx(gca);
xlabel('\theta_B (deg)'); ylabel('Gain at port 6 (dB)'); title('Gain at port 6');
legend('B, iso: |w_B^H a(\theta_B)|^2', 'B, iso, uniform: |w_{uni}^H a(\theta_B)|^2', ...
    'A leakage, iso, uniform: |w_{uni}^H a(\theta_A)|^2', ...
    sprintf('10log_{10}N = %.2f dB', dB(N)), sprintf('\\theta_A = %g^\\circ', thetaA), ...
    'Location', 'southeast');
savePng(f1, 'q4_q5_port6_gain');

f2 = figure('Position', [100 100 700 200]); hold on;
plot(thetaB, deltaG, '-', 'SeriesIndex', 5, 'LineWidth', 2);
xline(thetaA, '--k', 'LineWidth', 1.2);
styleAx(gca);
xlabel('\theta_B (deg)'); ylabel('\DeltaG_{6,B} (dB)');
title('Change in gain of B: uniform - null on A');
savePng(f2, 'q5_delta_gain');

%% Q6: prints
fprintf('Length = %.3f mm (%.3f lambda0), Width = %.3f mm\n', ...
    1e3*ant.Length, ant.Length/lambda0, 1e3*ant.Width);
fprintf('Z(f0) = %.2f %+.4fj ohm\n', real(dipoleZin), imag(dipoleZin));
fprintf('Element gain in xz-plane: %.3f .. %.3f dBi (towards A: %.3f dBi)\n', ...
    min(GeB_dB), max(GeB_dB), GeA_dB);
fprintf('max G6,A (isotropic): %.1f dB\n', dB(max(G6A)));

%% Q6: dipole plots
q6f1 = figure; pattern(ant, f0);
savePng(q6f1, 'q6_dipole_3d');
q6f2 = figure; patternElevation(ant, f0, 0);           % azimuth 0 = xz-plane
q6pp = polarpattern('gco');                            % the polar plot in the current figure
q6pp.MagnitudeLim = [1.5 2.5];
savePng(q6f2, 'q6_dipole_xz_cut');
q6f3 = figure('Position', [100 100 700 400]); impedance(ant, 8e9:10e6:10e9);
savePng(q6f3, 'q6_dipole_impedance');

%% Q6: port 5
q6f4 = figure('Position', [100 100 700 400]); hold on;
plot(thetaB, G5A_dip_dB, '--', 'SeriesIndex', 1, 'LineWidth', 2);
plot(thetaB, dB(G5A) * ones(1, M),     '-',  'SeriesIndex', 1, 'LineWidth', 2);
plot(thetaB, G5B_dip_dB, '--', 'SeriesIndex', 2, 'LineWidth', 2);
plot(thetaB, dB(G5B),     '-',  'SeriesIndex', 2, 'LineWidth', 2);
xline(thetaA, '--k', 'LineWidth', 1.2);
ylim([-40 12]); styleAx(gca);
xlabel('\theta_B (deg)'); ylabel('G_5 (dB)'); title('Gain at port 5');
legend('A, no coupling: G_e|w_A^H a(\theta_A)|^2', 'A, iso: |w_A^H a(\theta_A)|^2', ...
    'B, no coupling: G_e|w_A^H a(\theta_B)|^2', 'B, iso: |w_A^H a(\theta_B)|^2', ...
    sprintf('\\theta_A = %g^\\circ', thetaA), 'Location', 'southeast');
savePng(q6f4, 'q6_port5_gain');

%% Q6: port 6
q6f5 = figure('Position', [100 100 700 400]); hold on;
plot(thetaB, G6B_dip_dB, '--', 'SeriesIndex', 2, 'LineWidth', 2);
plot(thetaB, dB(G6B),     '-',  'SeriesIndex', 2, 'LineWidth', 2);
xline(thetaA, '--k', 'LineWidth', 1.2);
ylim([-40 12]); styleAx(gca);
xlabel('\theta_B (deg)'); ylabel('G_{6,B} (dB)'); title('Gain at port 6');
legend('B, no coupling: G_e|w_B^H a(\theta_B)|^2', 'B, iso: |w_B^H a(\theta_B)|^2', ...
    sprintf('\\theta_A = %g^\\circ', thetaA), 'Location', 'southeast');
savePng(q6f5, 'q6_port6_gain');

%% Q6: change in gain
q6f6 = figure('Position', [100 100 700 400]); hold on;
plot(thetaB, deltaG5A_dip, '-',  'SeriesIndex', 1, 'LineWidth', 3);     % the three curves coincide:
plot(thetaB, deltaG5B_dip, '--', 'SeriesIndex', 2, 'LineWidth', 2);     % different colour and dash
plot(thetaB, deltaG6B_dip, ':',  'SeriesIndex', 4, 'LineWidth', 2.5);   % so all three stay visible
xline(thetaA, '--k', 'LineWidth', 1.2);
ylim([0 4]); styleAx(gca);
xlabel('\theta_B (deg)'); ylabel('\DeltaG (dB)');
title('Change in gain: no coupling - iso');
legend('A at port 5', 'B at port 5', 'B at port 6', ...
    sprintf('\\theta_A = %g^\\circ', thetaA), 'Location', 'southeast');
savePng(q6f6, 'q6_delta_gain');

%% Q7: prints
fprintf('array: %d elements, spacing %.3f mm (d = %.3f mm), dipole length %.3f mm\n', ...
    arr.NumElements, 1e3*arr.ElementSpacing, 1e3*d, 1e3*ant.Length);
assert(arr.NumElements == N && abs(arr.ElementSpacing - d) < 1e-5, 'array does not match array_setup');

%% Q7: embedded element patterns
q7f1 = figure('Position', [100 100 700 400]); hold on;
for i = 1:N
    plot(thetaB_full, GeFull_dB(i, :), 'SeriesIndex', i, 'LineWidth', 2, ...
        'DisplayName', sprintf('element %d', i));
end
plot(thetaB_full, GisoFull_dB, '--k', 'LineWidth', 2, 'DisplayName', 'isolated dipole');
xline(thetaA, '--k', 'LineWidth', 1.2, 'DisplayName', sprintf('\\theta_A = %g^\\circ', thetaA));
styleAx(gca);
set(gca, 'XLim', [-90 90], 'XTick', -90:15:90);
yl = ylim;
band = patch([0 90 90 0], [yl(1) yl(1) yl(2) yl(2)], [0.5 0.5 0.5], ...
    'FaceAlpha', 0.12, 'EdgeColor', 'none', 'DisplayName', 'satellite range');
uistack(band, 'bottom'); ylim(yl);
xlabel('\theta (deg)'); ylabel('Gain (dBi)'); title('Embedded element patterns in the xz-plane');
legend('Location', 'south', 'NumColumns', 2);
savePng(q7f1, 'q7_element_patterns');

%% Q7: port 5
q7f2 = figure('Position', [100 100 700 400]); hold on;
plot(thetaB, dB(G5A_emb),    '-',  'SeriesIndex', 1, 'LineWidth', 2);
plot(thetaB, G5A_dip_dB,     '--', 'SeriesIndex', 1, 'LineWidth', 2);
plot(thetaB, dB(G5B_emb),    '-',  'SeriesIndex', 2, 'LineWidth', 2);
plot(thetaB, G5B_dip_dB,     '--', 'SeriesIndex', 2, 'LineWidth', 2);
xline(thetaA, '--k', 'LineWidth', 1.2);
ylim([-40 12]); styleAx(gca);
xlabel('\theta_B (deg)'); ylabel('G_5 (dB)'); title('Gain at port 5');
legend('A, coupling: |w_A^H g(\theta_A)|^2', 'A, no coupling: G_e|w_A^H a(\theta_A)|^2', ...
    'B, coupling: |w_A^H g(\theta_B)|^2', 'B, no coupling: G_e|w_A^H a(\theta_B)|^2', ...
    sprintf('\\theta_A = %g^\\circ', thetaA), 'Location', 'southeast');
savePng(q7f2, 'q7_port5_gain');

%% Q7: port 6
q7f3 = figure('Position', [100 100 700 400]); hold on;
plot(thetaB, dB(G6B_emb), '-',  'SeriesIndex', 2, 'LineWidth', 2);
plot(thetaB, G6B_dip_dB,  '--', 'SeriesIndex', 2, 'LineWidth', 2);
plot(thetaB, dB(G6A_emb), '-',  'SeriesIndex', 1, 'LineWidth', 2);
xline(thetaA, '--k', 'LineWidth', 1.2);
ylim([-60 12]); styleAx(gca);
xlabel('\theta_B (deg)'); ylabel('Gain at port 6 (dB)'); title('Gain at port 6');
legend('B, coupling: |w_B^H g(\theta_B)|^2', 'B, no coupling: G_e|w_B^H a(\theta_B)|^2', ...
    'A leakage, coupling: |w_B^H g(\theta_A)|^2', ...
    sprintf('\\theta_A = %g^\\circ', thetaA), 'Location', 'southeast');
savePng(q7f3, 'q7_port6_gain');

%% Q6 + Q7: port 5 (isotropic, dipoles without coupling, dipoles with coupling)
q67f1 = figure('Position', [100 100 700 400]); hold on;
plot(thetaB, dB(G5A) * ones(1, M), '-',  'SeriesIndex', 1, 'LineWidth', 2);
plot(thetaB, G5A_dip_dB,           '--', 'SeriesIndex', 1, 'LineWidth', 2);
plot(thetaB, dB(G5A_emb),          ':',  'SeriesIndex', 1, 'LineWidth', 2.5);
plot(thetaB, dB(G5B),              '-',  'SeriesIndex', 2, 'LineWidth', 2);
plot(thetaB, G5B_dip_dB,           '--', 'SeriesIndex', 2, 'LineWidth', 2);
plot(thetaB, dB(G5B_emb),          ':',  'SeriesIndex', 2, 'LineWidth', 2.5);
xline(thetaA, '--k', 'LineWidth', 1.2);
ylim([-40 12]); styleAx(gca);
xlabel('\theta_B (deg)'); ylabel('G_5 (dB)'); title('Gain at port 5');
legend('A, iso: |w_A^H a(\theta_A)|^2', 'A, no coupling: G_e|w_A^H a(\theta_A)|^2', ...
    'A, coupling: |w_A^H g(\theta_A)|^2', ...
    'B, iso: |w_A^H a(\theta_B)|^2', 'B, no coupling: G_e|w_A^H a(\theta_B)|^2', ...
    'B, coupling: |w_A^H g(\theta_B)|^2', ...
    sprintf('\\theta_A = %g^\\circ', thetaA), 'Location', 'southeast');
savePng(q67f1, 'q6_q7_port5_gain');

%% Q6 + Q7: port 6 (isotropic, dipoles without coupling, dipoles with coupling)
q67f2 = figure('Position', [100 100 700 400]); hold on;
plot(thetaB, dB(G6B),      '-',  'SeriesIndex', 2, 'LineWidth', 2);
plot(thetaB, G6B_dip_dB,   '--', 'SeriesIndex', 2, 'LineWidth', 2);
plot(thetaB, dB(G6B_emb),  ':',  'SeriesIndex', 2, 'LineWidth', 2.5);
plot(thetaB, dB(G6A_emb),  '-',  'SeriesIndex', 1, 'LineWidth', 2);
xline(thetaA, '--k', 'LineWidth', 1.2);
ylim([-60 12]); styleAx(gca);
xlabel('\theta_B (deg)'); ylabel('Gain at port 6 (dB)'); title('Gain at port 6');
legend('B, iso: |w_B^H a(\theta_B)|^2', 'B, no coupling: G_e|w_B^H a(\theta_B)|^2', ...
    'B, coupling: |w_B^H g(\theta_B)|^2', ...
    'A leakage, coupling: |w_B^H g(\theta_A)|^2', ...
    sprintf('\\theta_A = %g^\\circ', thetaA), 'Location', 'southeast');
savePng(q67f2, 'q6_q7_port6_gain');

%% Q7: change in gain with respect to isotropic elements
q7f4 = figure('Position', [100 100 700 300]); hold on;
plot(thetaB, deltaG5A_emb, '-',  'SeriesIndex', 1, 'LineWidth', 3);
plot(thetaB, deltaG5B_emb, '-', 'SeriesIndex', 2, 'LineWidth', 2);
plot(thetaB, deltaG6B_emb, '-',  'SeriesIndex', 4, 'LineWidth', 2.5);
plot(thetaB, GeB_dB,       '-.k', 'LineWidth', 1.2);
xline(thetaA, '--k', 'LineWidth', 1.2);
ylim([-0.5 6]); styleAx(gca);
xlabel('\theta_B (deg)'); ylabel('\DeltaG (dB)');
title('Change in gain: coupling - iso');
legend('A at port 5', 'B at port 5', 'B at port 6', 'no coupling: G_e', ...
    sprintf('\\theta_A = %g^\\circ', thetaA), 'Location', 'northeast', 'NumColumns', 2);
savePng(q7f4, 'q7_delta_gain');