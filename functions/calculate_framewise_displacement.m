function [fd] = calculate_framewise_displacement(in_file, out_file, radius,overwrite)
% calculate_framewise_displacement calculates and saves out framewise
%displacement
%  Framewise displacement is calculated by:
%  1. converting radians to mm
%  2. obtaining the lag (first temporal derivative)
%  3. obtain absolute values
%  4. sum values
%
% input:
%   6 motion parameters text files of translation in the x, y, and
%   z-direction and rotation in the x, y, and z-direction
% output:
%   text file of 1 column of FD values for each volume

% ensure in_file exists
if ~exist(in_file, 'file')
    error_msg = sprintf('%s file does not exist', in_file);
    error(error_msg);
end

% ensure out_file doesn't already exist
if exist(out_file, 'file') && any(contains(overwrite,'f','IgnoreCase',true))
    error_msg = sprintf('%s file already exist', out_file);
    error(error_msg);
end

% read motion text
x = load(in_file);

% convert radians to mm
x(:,4:6) = x(:,4:6) * (radius);

% calculate temporal derivatives
x_td = [zeros(1, size(x, 2)); diff(x)];

% calculate frame-wise displacement
fd = sum(abs(x_td), 2);

% write out csv file
csvwrite(out_file, fd);

end
