function create_max_prob_atlas(path_to_atlas, threshold, output_file_loc, xml_file)
% Function to create a maximum probability atlas from a 4D probabilistic
% map after thresholding
%% Inputs:
% path_to_atlas:    full path to 4D probability map(s) or full path to a
%                   folder having 3D probability maps, one file for each ROI
% threshold:        numeric value to threshold with (optional)
% output_file_loc:  full path to where the output file(s) would be written 
%                   (optional)
% xml_file:         full path to xml file from which lookup file will be
%                   created (optional; see Notes)
% 
%% Output:
% A 3D NIfTI file with an intensity value corresponding to a particular
% region
% 
% A .txt file if the xml file having indices and labels are provided
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
% The xml file input is valid when trying to import FSL atlas files; this
% module is not well tested so may not work in case of other kinds of xml
% files. If xml file is provided, lookup file is created as well. The
% created lookup file will have 0 and 'Undefined' as the first entry
% 
% The index value read from xml file is +1ed as the starting value is from
% zero
% 
% In case folder is provided instead of 4D files, image file properties
% (such as affine transform matrix) are read from the first ROI
% 
%% Default
% threshold = 0.25
% output file location is the same as path in path_to_atlas
% output file name: is atlas_name_maxprob_thr_threshold.nii
% lookup file name: is atlas_name_maxprob_thr_threshold.txt
% 
% In case folder is provided instead of 4D file, the name of the folder is
% assumed to be the atlas_name
% 
%% Author(s)
% Parekh, Pravesh
% July 08, 2017
% MBIAL

%% Check and read inputs
% Check if input is folder or NIfTI file
if isdir(path_to_atlas)
    cd(path_to_atlas);
    list_files = dir('*.nii');
   
    % Check to make sure that there are some image files present
    if isempty(list_files)
        % Make an attempt to see if .img files are present
        list_files = dir('*.img');
        if isempty(list_files)
            error('Could not find image files');
        end
    end
        num_rois = length(list_files);
        
        % Read first file and get information
        atlas_header = spm_vol(list_files(1).name);
        [atlas_path, ~, ~] = fileparts(atlas_header(1).fname);
        [tmp_data, atlas_xyz] = spm_read_vols(atlas_header);
        atlas_xyz = atlas_xyz(1:3,:)';
        
        % Initialize
        atlas_data = zeros([size(tmp_data), num_rois]);
        
        % atlas_name is the name of the folder
        [~, atlas_name, ~] = fileparts(path_to_atlas);
        
        % Read each file and assign to atlas_data 
        for i = 1:num_rois
            tmp_vol             = spm_vol(list_files(i).name);
            atlas_data(:,:,:,i) = spm_read_vols(tmp_vol);
        end
        clear tmp_data tmp_vol
else
    
    [atlas_header, atlas_path, atlas_name, atlas_data, atlas_xyz, ~, ~] = ...
        get_atlas_data(path_to_atlas);
    if size(atlas_header, 1) == 1
        error('Does not appear to be 4D probability map');
    end
    num_rois = size(atlas_header,1);
end

%% Setting defaults
if nargin == 1
    threshold = 0.25;
    warning_file_name = fullfile(atlas_path, [atlas_name, '_maxprob_thr', ...
        num2str(threshold), '_warnings.txt']);
    output_file_loc   = fullfile(atlas_path, [atlas_name, '_maxprob_thr', ...
        num2str(threshold), '.nii']);
    xml_file = '';
else
    if nargin == 2
        if isempty(threshold)
            threshold = 0.25;
        end
        warning_file_name = fullfile(atlas_path, [atlas_name, '_maxprob_thr', ...
            num2str(threshold), '_warnings.txt']);
        output_file_loc   = fullfile(atlas_path, [atlas_name, '_maxprob_thr', ...
            num2str(threshold), '.nii']);
        xml_file = '';
    else
        if nargin == 3
            if isempty(threshold)
                threshold = 0.25;
            end
            if isempty(output_file_loc)
                 warning_file_name = fullfile(atlas_path, [atlas_name, ...
                    '_maxprob_thr', num2str(threshold), '_warnings.txt']);
                output_file_loc    = fullfile(atlas_path, [atlas_name, ...
                    '_maxprob_thr', num2str(threshold), '.nii']);
            else
                warning_file_name = fullfile(output_file_loc, [atlas_name, ...
                    '_maxprob_thr', num2str(threshold), '_warnings.txt']);
                output_file_loc   = fullfile(output_file_loc, [atlas_name, ...
                    '_maxprob_thr', num2str(threshold), '.nii']);
            end
            xml_file = '';
        else
            if nargin == 4
                if isempty(threshold)
                    threshold = 0.25;
                end
                if isempty(output_file_loc)
                    warning_file_name = fullfile(atlas_path, [atlas_name, ...
                        '_maxprob_thr', num2str(threshold), '_warnings.txt']);
                    output_file_loc   = fullfile(atlas_path, [atlas_name, ...
                        '_maxprob_thr', num2str(threshold), '.nii']);
                    xml_file_name     = fullfile(atlas_path, [atlas_name, ...
                        '_maxprob_thr', num2str(threshold), '.txt']);
                else
                    warning_file_name = fullfile(output_file_loc, [atlas_name, ...
                        '_maxprob_thr', num2str(threshold), '_warnings.txt']);
                    xml_file_name     = fullfile(output_file_loc, [atlas_name, ...
                        '_maxprob_thr', num2str(threshold), '.txt']);
                    output_file_loc   = fullfile(output_file_loc, [atlas_name, ...
                        '_maxprob_thr', num2str(threshold), '.nii']);
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
   delete(warning_file_name);
end

atlas_data_mod = idx.*logical(val);
atlas_data_mod = reshape(atlas_data_mod, size(squeeze(atlas_data(:,:,:,1))));

%% Creating lookup table and writing lookup file if xml file was provided
if ~isempty(xml_file)
    % Read xml file
    xmlDoc = xmlread(xml_file);
    
    % Get all list items corresponding to tag label
    allListItems = xmlDoc.getElementsByTagName('label');
    
    % Find number of all such list items
    numListItems = allListItems.getLength;
    
    % Initialize
    data = cell(numListItems, 2);
    
    % Loop over all entries
    for element_num = 0:numListItems-1
        % Get 'index' attribute; adding +1 to index value
        data{element_num+1,1} = str2double(allListItems.item(element_num).getAttribute('index'))+1;
        % Get 'label'
        data{element_num+1,2} = char(allListItems.item(element_num).getTextContent);
    end
    
    % Append 'Undefined' entry at the top
    data = [0, {'Undefined'}; data];
    
    % Open lookup table text file for writing
    fid = fopen(xml_file_name, 'w');
    
    for i = 1:size(data,1)
        if i == size(data,1)
            fprintf(fid, '%d\t%s', data{i,1}, data{i,2});
        else
            fprintf(fid, '%d\t%s\r\n', data{i,1}, data{i,2});
        end
    end
    fclose(fid);
end

%% Modify header and write
vol_header = atlas_header(1);
vol_header.fname = output_file_loc;
vol_header.dt = [4,0];
spm_write_vol(vol_header, atlas_data_mod);