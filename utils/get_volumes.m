function [volumes, volumes_labels] = ...
    get_volumes(path_to_atlas, roi_idx, path_to_lookup, write_file, file_name)
% Function to calculate volumes for the ROIs in an atlas
%% Inputs:
% path_to_atlas:    full path to an SPM readable atlas file
% roi_idx:          vector of numbers corresponding to the indices for
%                   which volumes need to be computed (optional)
% path_to_lookup:   full path to a lookup file having labels for the atlas
%                   (optional)
% write_file:       write volumes as a text file [1/0] (optional)
% file_name:        name of the text file (optional)
%
%% Outputs:
% volumes:          n x 2 matrix of volumes and indices
% volumes_label:    n x 3 cell of volumes, indices, and labels
% n = number of ROIs
%
%% Defaults:
% If only path_to_atlas is input, volumes of all regions is calculated
%
% If roi_idx is input, volumes for only those regions is calculated
%
% If path_to_lookup is input, volumes_labels is output as well with the
% third column having names of the regions
%
% write_file is 0 by default
%
% If file_name is not provided (only in cases when write_file = 1), the
% output file name is as following:
%   When roi_idx is not given:  <atlas_name_all_volumes.txt>
%   When roi_idx is present:    <atlas_name_roi_volumes.txt>
%
%% Examples (not exhaustive):
% path_to_atlas             =   'E:\Parekh\Test\HO_Cortical.nii';
% roi_idx                   =   [1, 5, 8];
% path_to_lookup            =   'E:\Parekh\Test\HO_Cortical.txt';
%
% volumes                   =   get_volumes(path_to_atlas);
% volumes                   =   get_volumes(path_to_atlas, roi_idx);
% [volumes, volumes_labels] =   get_volumes(path_to_atlas, roi_idx, ...
%                               path_to_lookup);
% [volumes, volumes_labels] =   get_volumes(path_to_atlas, [], ...
%                               path_to_lookup);
% [volumes, volumes_labels] =   get_volumes(path_to_atlas, [], [], 1);
% [volumes, volumes_labels] =   get_volumes(path_to_atlas, [], [], 1, ...
%                               'HO_Cortical_AllVol.txt');
%
%% Author(s)
% Parekh, Pravesh
% June 26, 2017
% MBIAL

%% Check and evaluate input
if nargin < 1
    error('At least atlas file should be provided');
else
    % Read atlas file
    [atlas_header, atlas_path, atlas_name, atlas_data, ~, ...
        all_labels, num_labels] = get_atlas_data(path_to_atlas);
    
    % Only path_to_atlas is input
    if nargin == 1
        roi_idx = all_labels;
        num_rois = num_labels;
        path_to_lookup = '';
        write_file = 0;
        file_name = '';
    else
        % path_to_atlas and roi_idx are input
        if nargin == 2
            % If empty roi_idx, search for all indices
            if isempty(roi_idx)
                roi_idx = all_labels;
                num_rois = num_labels;
            else
                num_rois = length(roi_idx);
            end
            path_to_lookup = '';
            write_file = 0;
            file_name = '';
        else
            % Check if empty path_to_lookup is given
            if isempty(path_to_lookup)
                path_to_lookup = '';
            else
                % Otherwise, read path_to_lookup file
                [~, ~, lookup_idx, lookup_names] = ...
                    get_lookup_data(path_to_lookup);
                
                % Sort lookup_idx and lookup_names
                [lookup_idx, loc] = sort(lookup_idx);
                lookup_names = lookup_names(loc);
                
                % Ensure that 'Undefined' is the first entry
                if lookup_idx(1) ~= 0
                    lookup_idx = [0; lookup_idx];
                    lookup_names = [{'Undefined'}; lookup_names];
                end
            end
            % path_to_atlas, roi_idx, and path_to_lookup are input
            if nargin == 3
                % If empty roi_idx, search for all indices
                if isempty(roi_idx)
                    roi_idx = all_labels;
                    num_rois = num_labels;
                else
                    num_rois = length(roi_idx);
                end
                write_file = 0;
                file_name = '';
            else
                % path_to_atlas, roi_idx, path_to_lookup, and write_file
                % are input
                if nargin == 4
                    if write_file == 0
                        file_name = '';
                    end
                    % If empty roi_idx, search for all indices
                    if isempty(roi_idx)
                        roi_idx = all_labels;
                        num_rois = num_labels;
                        file_name = fullfile(atlas_path, ...
                            [atlas_name, '_all_volumes.txt']);
                    else
                        num_rois = length(roi_idx);
                        file_name = fullfile(atlas_path, ...
                            [atlas_name, '_roi_volumes.txt']);
                    end
                else
                    % Everything is input
                    if nargin == 5
                        if write_file == 0
                            file_name = '';
                        end
                        if isempty(roi_idx)
                            roi_idx = all_labels;
                            num_rois = num_labels;
                        else
                            num_rois = length(roi_idx);
                        end
                    end
                end
            end
        end
    end
end

%% Calculate volumes
% Initialize
volumes = zeros(num_rois, 2);
volumes_labels = cell(num_rois, 3);

% Find voxel volume
vox_size = sqrt(sum(atlas_header.mat(1:3,1:3).^2));   % Guillaume Flandin
vox_vol = prod(vox_size);

% Calculate volumes
for roi = 1:num_rois
    volumes(roi, 1) = vox_vol * (sum(atlas_data(:) == roi_idx(roi)));
    volumes(roi, 2) = roi_idx(roi);
    if ~isempty(path_to_lookup)
        loc = lookup_idx == roi_idx(roi);
        volumes_labels(roi,3) = strtrim(lookup_names(loc));
    end
end

volumes_labels(:,1) = num2cell(volumes(:, 1));
volumes_labels(:,2) = num2cell(volumes(:, 2));

% Write file if needed
if write_file == 1
    fid = fopen(file_name, 'w');
    for row = 1:num_rois
        % Check if labels are to be written
        if isempty(volumes_labels{1,3})
            % No extra blank line for last row
            if row == num_rois
                format = '%d\t%d';
            else
                format = '%d\t%d\r\n';
            end
            fprintf(fid, format, volumes_labels{row, 1}, volumes_labels{row, 2});
        else
            % No extra blank line for last row
            if row == num_rois
                format = '%d\t%d\t%s';
            else
                format = '%d\t%d\t%s\r\n';
            end
            fprintf(fid, format, volumes_labels{row, 1}, volumes_labels{row, 2}, strtrim(volumes_labels{row, 3}));
        end
    end
    fclose(fid);
end