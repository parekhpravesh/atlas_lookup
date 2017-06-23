function merge_rois(atlas_file, save_dir, roi_idx, vol_name)
% Function to merge a set of roi_idx
% It is possible to specify roi_idx as 'L', 'R', or 'M' in which cases all
% left sided regions, right sided regions, or midline regions respectively
% will be merged together; do note that x>0 is right, x=0 is midline, and
% x<0 is left. This might not correspond to the atlas defaults. Use this
% parameter with caution
% vol_name is the filename with which the output volume is written
% 
% Parekh, Pravesh
% June 24,2017
% MBIAL

% Load atlas file
atlas_vol = spm_vol(atlas_file);
[atlas_data, atlas_xyz] = spm_read_vols(atlas_vol);

% Get number of ROIs defined in the atlas
list_rois = unique(nonzeros(atlas_data(:)));

% Check if the provided roi_idx actually exist in the atlas
if isnumeric(roi_idx)
    num_rois = length(roi_idx);
    chk = setdiff(roi_idx, list_rois);
    if ~isempty(chk)
        error('One or more roi_idx input does not exist');
    end
end

binary_mask_data = zeros(size(atlas_data));

% Merge regions
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
else
    % Get atlas dimensions and then reorganize atlas_data and atlas_xyz
    atlas_data_dims = size(atlas_data);
    atlas_data = atlas_data(:)~=0;
    atlas_xyz = atlas_xyz(1:3,:)';
    
    switch(roi_idx)
        case 'L'
            all_x = (atlas_xyz(:,1)<0);
        case 'R'
            all_x = (atlas_xyz(:,1)>0);
        case 'M'
            all_x = (atlas_xyz(:,1)==0);
    end
    if ~isempty(all_x)
        binary_mask_data = reshape(atlas_data.*all_x, atlas_data_dims);
    else
        warning('Possibly empty file being written!');
    end
end

binary_mask_header = atlas_vol;
binary_mask_header.fname = vol_name;
cd(save_dir);

% Save volume
spm_write_vol(binary_mask_header, binary_mask_data);