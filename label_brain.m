function label_brain(db_location, input_string, threshold)
% Labeling the brain using multiple atlases
%% Inputs:
% db_location:          full path to the database.mat file
% input_string:         full path to a .nii or .txt file (see Notes)
% threshold:            threshold value (optional; see Notes)
%
%% Output:
% Text file having labels for each coordinate in the input file; labels are
% derived from the database, so will have as many number of labels as the
% number of atlases used for making the databsae
%
%% Notes:
% input_string can either be a .nii file or a .txt file
%
% If it is a text file, it should have x, y, and z coordinates in each row
% (tab separated)
%
% In case of a .nii file, it is possible to threshold by passing the
% threshold parameter
%
% Threshold is applied as greater than rather than greater than equal to
% (i.e. all values greater than the threshold are labeled)
%
% Output file is the name of the input file with "_labeled" as suffix
%
% If threshold is used (in case of nifti file), output file name is
% suffixed with "_labeled_thr<value>"
% 
%% Default:
% threshold = 0
%
%% Author(s)
% Parekh, Pravesh
% April 17, 2017
% May 02, 2017
% MBIAL

%% Set default
if nargin == 2
    threshold = 0;
end

%% Load database
load(db_location);
num_atlases = abs(size(database_intensity,2)-3);

%% Process nifti file, threshold, and initialize
[input_path, input_name, ext] = fileparts(input_string);
if strcmp(ext, '.nii')
    image_vol = spm_vol(input_string);
    [image_data, image_xyz] = spm_read_vols(image_vol);
    image_xyz = image_xyz';
    
    save_name = fullfile(input_path, [input_name, '_Labeled_thr', ...
                num2str(threshold), '.txt']);
    
    if ~isempty(nonzeros(image_data>threshold))
        image_data_thr = (image_data>threshold).*image_data;
        num_voxels_thr = nonzeros(image_data_thr);
        coordinates    = image_xyz(image_data>threshold,:);
        % Initialize some variables
        labeled_coordinates = cell(size(num_voxels_thr, 1), num_atlases);
        labeled_intensities = NaN(size(num_voxels_thr, 1), num_atlases);
    else
        error('No voxels cross the threhold');
    end
else
    %% Process text file and initialize
    coordinates = dlmread(input_string, '\t');
    if isempty(coordinates)
        error('No cooridnates exist in the file');
    else
        if size(coordinates,2) ~=3
            error('File has improper formatting');
        else
            % Initialize some variable variables
            labeled_coordinates = cell(size(coordinates,1), num_atlases);
            labeled_intensities = NaN(size(coordinates,1), num_atlases);
            save_name = fullfile(input_path, [input_name, '_Labeled.txt']);
        end
    end
end

%% Actual labeling operation
[ori_exist, loc] = (ismember(coordinates, database_intensity(:,1:3), 'rows'));
labeled_coordinates(loc==0,:) = {'Not found'};

to_look = database_intensity(nonzeros(loc), 4:size(database_intensity,2));
for atlas = 1:num_atlases
    [~, tmp_loc] = ismember(to_look(:,atlas), cell2mat(database_labels{atlas}(:,1)));
    labeled_coordinates(ori_exist,atlas) = database_labels{atlas}(tmp_loc,2);
    labeled_intensities(ori_exist,atlas) = to_look(:,atlas);
end

labeled_coordinates = [header; [num2cell(coordinates), labeled_coordinates]];

% Prepare to write the file
fid = fopen(save_name, 'w');
[num_rows, num_text_cols] = size(labeled_coordinates);
formatSpec = ['%2.2f\t%2.2f\t%2.2f', repmat('\t%s', 1, num_text_cols-3), '\r\n'];
formatSpec_last = ['%2.2f\t%2.2f\t%2.2f', repmat('\t%s', 1, num_text_cols-3)];
formatSpec_header = [repmat('%s\t', 1, num_text_cols), '\r\n'];

% Write header
fprintf(fid, formatSpec_header, labeled_coordinates{1,:});

for row = 2:num_rows
    if row == num_rows
        % No extra blank lines at end of file
        fprintf(fid, formatSpec_last, labeled_coordinates{row,:});
    else
        fprintf(fid, formatSpec, labeled_coordinates{row,:});
    end
end
fclose(fid);