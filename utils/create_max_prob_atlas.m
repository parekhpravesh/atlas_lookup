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
% A stats file if there is a conflict, mentioning the number of voxels in
% conflict, the number of voxels whhose conflict were resolved by
% neighbourhood searching, the number of voxels whose conflict were
% resolved by random allotment, and the number of voxels which were
% eliminated (see Notes)
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
% where two regions have the same probability; the conflict is resolved by
% checking in a neighbourhood of 26 voxels. Let us say that a particular
% voxel has a conflict of maximum probability between regions 10 and 20.
% Therefore, a neighbourhood of 26 voxels around this voxel is drawn and
% the number of voxels belonging to regions 10 and 20 are calculated. If
% there are no voxels belonging to either of these, then that voxel is
% eliminated (i.e. set as undefined). If the neighbourhood has a higher
% number of voxels belonging to one of these regions, that particular
% region is assigned to the voxel. If the conflict cannot be resolved by
% this method, then the voxel is randomly assigned to any of the regions in
% conflict. It is importantt to note that when searching the neighbourhood,
% only thresholded values are being looked for.
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

% Also getting the ijk indices
atlas_ijk = (atlas_header(1).mat)\([atlas_xyz, ones(length(atlas_xyz),1)])';
atlas_ijk = atlas_ijk(1:3,:)';

% Get matrix dimensions
max_i = size(atlas_data,1);
max_j = size(atlas_data,2);
max_k = size(atlas_data,3);

%% Setting defaults
if nargin == 1
    threshold = 0.25;
    warning_file_name = fullfile(atlas_path, [atlas_name, '_maxprob_thr', ...
        num2str(threshold), '_warnings.txt']);
    stats_file_name   = fullfile(atlas_path, [atlas_name, '_maxprob_thr', ...
        num2str(threshold), '_stats.txt']);
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
        stats_file_name   = fullfile(atlas_path, [atlas_name, '_maxprob_thr', ...
            num2str(threshold), '_stats.txt']);
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
                stats_file_name   = fullfile(atlas_path, [atlas_name, ...
                    '_maxprob_thr', num2str(threshold), '_stats.txt']);
                output_file_loc    = fullfile(atlas_path, [atlas_name, ...
                    '_maxprob_thr', num2str(threshold), '.nii']);
            else
                warning_file_name = fullfile(output_file_loc, [atlas_name, ...
                    '_maxprob_thr', num2str(threshold), '_warnings.txt']);
                stats_file_name   = fullfile(output_file_loc, [atlas_name, ...
                    '_maxprob_thr', num2str(threshold), '_stats.txt']);
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
                    stats_file_name   = fullfile(atlas_path, [atlas_name, ...
                        '_maxprob_thr', num2str(threshold), '_stats.txt']);
                    output_file_loc   = fullfile(atlas_path, [atlas_name, ...
                        '_maxprob_thr', num2str(threshold), '.nii']);
                    xml_file_name     = fullfile(atlas_path, [atlas_name, ...
                        '_maxprob_thr', num2str(threshold), '.txt']);
                else
                    warning_file_name = fullfile(output_file_loc, [atlas_name, ...
                        '_maxprob_thr', num2str(threshold), '_warnings.txt']);
                    stats_file_name   = fullfile(output_file_loc, [atlas_name, ...
                        '_maxprob_thr', num2str(threshold), '_stats.txt']);
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
rand_count = 0;
high_count = 0;
elim_count = 0;

% Open a file to write warnings
fid = fopen(warning_file_name, 'w');

% Check if multiple regions have the same probability (equal to max prob)
for i = 1:length(val)
    if val(i) ~= 0
        tmp = sum(atlas_data2(i,:) == val(i));
        if tmp > 1
            
            % Conflict found
            warn_count = warn_count + 1;
            which_regions = find(atlas_data2(i,:) == val(i));
            
            % Attempting to resolve conflict by checking in a neighbourhood
            % of 3x3x3 voxels; if there is a majority of voxels of one
            % region over others, assign that
            loc_ijk     = atlas_ijk(i,1:3);
            
            % Create all 26 neighbours
            repmat_x    = repmat((loc_ijk(1)-1:loc_ijk(1)+1)',9,1);
            repmat_y    = repmat((loc_ijk(2)-1:loc_ijk(2)+1) ,3,3);
            repmat_z    = repmat((loc_ijk(3)-1:loc_ijk(3)+1) ,9,1);
            repmat_xyz  = [repmat_x(:), repmat_y(:), repmat_z(:)];
            repmat_xyz(ismember(repmat_xyz, loc_ijk(1:3), 'rows'),:)= [];
            
            % Remove any neighbours that are outside the matrix
            repmat_xyz(repmat_xyz(:,1)>max_i, :) = [];
            repmat_xyz(repmat_xyz(:,2)>max_j, :) = [];
            repmat_xyz(repmat_xyz(:,3)>max_k, :) = [];
            repmat_xyz(repmat_xyz(:,1)<1, :) = [];
            repmat_xyz(repmat_xyz(:,2)<1, :) = [];
            repmat_xyz(repmat_xyz(:,3)<1, :) = [];
            
            % Convert all the subscripts to indices
            repmat_ind = sub2ind([max_i max_j max_k],repmat_xyz(:,1), ...
                repmat_xyz(:,2), repmat_xyz(:,3));
            
            % Get maximum probabilities in this neighbourhood
            [nei_val, nei_ind] = max(atlas_data2(repmat_ind, :), [], 2);
            
            % Remove neighbouring voxels having zero probability and/or
            % probability conflict
            nei_to_remove = [];
            counter = 1;
            for j = 1:length(nei_val)
                if nei_val(j)~=0
                    tmp2 = sum(atlas_data2(repmat_ind(j),:) == nei_val(j));
                    if tmp2 > 1
                        nei_to_remove(counter) = j;
                        counter = counter + 1;
                    end
                else
                    nei_to_remove(counter) = j;
                    counter = counter + 1;
                end
            end
            nei_ind(nei_to_remove) = [];
            
            % Count number of voxels belonging to all regions
            count_tab = tabulate_vector(nei_ind);
            count_tab = count_tab(1:end, 1:end-1);
            
            % Check if there is at least one voxel in the neighbourhood
            % which belongs to any of the regions which are in conflict; if
            % not, then do not assign any region to this voxel
            if sum(ismember(count_tab(:,1), which_regions'))==0
                % No region assignment to this voxel
                idx(i) = 0;
                % Report
                warning_msg = ['Regions ', num2str(which_regions, '%02d, '),...
                    ' have maximum probability of ', num2str(val(i), '%02d'), ...
                    ' at voxel number ', num2str(i), '; assigning ', ...
                    num2str(idx(i), '%02d'), ...
                    ' as no neighbouring voxels of conflicted regions found;', ...
                    ' x,y,z : [', num2str(atlas_xyz(i,:), '%02d '), ']', ];
                elim_count = elim_count + 1;
                
            else 
                % Find number of voxels belonging to regions having a
                % conflicted probability (which_regions from above)
                [tmp_val, tmp_loc] = max(count_tab(ismember(count_tab(:,1), which_regions'),2));
                if numel(find(count_tab(:,2) == tmp_val)) == 1
                    
                    % Conflict resolved; report and update
                    idx(i) = count_tab(tmp_loc,1);
                    warning_msg = ['Regions ', num2str(which_regions, '%02d, '),...
                        ' have maximum probability of ', num2str(val(i), '%02d'), ...
                        ' at voxel number ', num2str(i), '; assigning ', ...
                        num2str(idx(i), '%02d'), ...
                        ' by highest number of neighbouring voxels: ', ...
                        num2str(tmp_val), ...
                        '; x,y,z : [', num2str(atlas_xyz(i,:), '%02d '), ']', ];
                    high_count = high_count + 1;
                    
                else
                    % Conflict not resolved; random allocation; report and
                    % update
                    idx(i) = count_tab(randi(length(count_tab)),1);
                    warning_msg = ['Regions ', num2str(which_regions, '%02d, '),...
                        ' have maximum probability of ', num2str(val(i), '%02d'), ...
                        ' at voxel number ', num2str(i), '; assigning ', ...
                        num2str(idx(i), '%02d'), ' by random allotment;', ...
                        ' x,y,z : [', num2str(atlas_xyz(i,:), '%02d '), ']', ];
                    rand_count = rand_count + 1;
                end
            end
            fprintf(fid, '%s\r\n', warning_msg);
            
            clear warning_msg which_regions tmp_val tmp_loc count_tab ...
                nei_ind nei_to_remove nei_val tmp2 counter repmat_ind ...
                repmat_x repmat_y repmat_z repmat_xyz loc_ijk tmp
        end
    end
end
fclose(fid);

if warn_count > 0
    msg = ['Total number of voxels with conflicting maximum probability = ', ...
        num2str(warn_count)];
    disp(msg);
    % Open the stats file and write details
    fid = fopen(stats_file_name, 'w');
    fprintf(fid, '%s\r\n', msg);
    fprintf(fid, '%s\r\n', ...
        ['No. of conflicts resolved by neighbourhood searching = ', ...
        num2str(high_count)]);
    fprintf(fid, '%s\r\n', ...
        ['No. of conflicts resolved by random allotment = ', ...
        num2str(rand_count)]);
    fprintf(fid, '%s', ...
        ['No. of voxels eliminated = ', num2str(elim_count)]);
    fclose(fid);
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