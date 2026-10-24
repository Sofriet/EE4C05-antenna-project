%% MAIN  SatCom receiver - analog beamforming network (Student #2, Q1-Q5)
%
%  Runs the analog part of the EE4C05 track assignment in one go:
%     Q1  phase shifters phi1, phi2, phi3 of the A ("blue") network
%     Q2  gain of sources A and B at port 5 versus thetaB
%     Q3  phi4, phi5 and the ratio of the variable coupler (B, "red" network)
%     Q4  gain of source B at port 6 versus thetaB
%     Q5  how Q4 changes with 2-bit phase shifters
%
%  Output:  results/figures/*.png   all plots (named after the question)
%           results/tables/*.csv    phase values, coupler ratio, gains
%           results/summary.txt     every number used in the presentation
%           results/results.mat     cfg + all results
%
%  Usage:   run this file; all settings are in config.m (thetaA = 8 deg).
%  Needs:   MATLAB R2018b or newer, no toolboxes.

clear; close all; clc;

rootDir = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(rootDir, 'src')), fullfile(rootDir, 'questions'));

cfg = config();
cfg = prepare_output(cfg);          % result folders, colours, plot defaults
print_banner(cfg);

res    = struct();
res.Q1 = q1_A_network(cfg);
res.Q2 = q2_gain_port5(cfg, res.Q1);
res.Q3 = q3_B_network(cfg, res.Q1);
res.Q4 = q4_gain_port6(cfg, res.Q1, res.Q3);
res.Q5 = q5_two_bit(cfg, res.Q1, res.Q3, res.Q4);

write_summary(cfg, res);
save(fullfile(cfg.outDir, 'results.mat'), '-v7', 'cfg', 'res');
fprintf('\nDone. Figures, tables and summary are in:\n  %s\n', cfg.outDir);
