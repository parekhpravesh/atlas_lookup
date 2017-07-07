function create_max_prob_atlas(atlas_name, threshold)
% Function to create a maximum probability atlas from a 4D probabilistic
% map after thresholding
%% Inputs:
% atlas_name:       full path to 4D probability map(s)
% threshold:        numeric value to threshold with
% 
%% Output:
% A 3D NIfTI file with an intensity value corresponding to a particular
% region
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
%% Author(s)
% Parekh, Pravesh
% July 08, 2017
% MBIAL

%% Check and read inputs
if exist(atlas_name, 'file')
    [~,name,~] = fileparts(atlas_name);
    vol_header = spm_vol(atlas_name);
    if size(vol_header,1) == 1
        error('Does not appear to be 4D probability map');
    else
        [vol_data, vol_xyz] = spm_read_vols(vol_header);
        vol_xyz = vol_xyz(1:3,:)';
        num_rois = size(vol_header,1);
    end
end

%% Thresholding
max_data_val = max(max(max(max(vol_data))));

% Check units
if max_data_val > 1 && max_data_val <= 100
    if threshold > 1 && threshold <= 100
        vol_data(vol_data<threshold) = 0;
    else
        threshold = threshold * 100;
        vol_data(vol_data<threshold) = 0;
    end
else
    if threshold > 1 && threshold <= 100
        threshold = threshold/100;
        vol_data(vol_data<threshold) = 0;
    else
        vol_data(vol_data<threshold) = 0;
    end
end
vol_data2 = reshape(vol_data, [size(vol_xyz,1), num_rois]);

%% Assign maximum probability
[val, idx] = max(vol_data2, [], 2);
atlas_data_mod = idx.*logical(val);
atlas_data_mod = reshape(atlas_data_mod, size(squeeze(vol_data(:,:,:,1))));

%% Modify header and write
vol_header = vol_header(1);
vol_header.fname = [name, '_maxprob_thr', num2str(threshold), '.nii'];
vol_header.dt = [4,0];
spm_write_vol(vol_header, atlas_data_mod);