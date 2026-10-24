%% Shared parameters and helpers
% theta is measured from the z-axis towards +x.

c0      = physconst('LightSpeed');
f0      = 9e9;                  % group 9
lambda0 = c0/f0;
N       = 4;
d       = lambda0/2;
k       = 2*pi/lambda0;
thetaA  = 7;                    % deg, student number 5840597
n       = (0:N-1).';

steer   = @(th) exp(1j*k*d*n*sind(th));    % th scalar -> N x 1, row of M angles -> N x M
dB      = @(G) 10*log10(G);
styleAx = @(ax) set(ax, 'XLim', [0 90], 'XTick', 0:10:90, 'XGrid', 'on', 'YGrid', 'on', 'Box', 'on');

figDir = fullfile(fileparts(mfilename('fullpath')), '..', 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end
savePng = @(f, name) exportgraphics(f, fullfile(figDir, [name '.png']), 'Resolution', 600);
