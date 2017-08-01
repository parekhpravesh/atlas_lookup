function create_max_prob_atlas(path_to_atlas, threshold, output_file_name)
% Function to create a maximum probability atlas from a 4D probabilistic
% map after thresholding
%% Inputs:
% path_to_atlas:    full path to 4D probability map(s)
% threshold:        numeric value to threshold with (optional)
% output_file_name: file name (optionally: with full path) which will be
%                   written (optional)
% 
%% Output:
% A 3D NIfTI file with an intensity value corresponding to a particular
% region
% 
% A warning file if there is a conflict in determining maximum probability
% at a given voxel (see Notes)
% 
%% Notes:
% At a given voxel, the probability value for all regions are checked. All
% probability values below threshold are discarded. Then, all indices with
% probability above threshold are checked and the index for which the
% probability is the highest is taken and is assigned to that voxel.
% 
% Thresholding is done by using less than operation rather than less than
% equal to
% 
% A check is done before thresholding to ensure that units of probaility
% and thresholding are similar (i.e. they are both fractions or both
% percentages)
% 
% A text file with warnings is created having a warning for every voxel
% where two regions have the same probability; the first region to have
% that probability is labeled
% 
%% Default
% threshold = 0.25
% default output file name is atlas_name_maxprob_thr_threshold.nii
% 
%% Author(s)
% Parekh, Pravesh
% July 08, 2017
% MBIAL

%% Check and read inputs
[atlas_header, atlas_path, atlas_name, atlas_data, atlas_xyz, ~, ~] = ...
    get_atlas_data(path_to_atlas);
if size(atlas_header, 1) == 1
    error('Does not appear to be 4D probability map');
end
num_rois = size(atlas_header,1);

% Setting defaults
if nargin == 1
    threshold = 0.25;
    output_file_name =  fullfile(atlas_path, [atlas_name, '_maxprob_thr', ...
                        num2str(threshold), '.nii']);
    warning_file_name = fullfile(atlas_path, [atlas_name, '_maxprob_thr', ...
                        num2str(threshold), '_warnings.txt']);
else
    if nargin == 2
        if isempty(threshold)
            threshold = 0.25;
        end
        output_file_name =  fullfile(atlas_path, [atlas_name, '_maxprob_thr', ...
                            num2str(threshold), '.nii']);
        warning_file_name = fullfile(atlas_path, [atlas_name, '_maxprob_thr', ...
                            num2str(threshold), '_warnings.txt']);
    else
        if nargin == 3
            if isempty(threshold)
                threshold = 0.25;
            end
            if isempty(output_file_name)
                output_file_name  = fullfile(atlas_path, [atlas_name, ...
                                    '_maxprob_thr', num2str(threshold), '.nii']);
                warning_file_name = fullfile(atlas_path, [atlas_name, ...
                                    '_maxprob_thr', num2str(threshold), '_warnings.txt']);
            else
                [tmp_path, tmp_name, tmp_ext] = fileparts(output_file_name);
                if isempty(tmp_path)
                    output_file_name  = fullfile(atlas_path, [tmp_name, tmp_ext]);
                    warning_file_name = fullfile(atlas_path, [tmp_name, '_warnings.txt']);
                end
            end
        end
    end
end

%% Thresholding
max_data_val = max(max(max(max(atlas_data))));

% Check units
if max_data_val > 1 && max_data_val <= 100
    if threshold > 1 && threshold <= 100
        atlas_data(atlas_data<threshold) = 0;
    else
        threshold = threshold * 100;
        atlas_data(atlas_data<threshold) = 0;
    end
else
    if threshold > 1 && threshold <= 100
        threshold = threshold/100;
        atlas_data(atlas_data<threshold) = 0;
    else
        atlas_data(atlas_data<threshold) = 0;
    end
end
atlas_data2 = reshape(atlas_data, [size(atlas_xyz,1), num_rois]);

%% Calculate and assign maximum probability
[val, idx] = max(atlas_data2, [], 2);
warn_count = 0;

% Open a file to write warnings
fid = fopen(warning_file_name, 'w');

% Check if multiple regions have the same probability (equal to max prob)
for i = 1:length(val)
    if val(i) ~= 0
        tmp = sum(atlas_data2(i,:) == val(i));
        if tmp > 1
            warn_count = warn_count + 1;
            warning_msg = ['Regions ', num2str(find(atlas_data2(i,:) == val(i)), '%02d, '),...
                ' have maximum probability of ', num2str(val(i), '%02d'), ...
                ' at voxel number ', num2str(i), '; assigning ', ...
                num2str(idx(i), '%02d'), '; x,y,z : [', ...
                num2str(atlas_xyz(i,:), '%02d '), ']', ];
            fprintf(fid, '%s\r\n', warning_msg);
        end
    end
end
fclose(fid);

if warn_count > 0
    disp(['Total number of voxels with conflicting maximum probability = ', num2str(warn_count)]);
else
    % Delete file if no warnings
   delete(fname);
end

atlas_data_mod = idx.*logical(val);
atlas_data_mod = reshape(atlas_data_mod, size(squeeze(atlas_data(:,:,:,1))));

%% Modify header and write
vol_header = atlas_header(1);
vol_header.fname = output_file_name;
vol_header.dt = [4,0];
spm_write_vol(vol_header, atlas_data_mod);