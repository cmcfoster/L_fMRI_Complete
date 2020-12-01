function [dummy_number,dummy_list] = create_dummy_motion_regressors(m_paths,GS_perc_num,Motion_from_origin,FD_num,GS_std_num,radius)
%create_dummy_motion_regressors Create dummy variables for images that are
%associated with greater than Nmm (typically 2)of movement or N% global
%signal change (typically 3%)

% GS_perc_num (Global Signal change in percent) maybe .75 as a cutoff
% Motion_from_origin (Motion on any axis in mm from starting volume for that run) maybe 2mm as cutoff
% FD_num (Framewise Displacement) Powers et al uses .5 but maybe 1 for task
% GS_std_num (Global signal standard deviation from mean by frame) maybe 3 as a cutoff

% FD import
fd_dat = readmatrix(char(m_paths(contains(m_paths,'fd'))));

rp_dat = readmatrix(char(m_paths(contains(m_paths,'rp_vol_0000.txt'))));
rp_dat_in_mm = [rp_dat(:,1:3) (rp_dat(:,4:6) * (radius))];
rp_dat_in_mm = abs(rp_dat_in_mm);

% check for motion on any axis greater than 2mm from origin (Art Repair Style)
for i = 1:size(rp_dat_in_mm)
    if any(rp_dat_in_mm(i,:) > Motion_from_origin)
        rp_flag(i,1) = 1;
    else
        rp_flag(i,1) = 0;
    end
end

wb_list = m_paths(contains(m_paths,'wb'));

gs_dat = readmatrix(char(wb_list(~contains(wb_list,{'gwvol','td1'}))));
gs_dat(:,1) = [];
mean_gs = mean(gs_dat(:));
sd_gs = std(gs_dat(:));

gs_dat(1,2) = 0;
% percent global signal change
for i = 2:size(gs_dat,1)
    gs_dat(i,2) = ((gs_dat(i,1)-gs_dat(i-1,1))/mean_gs)*100;
end

% standard deviation from mean global signal (Art Repair style)
for i = 1:size(gs_dat,1)
    gs_dat(i,3) = (gs_dat(i,1)-mean_gs)/sd_gs;
end

% percent sig change, global signal std, fd, rp_in_mm, rp_flag
gs_fd = [abs(gs_dat(:,2)),abs(gs_dat(:,3)),fd_dat(:),rp_flag(:)];

dummy_number = 0;

if size(fd_dat,1) == size(gs_dat,1)
    for i = 1 : size(fd_dat,1)
        if gs_fd(i,1) > GS_perc_num || ...
                gs_fd(i,2) > GS_std_num || ...
                gs_fd(i,3) > FD_num || ...
                gs_fd(i,4) == 1
            dummy_reg(i,1) = dummy_number + 1;
            dummy_number = dummy_number + 1;
        else
            dummy_reg(i,1) = 0;
        end
    end
else
    error('Size of FD and GS not the same');
end

if any(dummy_reg)
    dummy_list = dummyvar(categorical(dummy_reg));
    dummy_list(:,1) = [];
else
    dummy_list = [];
end

end