function atlas_to_roi(atlas_file, save_dir, roi_idx, roi_labels)
% Function to convert an atlas file to binzarized roi files 
% roi_labels is a text file having rows of names for the rois to be saved
% Parekh, Pravesh
% June 24, 2017
% MBIAL

% Check number of arguments and figure out defaults
if nargin == 1
    roi_idx = 'all';
    save_dir = pwd;
else
    if nargin == 2
        roi_idx = 'all';
    end
end     

% Load atlas file
atlas_vol = spm_vol(atlas_file);
atlas_data = spm_read_vols(atlas_vol);

% Get number of ROIs defined in the atlas
list_rois = unique(nonzeros(atlas_data(:)));

% Check if the provided roi_idx actually exist in the atlas
if isnumeric(roi_idx)
    num_rois = length(roi_idx);
    chk = setdiff(roi_idx, list_rois);
    if ~isempty(chk)
        error('One or more roi_idx input does not exist');
    end
else
    roi_idx = list_rois;
    num_rois = length(list_rois);
end

% Check if a label file is supplied and if it has the correct number of
% file names in it
if exist('roi_labels','var')
    fid = fopen(roi_labels, 'r');
    data = textscan(fid, '%s');
    
    if size(data{1},1) ~= num_rois
        error(['One or more filenames missing in ', roi_labels , ' file']);
    else
        
        % Checking if the filenames in the text file have extension or not
        [~, ~, ext] = fileparts(data{1}{1});
        if isempty(ext)
            
            % Add .nii extension to all filenames
            for roi = 1:num_rois
                data{1,1}{roi} = [data{1,1}{roi}, '.nii'];
            end
        end
    end
else
    % Create a list of filenames for the ROIs
    for roi = 1:num_rois
        data{1,1}{roi} = ['ROI_', sprintf('%03d', roi), '.nii'];
    end
end

% Go to save directory and create a folder with atlas name
cd(save_dir);
[~,save_dir_name,~] = fileparts(atlas_vol.fname);
if ~exist(save_dir_name, 'dir')
    mkdir(save_dir_name);
end
cd(save_dir_name);

% Loop over all ROI indices and save them as files
for roi = 1:num_rois
	
    % Create a 3D matrix of dimensions equal to the atlas file
    binary_mask_data = zeros(size(atlas_data));
    binary_mask_header = atlas_vol;
    
    % All corresponding entries to the roi_idx = 1
    binary_mask_data(atlas_data == roi_idx(roi)) = 1;
    
    % Edit header of nifti
    binary_mask_header.fname = data{1,1}{roi};
    
    % Save volume
    spm_write_vol(binary_mask_header, binary_mask_data);
end