function labeled_coordinates = label_brain(input_string, threshold)
% Labeling the brain using multiple atlases
% Parekh, Pravesh
% MBIAL
% April 17, 2017
% May 02, 2017

% Evaluate input and make some choices
num_inputs = nargin;
if num_inputs == 0
    error('At least one input is necessary');
else
    [~, ~, ext] = fileparts(input_string);
    if strcmp(ext, '.txt') && ~exist('threshold', 'var')
        threshold = 0;
    end
end

% If input is a nifti file, read the file in and threshold
if strcmp(ext, '.nii') || strcmp(ext, '.img') || strcmp(ext, '.hdr')
    image_vol = spm_vol(input_string);
    if length(image_vol) > 1
        error('Only 3D volumes allowed');
    end
    image_data = spm_read_vols(image_vol);
    if isempty(nonzeros(image_data>threshold)) ~=0
        image_data_thr = (image_data>threshold).*image_data;
    else
        error('No voxels cross the threhold');
    end
else
    % If input is a text file, ensure that the file is readable and organized
    % in three columns, separated with tab spacing
    coordinates = dlmread(input_string, '\t');
    if isempty(coordinates)
        error('No cooridnates exist in the file');
    else
        if size(coordinates,2) ~=3
            error('File has improper formatting');
        end
    end
end

% Locate the installation directory and check if database exists
% [path_to_database, ~] = fileparts(which('label_brain'));
% 
% if isempty(path_to_database)
%     warn('Installation lcoation not found; please manually locate database');
    path_to_database = uigetdir(pwd, 'Select directory having database');
% end

% Load the coordinates text file and lookup from the database
load(fullfile(path_to_database, 'database.mat'));
num_atlases = abs(size(database_intensity,2)-3);
labeled_coordinates = cell(size(coordinates,1), num_atlases);
labeled_intensities = NaN(size(coordinates,1), num_atlases);

[ori_exist, loc] = (ismember(coordinates, database_intensity(:,1:3), 'rows'));
labeled_coordinates(loc==0,:) = {'Not found'};

to_look = database_intensity(nonzeros(loc), 4:size(database_intensity,2));
for atlas = 1:num_atlases
    [~, tmp_loc] = ismember(to_look(:,atlas), cell2mat(database_labels{atlas}(:,1)));
    labeled_coordinates(ori_exist,atlas) = database_labels{atlas}(tmp_loc,2);
    labeled_intensities(ori_exist,atlas) = to_look(:,atlas);
end