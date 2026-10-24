function save_figure(cfg, fig, baseName)
%SAVE_FIGURE  Export a figure to results/figures in the formats of cfg.figFormats.
    if ~cfg.saveFigures, return; end
    base = fullfile(cfg.figDir, baseName);
    drawnow;
    for k = 1:numel(cfg.figFormats)
        switch lower(cfg.figFormats{k})
            case 'png'
                print(fig, [base '.png'], '-dpng', sprintf('-r%d', cfg.dpi));
            case 'pdf'
                set(fig, 'PaperUnits', 'inches');
                pp = get(fig, 'PaperPosition');
                set(fig, 'PaperSize', pp(3:4));
                print(fig, [base '.pdf'], '-dpdf');
            case 'fig'
                if ~cfg.isOctave
                    savefig(fig, [base '.fig']);
                end
            otherwise
                warning('save_figure:format', 'Unknown figure format "%s".', cfg.figFormats{k});
        end
    end
    fprintf('  figure  -> %s.%s\n', baseName, strjoin(cfg.figFormats, '/'));
end
