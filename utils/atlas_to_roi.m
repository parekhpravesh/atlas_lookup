function atlas_to_roi(path_to_atlas, output_location, roi_idx, roi_labels)
% Function to convert an atlas file to binzarized roi files
%% Inputs:
% path_to_atlas:            full path to an atlas file
% output_location:          full path to where output ROIs will be saved
% roi_idx:                  indices which are to be converted to ROIs
%                           (optional)
% roi_labels:               text file having names which will be used to
%                           name the created ROI files (optional)
% 
%% Outputs:
% Each region indicated in the roi_idx list will be saved as a new biary
% ROI file
% 
% If roi_labels are provided, they will be used to name the ROIs, otherwise
% ROIs are written as "ROI_<indexvalue>.nii"
% 
%% Notes:
% roi_labels can be a text file organized in rows; each row can have a file
% name (with or without extension)
% 
% It is important to note that the ordering of file names in roi_labels is
% assumed to be in order of roi_idx
% 
% If roi_idx is not provided, then the ordering in roi_labels has to be the
% same as ascending order of all indices in the atlas file
% 
%% Defaults:
% roi_idx = 'all';
% 
%% The following values for roi_idx are allowed:
% 'all':                    each region is saved as a separate file
% 'left':                   all regions on the left side are saved as
%                           separate files (left includes midline)
% 'right':                  all regions on the right side are saved as
%                           separate files (does not include midline)
% a vector of numbers corresponding to the indices
% 
%% Author(s)
% Parekh, Pravesh
% June 24, 2017
% MBIAL

%% Evaluate input
if nargin < 2
    error('At least atlas file and output location are required');
else
    if nargin == 2
        roi_idx     = 'all';
        roi_labels  = 'default';
    else
        if nargin == 3
            if isempty(roi_idx)
                roi_idx = 'all';
            end
            roi_labels = 'default';
        else
            if isempty(roi_idx)
                roi_idx = 'all';
            end
            if isempty(roi_labels)
                roi_labels = 'default';
            end
        end
    end
end

%% Read atlas file
[atlas_header, ~, ~, atlas_data, atlas_xyz, ...
    all_labels, ~] = get_atlas_data(path_to_atlas);

%% Process roi_idx
if ~isnumeric(roi_idx)
    switch roi_idx
        case 'all'
            roi_idx = all_labels;
        case 'left'
            roi_idx = unique(atlas_data(atlas_xyz(:,1)<=0));
        case 'right'
            roi_idx = unique(atlas_data(atlas_xyz(:,1)>0));
        otherwise
            error('Unable to process roi_idx');
    end
else
    % Ensure that the indices exist in the atlas
    chk = setdiff(roi_idx, all_labels);
    if ~isempty(chk)
        error('One or more roi_idx input does not exist');
    end
end
% Remove zero from roi_idx list
roi_idx(roi_idx==0) = [];

%% Process roi_labels
if strcmpi(roi_labels, 'default')
    roi_labels = strcat({'ROI_'}, strtrim(num2str(roi_idx)), {'.nii'});
else
    % Ensure that text file is passed
    [~, ~, ext] = fileparts(roi_labels);
    if strcmp(ext, '.txt')
        fid  = fopen(roi_labels, 'r');
        data = textscan(fid, '%s');
        data = data{1};
        fclose(fid);
        % Ensure that correct number of entries are present
         if size(data,1) ~= length(roi_idx)
             error('Incorrect number of file names in labels file');
         else
             % Find if extension is present in the names provided
             tmp = strsplit(data{1}, '.');
             if size(tmp,2) == 1
                 % Add extensions
                 roi_labels = strcat(data, '.nii');
             end
         end
    else
        error('Unable to read roi_labels file');
    end
end

%% Binarize and write
% Loop over all ROI indices and save them as files
for roi = 1:length(roi_idx)
	
    % Create a 3D matrix of dimensions equal to the atlas file
    binary_mask_data = zeros(size(atlas_data));
    binary_mask_header = atlas_header;
    
    % Edit header of nifti
    binary_mask_header.fname = fullfile(output_location, roi_labels{roi});
    
    % Make all corresponding entries to the roi_idx = 1
    binary_mask_data(atlas_data == roi_idx(roi)) = 1;
    
    % Save volume
    spm_write_vol(binary_mask_header, binary_mask_data);
end