function label_brain(db_location, input_string, save_dir, threshold)
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
    if strcmp(ext, '.nii') && ~exist('threshold', 'var')
        threshold = 0;
    end
end

% Flag for cases when nothing passes the threhsold
flag = 0;

% Load database
load(db_location);
num_atlases = abs(size(database_intensity,2)-3);

% If input is a nifti file, read the file in and threshold
if strcmp(ext, '.nii') || strcmp(ext, '.img') || strcmp(ext, '.hdr')
    image_vol = spm_vol(input_string);
    if length(image_vol) > 1
        error('Only 3D volumes allowed');
    end
    [image_data, image_xyz] = spm_read_vols(image_vol);
    image_xyz = image_xyz';
    if ~isempty(nonzeros(image_data>threshold))
        image_data_thr = (image_data>threshold).*image_data;
        num_voxels_thr = nonzeros(image_data_thr);
        coordinates = image_xyz(image_data>threshold,:);
        
        % If 3D volume is proper, initialize labeling variables
        labeled_coordinates = cell(size(num_voxels_thr, 1), num_atlases);
        labeled_intensities = NaN(size(num_voxels_thr, 1), num_atlases);
    else
        disp('No voxels cross the threhold');
        flag = 1;
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
        else
            % If text file is proper, initialize labeling variables
            labeled_coordinates = cell(size(coordinates,1), num_atlases);
            labeled_intensities = NaN(size(coordinates,1), num_atlases);
        end
    end
end

% Actual labeling operation
if flag ~= 1
    [ori_exist, loc] = (ismember(coordinates, database_intensity(:,1:3), 'rows'));
    labeled_coordinates(loc==0,:) = {'Not found'};
    
    to_look = database_intensity(nonzeros(loc), 4:size(database_intensity,2));
    for atlas = 1:num_atlases
        [~, tmp_loc] = ismember(to_look(:,atlas), cell2mat(database_labels{atlas}(:,1)));
        labeled_coordinates(ori_exist,atlas) = database_labels{atlas}(tmp_loc,2);
        labeled_intensities(ori_exist,atlas) = to_look(:,atlas);
    end
    
    labeled_coordinates = [header; [num2cell(coordinates), labeled_coordinates]];
else
    labeled_coordinates = header;
end

% Prepare to write the file
fid = fopen(save_dir, 'w');
[num_rows, num_text_cols] = size(labeled_coordinates);
formatSpec = ['%2.2f\t%2.2f\t%2.2f', repmat('\t%s', 1, num_text_cols-3), '\r\n'];
formatSpec_header = [repmat('%s\t', 1, num_text_cols), '\r\n'];

% Write header
fprintf(fid, formatSpec_header, labeled_coordinates{1,:});

for row = 2:num_rows
    fprintf(fid, formatSpec, labeled_coordinates{row,:});
end
fclose(fid);