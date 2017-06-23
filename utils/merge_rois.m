function merge_rois(atlas_file, save_dir, roi_idx, vol_name)
% Function to merge a set of ROIs
% roi_idx can take the following values:
% a vector of numbers corresponding to indices in the atlas_file
% 'L':      left (x<0)
% 'R':      right (x>0)
% 'M':      midline (x=0)
% 'LM':     left+midline (x<=0)
% 'RM':     right+midline (x>=0)
% 'LR':     left+midline (x<0 AND x>0 i.e. x~=0)
% 'LRM':    the entire brain (left+right+midline)
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
        case 'LM'
            all_x = (atlas_xyz(:,1)<=0);
        case 'RM'
            all_x = (atlas_xyz(:,1)>=0);
        case 'LR'
            all_x = (atlas_xyz(:,1)~=0);
        case 'LRM'
            all_x = ones(length(atlas_xyz(:,1)),1);
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