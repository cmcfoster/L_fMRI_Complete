function [y] = create_parameter_derivatives_polynomial(in_file, temporal_derivatives, poly, out_file, overwrite)
%create_parameter_derivatives_polynomial create parameters temporal derivatives and polynomial
%   applys each temporal derivatives (lag/diff) column-wise then applys each polynomial to each column
%
%   input:
%      in_file                  full path to input file
%      temporal_derivatives     temporal derivative (lag/diff) to apply
%      poly                     polynomial to apply
%      out_file                 full path to output file
%      overwrite                overwrite output file (default: F)
%   output:
%      y                        combined matrix of original matrix, its derivatives, and its polynomials
%

% set overwrite default
if nargin <= 4
    overwrite = false;
end

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

% read file
x = load(in_file);

% calculate temporal derivative
x_td = x;
for i = 1:temporal_derivatives
    temp_x_td = [zeros(i, size(x, 2)); diff(x, i, 1)];
    x_td = [x_td temp_x_td];
end

% mean center each column
x_td = detrend(x_td,0);

% calculate polynomial
x_poly = [];
for i = 1:poly
    temp_x_poly = x_td.^i;
    x_poly = [x_poly temp_x_poly];
end

% save file
y = x_poly;
csvwrite(out_file, y);

end
