function merge_idx(atlas_file, lookup_file, idx_to_merge, new_idx_list, new_names_list)
% Function to merge index values in an atlas; simulataneously modifies the
% lookup table based on the new_idx value given
%% Inputs
% atlas_file:       full path to SPM readable atlas file
% lookup_file:      full path to text file having lookup entries for the
%                   atlas_file provided
% idx_to_merge:     cell matrix or text file having rows of values to be
%                   merged; entries in a particular row are merged together
%                   (see Notes and Example)
% new_idx_list:     vector or text file of entries with each row entry
%                   corresponding to the new index for the indices which
%                   are merged (see Notes and Example)
% new_names_list:   cell or text file with each row entry corresponding to
%                   the new name for the merged indices (see Notes and
%                   Example)
% 
%% Outputs
% new atlas and lookup files written in the respective folders where
% atlas_file and lookup_file are being read from; the files will have
% "_merged" in their names
% 
%% Notes
% idx_to_merge should be organized in rows; each row can have several
% column entries; all columns in a row are merged together
% 
% new_idx_list should have as many rows as idx_to_merge with each row
% having a single value; this value would be used as the new idx value for
% the merged indices
% 
% new_names_list should have as many rows as idx_to_merge and new_idx_list;
% these values would be used in the lookup table as the new name for the
% ROI which is created after merging
% 
% idx_to_merge, new_idx_list, and new_names_list can either be text files
% or else cell type; new_idx_list can be a numeric vector too
% 
% idx_to_merge and new_names_list should be cell type; new_idx_list can be
% either numeric or cell type
% 
% If 'Undefined' is not present as the first entry of lookup table, it is
% automatically added
% 
% It is possible to mix cell type and text files as inputs
% 
%% Example 1: cell type
% idx_to_merge   = {1, 2, 3; 4, 5, []};
% new_idx_list   = {10; 20};
% new_names_list = {'ROI10'; 'ROI20'};
% 
% idx_to_nerge = 
% [1]    [2]    [3]
% [4]    [5]     []
% 
% new_idx_list =
% [10]
% [20]
% 
% new_names_list = 
% 'ROI10'
% 'ROI20'
% 
% This would merge areas 1, 2, and 3, assign the value 10, and the name
% 'ROI10' to them; and merge areas 4 and 5, assign the valules 20, and the
% name 'ROI20' to them
% 
%% Example 2: text files
% idx_to_merge:
% 1 2 3
% 4 5
% 
% new_idx_list:
% 10
% 20
% 
% new_names_list:
% ROI10
% ROI20
% 
% This would merge areas 1, 2, and 3, assign the value 10, and the name
% 'ROI10' to them; and merge areas 4 and 5, assign the valules 20, and the
% name 'ROI20' to them
% 
%% Author(s)
% Parekh, Pravesh
% July 24, 2017
% MBIAL

%% Get atlas and lookup data
[atlas_header, atlas_path, atlas_name, atlas_data, ~, all_labels, num_labels] ...
                                                     = get_atlas_data(atlas_file);
[lookup_path, lookup_name, lookup_idx, lookup_names] = get_lookup_data(lookup_file,1);

%% Process inputs
if ischar(idx_to_merge)
    % Read idx_to_merge text file
    idx_to_merge = dlmread(idx_to_merge, ' ');
    % Find "0" entries (spurious)
    loc = idx_to_merge == 0;
    % Convert idx_to_merge to cell
    idx_to_merge = num2cell(idx_to_merge);
    % Replace "0" with "[]"
    idx_to_merge(loc) = {[]};
end

if ischar(new_idx_list)
    % Read new_idx_list text file
    new_idx_list = dlmread(new_idx_list);
end

if ischar(new_names_list)
    % Read new_names_list text file
    fid = fopen(new_names_list, 'r');
    tmp = textscan(fid, '%s');
    fclose(fid);
    new_names_list = tmp{1};
end

if iscell(new_idx_list)
    new_idx_list = cell2mat(new_idx_list);
end

output_suffix = '_merged';

%% Sanity check
% Checking if all inputs have the same number of rows
if size(idx_to_merge,1) ~= size(new_idx_list,1) ||...
        size(new_names_list,1) ~= size(new_idx_list,1) ||...
        size(new_names_list,1) ~= size(idx_to_merge,1)
    error('idx_to_merge, new_idx_list, and new_names_list should have same number of rows');
end

% Checking if there is any overlap between new_idx_list, idx_to_merge and
% existing indices; not sure if this is a good idea
% if ~isempty(intersect(cell2mat(idx_to_merge(:)), new_idx_list(:))) ...
%         || ~isempty(intersect(all_labels, new_idx_list(:)))
%     error('Conflict between indices to merge/new indices/existing indices');
% end

% Checking if idx_to_merge exists in the atlas
if isempty(intersect(cell2mat(idx_to_merge(:)), all_labels))
    error('Non existent indices to be merged');
end

%% Initialize
atlas_data_modified = atlas_data;

% Find lookup_names and lookup_idx which remain unchanged
[~, ~, loc_names] = intersect(cell2mat(idx_to_merge(:)), lookup_idx);
all_locs = 1:num_labels;
all_locs(loc_names) = [];
unchanged_list = [strtrim(lookup_names(all_locs)), num2cell(double(lookup_idx(all_locs)))];

%% Loop over all rows in idx_to_merge
for rows = 1:size(idx_to_merge,1)
    % For each row, find indices and merge them
    for cols = 1:size(idx_to_merge(rows,:),2)
        if ~isempty(idx_to_merge{rows, cols})
            to_mod = atlas_data_modified == idx_to_merge{rows, cols};
            atlas_data_modified(to_mod) = new_idx_list(rows);
        end
    end
    % Grow unchanged_list
    unchanged_list{end+1, 1} = new_names_list{rows};
    unchanged_list{end  , 2} = new_idx_list(rows);
end

%% Sort unchanged_list
unchanged_list = sortrows(unchanged_list,2);

%% Edit header and write atlas file
atlas_header.fname = fullfile(atlas_path, [atlas_name, output_suffix, '.nii']);
spm_write_vol(atlas_header, atlas_data_modified);

%% Write lookup file
fid = fopen(fullfile(lookup_path, [lookup_name, output_suffix, '.txt']), 'w');
for i = 1:size(unchanged_list,1)
    if i == size(unchanged_list,1)
        fprintf(fid, '%d %s', unchanged_list{i,2}, unchanged_list{i,1});
    else
        fprintf(fid, '%d %s \r\n', unchanged_list{i,2}, unchanged_list{i,1});
    end
end
fclose(fid);