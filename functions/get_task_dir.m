function [task_dir_list, dj_dir_list, nback_dir_list] = get_task_dir(subj_dir)
%get_task_dir obtains the directories of all the functional task runs
%
%   input:
%       subj_dir          subject directory
%
%   output:
%       task_dir_list     all available functional task directories
%       dj_dir_list       all available functional dj task directories
%       nback_dir_list    all available functional nback task directories
%

    dj_dir_list = {}; nback_dir_list = {};
    dj_dir_list = get_file_path([subj_dir '/DJ*']);
    nback_dir_list = get_file_path([subj_dir '/Nback*']);
    tmpdj = isempty(dj_dir_list{1,1});
    tmpnback = isempty(nback_dir_list{1,1});
    if ~tmpdj && ~tmpnback
        task_dir_list = [dj_dir_list; nback_dir_list];
    elseif ~tmpdj
        task_dir_list = dj_dir_list;
    elseif ~tmpnback
        task_dir_list = nback_dir_list;
    elseif tmpdj && tmpnback
        task_dir_list = {};
    end        
end