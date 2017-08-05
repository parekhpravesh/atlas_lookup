function modify_atlas_lr(path_to_atlas, path_to_lookup, new_idx_list, new_names_list)
% Function to modify an atlas to include the left and right sided labels
%% Inputs:
% path_to_atlas:    path to an SPM readable image file having labels
% path_to_lookup:   path to a tab separated text file having names for
%                   these labels (should have two columns: one having
%                   intensities and one having labels) (can be empty if
%                   only atlas is to be modified; see Notes)
% new_idx_list:     indices which would replace the existing ones in the
%                   atlas
% new_names_list:   new names which would replace existing names in
%                   the lookup table
%
%% Outputs:
% Modified atlas file written with the suffix "_Modified_LR"
% If new_names_list is provided, new lookup file is also written with the
% same suffix
% Both output files are written in the respective folders from which they
% were read
% 
%% The following inputs for new_idx_list are supported:
% 'serialize'       create intensities from 0:number of intensities*2
% 'add n m'         add n to intensities on the left; add m to intensities
%                   on the right (except 0)
% 'sub n m'         subtract n from intensities on left; subtract m from
%                   intensities on the right (except 0)
% 'mul n m'         multiply n to intensities on the left; multiply m to
%                   intensities on the right (0 remains unaffected)
% 'div n m'         divide intensities on the left by n; divide intensities
%                   on the right by n (except 0) (see Notes)
% a numeric vector of intensities
% a cell array of intensities
% a cell array of intensities and names (see Notes)
% path to a text file with a column of intensities
% path to a tab separated text file with intensities and names (see Notes)
%
%% The following inputs for new_names_list are supported:
% 'lr sh prefix'	add 'L' and 'R' as prefix to existing names
% 'lr sh postfix'	add 'L' and 'R' as postfix to existing names
% 'lr prefix'       add 'Left' and 'Right' as prefix to existing names
% 'lr postfix'      add 'Left' and 'Right' as postfix to existing names
% a cell array of names
% path to a text file with a column of names
% path to a tab separated text file with intensities and names (see Notes)
%
%% Notes:
% new_names_list provided along with new_idx_list will be ignored if fourth
% argument is passed
%
% new_idx_list provided with new_names_list will be ignored
%
% If dividing new_idx_list by a number result in fractional values,
% operation will generate an error and atlas will not be modified
%
% It is optional to define "0" in the new_idx_list and "Undefined" in the
% new_names_list; if they are not specified, they will be automatically
% added to the written files

% In case "Undefined" is entered as something else in the input (for
% example, "Undef" etc.), script assumes that "Undefined" is not present
% and will force an additional entry of "Undefined" into the
% new_names_list, leading to an error during sanity check
%
% x<=0 is treated as left and x>0 is treated as right; therefore, midline
% coordinates are clubbed with left side.
%
% It is possible to modify only the atlas without modifying the lookup
% table. This can be done in two ways:
%   Only input atlas_name and the new atlas will be created using default
%   case for new_idx
%   Altenatively, input atlas_name, '' for lookup_name, and new_idx, and
%   the new atlas will be created using the new_idx inputs
%
%% Defaults:
% If new_idx_list is not provided, 1000 is added to existing intensities
% for left side and 2000 is added to existing intensities for right side
%
% If new_names is not provided, "Left" is prefixed to existing name for
% left side and "Right" is prefixed to existing name for right side
%
% If lookup_names is not provided, only the atlas will be modified
%
%% Author(s)
% Parekh, Pravesh
% June 26, 2017
% MBIAL

%% Check and process the inputs
if nargin == 1
    path_to_lookup = '';
    new_idx_list = 'default';
    new_names_list = '';
else
    if nargin == 2
        new_idx_list = 'default';
        if isempty(path_to_lookup)
            new_names_list = '';
        else
            new_names_list = 'default';
        end
    else
        if nargin == 3
            if isempty(new_idx_list)
                new_idx_list = 'default';
            end
            if isempty(path_to_lookup)
                new_names_list = '';
            else
                new_names_list = 'default';
            end
        else
            if nargin == 4
                if isempty(new_idx_list)
                    new_idx_list = 'default';
                end
                if isempty(path_to_lookup)
                    new_names_list = '';
                end
            end
        end
    end
end

%% Read atlas file and lookup table
[atlas_header, atlas_path, atlas_name, atlas_data, atlas_xyz, ...
    all_labels, num_labels] = get_atlas_data(path_to_atlas);

if ~isempty(path_to_lookup)
[lookup_path, lookup_name, ~, lookup_names] = ...
    get_lookup_data(path_to_lookup, 1);
lookup_names_tmp = lookup_names(2:end); % Skipping 'Undefined'
end

%% Evaluate new_idx input
flag = 0;
if ischar(new_idx_list)
    % Check if text file is given
    [~,~,ext] = fileparts(new_idx_list);
    if strcmpi(ext, '.txt')
        % Read the file and get the new_idx
        fid = fopen(new_idx_list, 'r');
        tmp_data = textscan(fid, '%s %s', 'Delimiter', '\t');
        fclose(fid);
        % Check second column
        if isempty(tmp_data{2}{1})
            tmp_data(2) = [];
            % If it is numeric
            if isnumeric(str2double(tmp_data{1}))
                new_idx_list = str2double(tmp_data{1})';
            else
                error('Unable to process text file');
            end
        else
            % If two columns exist, figure out which is new_names and which
            % is new_idx column
            if isnumeric(str2double(tmp_data{1}))
                new_idx_list = str2double(tmp_data{1});
                new_names_tmp = tmp_data{2};
                flag = 1;
            else
                if isnumeric(str2double(tmp_data{2}))
                    new_idx_list = str2double(tmp_data{2});
                    new_names_tmp = tmp_data{1};
                    flag = 1;
                else
                    error('Text file is not organized properly');
                end
            end
        end
    else
        % If not a text file, figure out what to do
        switch(lower(new_idx_list))
            case 'serialize'
                new_idx_list = 0:(num_labels-1)*2;
            case 'default'
                tmp_list = all_labels(2:end); % First value is zero
                new_idx_list = [0; tmp_list+1000; tmp_list+2000];
            otherwise
                % Figure out operation type, n, and m
                tmp_op = strsplit(new_idx_list);
                if length(tmp_op) ~= 3
                    error('Unable to process new_idx input');
                else
                    operation_type = tmp_op{1};
                    n = str2double(tmp_op{2});
                    m = str2double(tmp_op{3});
                    tmp_list = all_labels(2:end); % First value is zero
                    switch(lower(operation_type))
                        case 'add'
                            new_idx_list = [0; tmp_list+n; tmp_list+m];
                        case 'sub'
                            new_idx_list = [0; tmp_list-n; tmp_list-m];
                        case 'mul'
                            new_idx_list = [0; tmp_list*n; tmp_list*m];
                        case 'div'
                            new_idx_list = [0; tmp_list/n; tmp_list/m];
                        otherwise
                            error('Unable to process new_idx input');
                    end
                end
        end
    end
else
    if iscell(new_idx_list)
        % Check if 1D cell is input
        if size(new_idx_list,2) == 1
            if isnumeric(new_idx_list{1})
                new_idx_list = new_idx_list{1};
            else
                error('Unable to process new_idx input');
            end
        else
            % Check if 2D cell is input
            if size(new_idx_list,2) == 2
                tmp_data = new_idx_list;
                % Figure out which column is index and which is names
                if iscell(tmp_data{2}) && isnumeric(tmp_data{1})
                    new_names_tmp = tmp_data{2};
                    new_idx_list = tmp_data{1};
                    flag = 1;
                else
                    if iscell(tmp_data{1}) && isnumeric(tmp_data{2})
                        new_names_tmp = tmp_data{1};
                        new_idx_list = tmp_data{2};
                        flag = 1;
                    else
                        error('Unable to process new_idx input');
                    end
                end
            else
                error('Unable to process new_idx input');
            end
        end
    else
        if ~isnumeric(new_idx_list)
            error('Unknown type of input for new_idx');
        end
    end
end

% Check if new_idx is a column vector or not
if isrow(new_idx_list)
    new_idx_list = new_idx_list';
end

% Check if zero exists in new_idx
if isempty(intersect(0, new_idx_list))
    new_idx_list = [0; new_idx_list];
end

%% Evaluate new_names input
% If new_idx_list had names and fourth argument was not passed, names
% passed with new_idx_list get selected
if flag == 1 && nargin <=3
    new_names_list = new_names_tmp;
else
    % Test for empty case
    if isempty(new_names_list)
        new_names_list = '';
    else
        if ischar(new_names_list)
            % Check if text file is input
            [~,~,ext] = fileparts(new_names_list);
            if strcmpi(ext, '.txt')
                fid = fopen(new_names_list, 'r');
                tmp_data = textscan(fid, '%s %s', 'Delimiter', '\t');
                % Check if second column exists
                if isempty(tmp_data{2}{1})
                    tmp_data(2) = [];
                    new_names_list = tmp_data{1};
                else
                    % If two columns exist, figure out which is new_names and
                    % which is new_idx column
                    if isnumeric(str2double(tmp_data{1}))
                        new_names_list = tmp_data{2};
                    else
                        if isnumeric(str2double(tmp_data{2}))
                            new_names_list = tmp_data{1};
                        else
                            error('Text file is not organized properly');
                        end
                    end
                end
            else
                switch(lower(new_names_list))
                    case 'lr sh prefix'
                        new_names_list = [{'Undefined'}; ...
                            strcat({'L '},      strtrim(lookup_names_tmp)); ...
                            strcat({'R '},      strtrim(lookup_names_tmp))];
                    case 'lr sh postfix'
                        new_names_list = [{'Undefined'}; ...
                            strcat(strtrim(lookup_names_tmp), {' L'}); ...
                            strcat(strtrim(lookup_names_tmp), {' R'})];
                    case 'lr prefix'
                        new_names_list = [{'Undefined'}; ...
                            strcat({'Left '},   strtrim(lookup_names_tmp)); ...
                            strcat({'Right '},  strtrim(lookup_names_tmp))];
                    case 'lr postfix'
                        new_names_list = [{'Undefined'}; ...
                            strcat(strtrim(lookup_names_tmp), {' Left'}); ...
                            strcat(strtrim(lookup_names_tmp), {' Right'})];
                    case 'default'
                        new_names_list = [{'Undefined'}; ...
                            strcat({'Left '},   strtrim(lookup_names_tmp)); ...
                            strcat({'Right '},  strtrim(lookup_names_tmp))];
                    otherwise
                        error('Unable to process new_names input');
                end
            end
        else
            if iscell(new_names_list)
                % Check if 1D cell is input
                if size(new_names_list,2) == 1
                    new_names_list = new_names_list{1};
                else
                    % Check if 2D cell is input
                    if size(new_names_list,2) == 2
                        tmp_data = new_idx_list;
                        % Figure out which column is index and which is names
                        if isnumeric(str2double(tmp_data{1}))
                            new_names_list = tmp_data{2};
                        else
                            if isnumeric(str2double(tmp_data{2}))
                                new_names_list = tmp_data{1};
                            else
                                error('Unable to process new_idx input');
                            end
                        end
                    else
                        error('Unable to process new_idx input');
                    end
                end
            else
                error('Unknown type of input for new_idx');
            end
        end
    end
end

% Add 'Undefined' if it does not exist entry exists
if ~isempty(new_names_list) && isempty(intersect('undefined', lower(new_names_list)))
    new_names_list = [{'Undefined'}; new_names_list];
end

%% Sanity check
% Number of entries in new_idx should be equal to twice the number of
% unique entries in the atlas
if length(new_idx_list) ~= (num_labels*2)-1
    error('Incorrect number of entries in new_idx_list');
end

% Number of entries in the new_names should be equal to twice the number of
% unique entries in the atlas
if ~isempty(new_names_list) && length(new_names_list) ~= (num_labels*2)-1
    error('Incorrect number of entries in new_names_list');
end

% Check each entry of new_names to ensure that no empty entries exist
if ~isempty(new_names_list)
    for tmp = 1:length(new_names_list)
        if isempty(new_names_list{tmp})
            error('Empty entires in new_names_list not allowed');
        end
    end
end

% Checking for duplicate new values
new_uniques = unique(new_idx_list);
if length(new_uniques) ~= length(new_idx_list)
    error('Duplicate values in new_idx_list');
end

% Checking overlap of new and old indices
if ~isempty(intersect(nonzeros(new_idx_list), nonzeros(all_labels)))
    warning('Old and new indices overlap!');
end

% Checking if new indices have any fractional values
if sum(floor(new_idx_list) == new_idx_list) ~= length(new_idx_list)
    error('Non-integer indices');
end

%% Left and right coordinates and new indices 
% All left and right coordinates
all_left = atlas_xyz(:,1)  <= 0;
all_right = atlas_xyz(:,1) >  0;

% All left and right new coordinates (except zero)
new_idx_left  = new_idx_list(2:num_labels);      % Skipping first entry (zero)
new_idx_right = new_idx_list(num_labels+1:end);

%% Modify atlas (actual module)
% Initialize
atlas_data_mod = zeros(numel(atlas_data),1);
count = 1;

for i = 2:length(all_labels)                % Skipping first entry (zero)
    tmp = atlas_data(:) == all_labels(i);
    atlas_data_mod(logical(tmp.*all_left))  = new_idx_left(count);
    atlas_data_mod(logical(tmp.*all_right)) = new_idx_right(count);
    count = count + 1;
end

% Reshape to original atlas dimensions
atlas_data_mod = reshape(atlas_data_mod, size(atlas_data));

%% Write modified atlas and lookup file
% Modify the header
atlas_header.dt = [4,0];
atlas_header.fname = fullfile(atlas_path, [atlas_name, '_Modified_LR.nii']);

% Writing the modified atlas
spm_write_vol(atlas_header, atlas_data_mod);

% Writing the lookup file
if ~isempty(new_names_list)
    filename = fullfile(lookup_path, [lookup_name, '_Modified_LR.txt']);
    fid = fopen(filename, 'w');
    for i = 1:length(new_idx_list)
        fprintf(fid, '%d\t%s\r\n', new_idx_list(i), new_names_list{i});
    end
    fclose(fid);
end
