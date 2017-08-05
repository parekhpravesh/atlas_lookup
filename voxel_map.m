function voxel_map(db_location, save_dir)
% Function to create voxel level concordance map
%% Inputs:
% db_location:          location of database file
% save_dir:             folder where results are to be saved
% 
%% Output:
% voxel_map.mat file containing summary of labels across voxels; for each
% voxel, following are saved:
% a) the coordinates in mm, 
% b) the labels, 
% c) the number of atlases in which a particular label is reported, 
% d) the percentage (number of atlases in c divided by total atlases in db,
% e) a summary of b-d entries
% 
%% Author(s)
% Parekh, Pravesh
% June 22, 2017
% MBIAL

%%
load(db_location);
num_atlases = abs(size(database_intensity,2)-3);
num_voxels = size(database_intensity,1);

% Find sum of rows
sum_cols = sum(database_intensity(:,4:end),2);

% Initialize variables
results = cell(num_voxels,4);
name = cell(1,num_atlases);
undef_entry = {'Undefined', num_atlases, 100, 'Undefined (100 %)'};

% Addiing x, y, and z coordinates into results
results(:,1:3) = num2cell(database_intensity(:, 1:3));

% All rows which sum to zero are labeled 'Undefined'
undef_entries = (sum_cols==0);
[results{undef_entries,4}] = deal(undef_entry);

% Figure out rows to actually label
to_label = find(sum_cols>0);

% Create a structure for all intensities in atlases (useful for comparing
% later)
for atlas = 1:num_atlases
    name{atlas} = ['atlas_', num2str(atlas)];
    tmp_mat.(name{atlas}) = cell2mat(database_labels{1,atlas}(:,1));
end

%  Loop over all entries in the database (voxel level)
for vox_idx = 1:length(to_label)
    
    % Get the intensity at each voxel
    intensities = database_intensity(to_label(vox_idx), 4:end);
    label = cell(1,num_atlases);
    
    % Label all entries
    for atlas = 1:num_atlases
        loc = intensities(atlas) == tmp_mat.(name{atlas});
        label(atlas) = database_labels{1,atlas}(loc,2);
    end
    
    % Tabulate entries
    vox_tabulate = sortrows(tabulate(label), -3);
    
    % Add a column with values and percentage together
    for tb = 1:size(vox_tabulate,1)
        vox_tabulate{tb, 4} = [vox_tabulate{tb,1}, ' (', sprintf('%2.4f', vox_tabulate{tb, 3}), ' %)'];
    end
    
    results{to_label(vox_idx),4} = vox_tabulate;
    
    clear vox_tabulate;
end

% Save results
cd(save_dir);
save('voxel_map.mat', 'results');