function [out_path] = get_file_path(in_path)
%get_file_path function to list all files (i.e., full path to file) in the directory
%
%   input:
%      in_path     directory to obtain all file paths
%
%   output:
%      out_path    list of all files (i.e., file paths) within directory
%

    
    out_path = dir(in_path)';
    out_path(strncmp({out_path.name}, '.', 1)) = []; %remove files and dir starting with '.'
    out_path = strcat({out_path.folder},{'/'},{out_path.name})';
    out_path = correct_path(out_path);
    

   if size(out_path, 1) == 0
       out_path = cell(1,1);
   end
end
