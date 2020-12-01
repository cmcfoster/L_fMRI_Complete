function [basepath] = get_base_path()
  %getbasepath Find the basepath for your system
  if exist('/raid/data/shared/KK_KR_JLBS','dir')
      basepath = '/raid/data/shared/KK_KR_JLBS/';
  elseif exist('Z:/KK_KR_JLBS','dir')
      basepath = 'Z:/KK_KR_JLBS/';
  elseif exist('/Volumes/shared/KK_KR_JLBS','dir')
      basepath = '/Volumes/shared/KK_KR_JLBS/';
  else
      fprintf('no path to KK_KR_JLBS, please check that drive is mapped or that you are connected to server \n');
  end
end
