function msg = check_atlas_midline(atlas_name)
% Function to check if the atlas midline is defined with left or right
%% Input:
% atlas_name:       Full path to SPM readable atlas file
%
%% Output:
% check_msg:        Message stating how midline is defined
%
%% Author(s)
% Parekh, Pravesh
% July 7, 2017
% MBIAL

%%
% Read atlas and get xyz coordinates
if exist(atlas_name, 'file')
    [~,name,~] = fileparts(atlas_name);
    [atlas_data, atlas_xyz] = spm_read_vols(spm_vol(atlas_name));
    atlas_xyz = (atlas_xyz(1:3,:))';
    all_atlas_data = [atlas_xyz, atlas_data(:)];
else
    error('File not found');
end

% Get atlas data for midline
atlas_data_midline = all_atlas_data(all_atlas_data(:,1)==0, 4);
uniques_midline = unique(nonzeros(atlas_data_midline));

% Get atlas data for right side
atlas_data_right = all_atlas_data(all_atlas_data(:,1)>0, 4);
uniques_right = unique(nonzeros(atlas_data_right));

% Get atlas data for left side
atlas_data_left = all_atlas_data(all_atlas_data(:,1)<0, 4);
uniques_left = unique(nonzeros(atlas_data_left));

% Check how midline is defined
if ~isempty(intersect(uniques_midline, uniques_left)) && ~isempty(intersect(uniques_midline, uniques_right))
    msg = [name, ': Midline has both left and right definition'];
else
    if isempty(intersect(uniques_midline, uniques_left))
        msg = [name, ': Midline is classified with right'];
    else
        if isempty(intersect(uniques_midline, uniques_right))
            msg = [name, ': Midline is classified with left'];
        end
    end
end