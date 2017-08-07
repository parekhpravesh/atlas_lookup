function msg = check_atlas_midline(path_to_atlas)
% Function to check if the atlas midline is defined with left or right
%% Input:
% path_to_atlas:    Full path to SPM readable atlas file
%
%% Output:
% msg:              Message stating how midline is defined
%
%% Author(s)
% Parekh, Pravesh
% July 7, 2017
% MBIAL

%%
% Read atlas file
[~, ~, atlas_name, atlas_data, atlas_xyz, ~, ~] = get_atlas_data(path_to_atlas);
all_atlas_data = [atlas_xyz, atlas_data(:)];
 
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
    msg = [atlas_name, ': Midline has both left and right definition'];
else
    if isempty(intersect(uniques_midline, uniques_left))
        msg = [atlas_name, ': Midline is classified with right'];
    else
        if isempty(intersect(uniques_midline, uniques_right))
            msg = [atlas_name, ': Midline is classified with left'];
        end
    end
end