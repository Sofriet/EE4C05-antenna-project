function cfg = prepare_output(cfg)
%PREPARE_OUTPUT  Create the result folders and load the plot style.
%   (No global graphics defaults are changed: every figure sets its own style.)

    cfg.figDir   = fullfile(cfg.outDir, 'figures');
    cfg.tabDir   = fullfile(cfg.outDir, 'tables');
    cfg.isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
    cfg.style    = plot_style();

    dirs = {cfg.outDir, cfg.figDir, cfg.tabDir};
    for k = 1:numel(dirs)
        if exist(dirs{k}, 'dir') ~= 7
            mkdir(dirs{k});
        end
    end
end
