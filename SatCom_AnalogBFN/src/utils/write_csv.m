function write_csv(file, header, data, fmt)
%WRITE_CSV  Write a numeric matrix with a header line (MATLAB + Octave safe).
%
%   WRITE_CSV(file, header, data)        header: cell array of column names
%   WRITE_CSV(file, header, data, fmt)   fmt: printf format per value ('%.6g')

    if nargin < 4, fmt = '%.6g'; end
    if size(data, 2) ~= numel(header)
        error('write_csv:size', '%d header names for %d columns.', numel(header), size(data, 2));
    end
    fid = fopen(file, 'w');
    if fid < 0
        error('write_csv:open', 'Cannot open %s for writing.', file);
    end
    fprintf(fid, '%s\n', strjoin(header, ','));
    line = [strjoin(repmat({fmt}, 1, numel(header)), ','), '\n'];
    fprintf(fid, line, data.');
    fclose(fid);
end
