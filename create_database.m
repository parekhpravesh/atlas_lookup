function create_database
% Create database from a list of atlases and lookup tables supplied by the
% user
% Parekh, Pravesh
% MBIAL
% May 02, 2017
% Carried over from April 17, 2017

% Get directories from user
atlas_files_path = uigetdir(pwd, 'Select atlas directory');
label_files_path = uigetdir(pwd, 'Select label directory');
output_dir = uigetdir(pwd, 'Select output directory');

% Initialize
cd(atlas_files_path);
list_atlases = dir('*.nii');
all_atlas_names = cell(1, length(list_atlases));
all_atlas_paths = cell(1, length(list_atlases));
all_label_paths = cell(1, length(list_atlases));

% Create paths and check if label files exist
for i = 1:length(list_atlases)
    [~, tmp_name, ~] = fileparts(list_atlases(i).name);
    all_atlas_names{i} = tmp_name;
    all_atlas_paths{i} = fullfile(atlas_files_path, list_atlases(i).name);
    all_label_paths{i} = fullfile(label_files_path, [tmp_name, '.txt']);
    if ~exist(all_label_paths{i}, 'file')
        error([all_label_paths{i}, ' not found']);
    end
end
clear tmp_name

% Read first atlas file and get some values
tmp_vol = spm_vol(all_atlas_paths{1});
[~, tmp_xyz] = spm_read_vols(tmp_vol);
vox_check = sqrt(sum(tmp_vol.mat(1:3,1:3).^2));   % Guillaume Flandin
dim_check = tmp_vol.dim;
num_voxels = prod(dim_check);
num_atlases = length(all_atlas_paths);

% Initialize based on these calculated values
% sorting rows
all_xyz = sortrows(tmp_xyz');

% Initialize result variables
database_intensity = zeros(num_voxels, num_atlases);
database_labels = cell(1,num_atlases);

clear i j k tmp_vol tmp_xyz

% Read each atlas and save intensity and label into the database
for atlas = 1:num_atlases
    atlas_vol = spm_vol(all_atlas_paths{atlas});
    vox_size = sqrt(sum(atlas_vol.mat(1:3,1:3).^2));   % Guillaume Flandin
    dim_size = atlas_vol.dim;
    
    % Check if the sizes are consistent with the first atlas
    if sum(vox_size ~= vox_check)~=0 || sum(dim_size ~= dim_check)~=0
        error(['Different image dimension and/or voxel size: ', all_atlas_names{atlas}]);
    end
    
    clear vox_size dim_size
    
    % Find intensity at each voxel
    [~, atlas_xyz] = spm_read_vols(atlas_vol);
    atlas_xyz = sortrows(atlas_xyz');
	atlas_ijk = (atlas_vol.mat)\[atlas_xyz, ones(length(atlas_xyz),1)]' ; 
    database_intensity(:, atlas) = spm_get_data(atlas_vol, atlas_ijk)';
    
    % Find all unique intensities which need to be labeled
    list_unique_intensities = unique(database_intensity(:, atlas));
    
    % Read label file
    fid = fopen(all_label_paths{atlas}, 'r');
    all_labels = textscan(fid, '%d %s', 'Delimiter', '\t');
    uq_count = 1;
    
    % Find label for each unique intensity
    for uq = 1:length(list_unique_intensities)
        loc = find(list_unique_intensities(uq) == all_labels{1});
        if isempty(loc)
            label = {'Undefined'};
        else
            label = deblank(all_labels{2}(loc));
        end
        database_labels{atlas}(uq_count,:) = [list_unique_intensities(uq), label];
        uq_count = uq_count + 1;
    end
    fclose(fid);
    clear all_labels label loc atlas_vol atlas_xyz fid list_unique_intensities uq uq_count atlas_ijk
end

clear vox_check dim_check atlas count num_voxels

% Assign xyz values into the result variable
database_intensity = [all_xyz, database_intensity];

clear all_xyz all_indices

% Column names
header = [{'x'}, {'y'}, {'z'}, all_atlas_names];

% Save variables 
cd(output_dir);
save('database_all_vars.mat', 'all_atlas_names', 'all_atlas_paths', ...
    'all_label_paths', 'atlas_files_path', 'database_intensity', ...
    'database_labels', 'header', 'label_files_path', 'list_atlases', ...
    'num_atlases', 'output_dir');
save('database.mat', 'database_intensity', 'database_labels', 'header');