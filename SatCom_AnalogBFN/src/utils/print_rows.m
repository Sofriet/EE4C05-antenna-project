function print_rows(cfg, thB, rows, names, fmt)
%PRINT_ROWS  Print selected thetaB rows (cfg.thetaB_table) of a few quantities.
%
%   PRINT_ROWS(cfg, thetaB, rows, names)   rows: K-by-M, names: 1-by-K cell

    if nargin < 5, fmt = '%11.2f'; end
    fprintf('  %8s', 'thetaB');
    fprintf('%11s', names{:});
    fprintf('\n');
    for t = cfg.thetaB_table
        [d, i] = min(abs(thB - t));
        if d > 1e-6, continue; end
        fprintf('  %8.1f', thB(i));
        fprintf(fmt, rows(:, i));
        fprintf('\n');
    end
end
