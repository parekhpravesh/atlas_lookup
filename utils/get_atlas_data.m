function [atlas_header, atlas_path, atlas_name, atlas_data, atlas_xyz, ...
    all_labels, num_labels] = get_atlas_data(path_to_atlas)
% Function that returns information about an atlas
%% Input
% path_to_atlas:    The atlas file with path for which information is to be
%                   returned
% 
%% Outputs:
% atlas_header:     The header which can be used for writing a new volume
% atlas_path:       The full path to the atlas
% atlas_name:       The name of the atlas file
% atlas_data:       The values/intensities at each voxel
% atlas_xyz:        The xyz coordinates for each voxel
% all_labels:       The list of unique intensities/labels
% num_labels:       The number of unique intensities/labels
% 
%% Notes
% If a 4D volume is input, the first volume is used for finding path and
% name information
% 
%% Author(s)
% Parekh, Pravesh
% July 24, 2017
% MBIAL

%% Get information
if exist(path_to_atlas, 'file')
    atlas_header = spm_vol(path_to_atlas);
    
    % Check if 4D volume
    if size(atlas_header,1) > 1
        [atlas_path, atlas_name] = fileparts(atlas_header(1).fname);
    else
        [atlas_path, atlas_name] = fileparts(atlas_header.fname);
    end
    
    [atlas_data, atlas_xyz] = spm_read_vols(atlas_header);
    atlas_xyz = atlas_xyz(1:3,:)';
    all_labels = unique(atlas_data(:));
    num_labels = length(all_labels);
else
    error([path_to_atlas, ' not found']);
end