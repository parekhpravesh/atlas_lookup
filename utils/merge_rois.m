function merge_rois(path_to_atlas, roi_idx)
% Function to merge a set of ROIs into a binary mask
%% Inputs:
% path_to_atlas:        full path to atlas file
% roi_idx:              indices to be merged (see below)
% 
%% Output:
% A binary mask containing "1"s for the coordinates covered by roi_idx If
% roi_idx is a special case, output file name is suffixed
% "_bin_merged_<roi_idx>", otherwise is suffixed "bin_merged_idx"
% 
%% The following values for roi_idx are supported:
% a vector of numbers corresponding to indices in the atlas_file
% 'L':                  left            (x< 0)
% 'R':                  right           (x> 0)
% 'M':                  midline         (x= 0)
% 'LM':                 left+midline    (x<=0)
% 'RM':                 right+midline   (x>=0)
% 'LR':                 left+midline    (x<0 AND x>0 i.e. x~=0)
% 'LRM':                the entire brain (left+right+midline)
% 
%% Author(s)
% Parekh, Pravesh
% June 24,2017
% MBIAL

%% Read atlas data, check inputs, and initialize
[atlas_header, atlas_path, atlas_name, atlas_data, atlas_xyz, ...
    all_labels, ~] = get_atlas_data(path_to_atlas);

% Check if the provided roi_idx actually exist in the atlas
if isnumeric(roi_idx)
    num_rois = length(roi_idx);
    chk = setdiff(roi_idx, all_labels);
    if ~isempty(chk)
        error('One or more roi_idx input does not exist');
    end
end

% Initialize
binary_mask_data = zeros(size(atlas_data));

%% Merge regions
if isnumeric(roi_idx)
    tmp = zeros(size(atlas_data));
    
    % Check if the rois have overlap and warn the user
    for roi = 1:num_rois
        tmp = tmp + (atlas_data == roi_idx(roi));
    end
    chk = nonzeros(tmp>1);
    if ~isempty(chk)
        warning('Regions overlap with each other!');
    end
    for roi = 1:num_rois
        binary_mask_data(atlas_data == roi_idx(roi)) = 1;
    end
    name = fullfile(atlas_path, [atlas_name, '_bin_merged_idx.nii']);
else
    % Get atlas dimensions and reorganize atlas_data
    atlas_data_dims = size(atlas_data);
    atlas_data      = atlas_data(:)~=0;
    
    switch(roi_idx)
        case 'L'
            all_x = (atlas_xyz(:,1)<0);
            name  = fullfile(atlas_path, [atlas_name, '_bin_merged_L.nii']);
        case 'R'
            all_x = (atlas_xyz(:,1)>0);
            name  = fullfile(atlas_path, [atlas_name, '_bin_merged_R.nii']);
        case 'M'
            all_x = (atlas_xyz(:,1)==0);
            name  = fullfile(atlas_path, [atlas_name, '_bin_merged_M.nii']);
        case 'LM'
            all_x = (atlas_xyz(:,1)<=0);
            name  = fullfile(atlas_path, [atlas_name, '_bin_merged_LM.nii']);
        case 'RM'
            all_x = (atlas_xyz(:,1)>=0);
            name  = fullfile(atlas_path, [atlas_name, '_bin_merged_RM.nii']);
        case 'LR'
            all_x = (atlas_xyz(:,1)~=0);
            name  = fullfile(atlas_path, [atlas_name, '_bin_merged_LR.nii']);
        case 'LRM'
            all_x = ones(length(atlas_xyz(:,1)),1);
            name  = fullfile(atlas_path, [atlas_name, '_bin_merged_LRM.nii']);
        otherwise
            error('Unable to process roi_idx');
    end
    if ~isempty(all_x)
        binary_mask_data = reshape(atlas_data.*all_x, atlas_data_dims);
    else
        warning('Possibly empty file being written!');
    end
end

%% Modify header and write
atlas_header.fname = name;
spm_write_vol(atlas_header, binary_mask_data);