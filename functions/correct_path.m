function [out_path] = correct_path(in_path)
% correct_path function to correct slashes in path
%   detect if a computer is running on mac or linux,
%   if so, replaces back slashes with forward slashes
%   else, replaces forward slashes with back slashes
%
% input:
%   in_path      path to be corrected
%
% output:
%   out_path     corrected input path
%
if computer == "GLNXA64" || computer == "MACI64"
    out_path = strrep(in_path, '\', '/');
else
    out_path = strrep(in_path, '/', '\');
end
