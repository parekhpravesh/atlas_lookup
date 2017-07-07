function [new_idx, new_names] = modify_atlas_lr(atlas_name, lookup_name, new_idx, new_names)
% Function to modify an atlas to include the left and right sided labels
%% Inputs:
% atlas_name:       path to an SPM readable image file having labels
% lookup_name:      path to a tab separated text file having names for
%                   these labels (should have two columns: one having
%                   intensities and one having labels) (can be empty if
%                   only atlas is to be modified; see Notes)
% new_idx:          indices which would replace the existing ones in the
%                   atlas
% new_names:        new names which would replace existing names in
%                   the lookup table
%
%% The following inputs for new_idx are supported:
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
%% The following inputs for new_names are supported:
% 'lr sh prefix'	add 'L' and 'R' as prefix to existing names
% 'lr sh postfix'	add 'L' and 'R' as postfix to existing names
% 'lr prefix'       add 'Left' and 'Right' as prefix to existing names
% 'lr postfix'      add 'Left' and 'Right' as postfix to existing names
% a cell array of names
% path to a text file with a column of names
% path to a tab separated text file with intensities and names (see Notes)
%
%% Notes:
% new_names provided along with new_idx will be ignored if fourth argument
% is passed
%
% new_idx provided with new_names will be ignored
%
% If dividing new_idx by a number result in fractional values, operation
% will generate an error and atlas will not be modified
%
% It is optional to define "0" in the new_idx list and "Undefined" in the
% new_names list; if they are not specified, they will be automatically
% added to the written files

% In case "Undefined" is entered as something else in the input (for
% example, "Undef" etc.), script assumes that "Undefined" is not present
% and will force an additional entry of "Undefined" into the new_names
% list, leading to an error during sanity check
%
% x<0 is treated as left and x>=0 is treated as right; therefore, midline
% coordinates are clubbed with right side.
%
% It is possible to modify only the atlas without modifying the lookup
% table. This can be done in two ways:
%   Only input atlas_name and the new atlas will be created using default
%   case for new_idx
%   Altenatively, input atlas_name, '' for lookup_name, and new_idx, and
%   the new atlas will be created using the new_idx inputs
%
%% Default cases:
% If new_idx is not provided, 1000 is added to existing intensities for
% left side and 2000 is added to existing intensities for right side
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
    lookup_name = '';
    new_idx = 'default';
    new_names = '';
else
    if nargin == 2
        new_idx = 'default';
        new_names = 'default';
    else
        if nargin == 3
            new_names = 'default';
        end
    end
end

%% Evaluate atlas_name input
atlas_header = spm_vol(atlas_name);
[atlas_data, atlas_xyz] = spm_read_vols(atlas_header);
[atlas_path, atlas_name] = fileparts(atlas_header.fname);
atlas_xyz = atlas_xyz(1:3,:)';
all_labels = unique(atlas_data(:));
num_labels = length(all_labels);

%% Evaluate lookup_name input
% Checking if lookup_name is empty
if isempty(lookup_name)
    new_names = '';
else
    if ischar(lookup_name)
        % Check if text file is given
        if ~(strcmpi(lookup_name, 'default') || isempty(lookup_name))
            [~,~,ext] = fileparts(lookup_name);
            if strcmpi(ext, '.txt')
                % If text file is given, read lookup data
                fid = fopen(lookup_name);
                lookup_data = textscan(fid, '%d %s', 'Delimiter', '\t');
                fclose(fid);
            else
                error('Unable to process lookup_name input');
            end
        end
    else
        error('Unable to process lookup_name input');
    end
end

%% Evaluate new_idx input
flag = 0;
if ischar(new_idx)
    % Check if text file is given
    [~,~,ext] = fileparts(new_idx);
    if strcmpi(ext, '.txt')
        % Read the file and get the new_idx
        fid = fopen(new_idx, 'r');
        tmp_data = textscan(fid, '%s %s', 'Delimiter', '\t');
        fclose(fid);
        % Check second column
        if isempty(tmp_data{2}{1})
            tmp_data(2) = [];
            % If it is numeric
            if isnumeric(str2double(tmp_data{1}))
                new_idx = str2double(tmp_data{1})';
            else
                error('Unable to process text file');
            end
        else
            % If two columns exist, figure out which is new_names and which
            % is new_idx column
            if isnumeric(str2double(tmp_data{1}))
                new_idx = str2double(tmp_data{1});
                new_names_tmp = tmp_data{2};
                flag = 1;
            else
                if isnumeric(str2double(tmp_data{2}))
                    new_idx = str2double(tmp_data{2});
                    new_names_tmp = tmp_data{1};
                    flag = 1;
                else
                    error('Text file is not organized properly');
                end
            end
        end
    else
        % If not a text file, figure out what to do
        switch(lower(new_idx))
            case 'serialize'
                new_idx = 0:(num_labels-1)*2;
            case 'default'
                tmp_list = all_labels(2:end); % First value is zero
                new_idx = [0; tmp_list+1000; tmp_list+2000];
            otherwise
                % Figure out operation type, n, and m
                tmp_op = strsplit(new_idx);
                if length(tmp_op) ~= 3
                    error('Unable to process new_idx input');
                else
                    operation_type = tmp_op{1};
                    n = str2double(tmp_op{2});
                    m = str2double(tmp_op{3});
                    tmp_list = all_labels(2:end); % First value is zero
                    switch(lower(operation_type))
                        case 'add'
                            new_idx = [0; tmp_list+n; tmp_list+m];
                        case 'sub'
                            new_idx = [0; tmp_list-n; tmp_list-m];
                        case 'mul'
                            new_idx = [0; tmp_list*n; tmp_list*m];
                        case 'div'
                            new_idx = [0; tmp_list/n; tmp_list/m];
                        otherwise
                            error('Unable to process new_idx input');
                    end
                end
        end
    end
else
    if iscell(new_idx)
        % Check if 1D cell is input
        if size(new_idx,2) == 1
            if isnumeric(new_idx{1})
                new_idx = new_idx{1};
            else
                error('Unable to process new_idx input');
            end
        else
            % Check if 2D cell is input
            if size(new_idx,2) == 2
                tmp_data = new_idx;
                % Figure out which column is index and which is names
                if iscell(tmp_data{2}) && isnumeric(tmp_data{1})
                    new_names_tmp = tmp_data{2};
                    new_idx = tmp_data{1};
                    flag = 1;
                else
                    if iscell(tmp_data{1}) && isnumeric(tmp_data{2})
                        new_names_tmp = tmp_data{1};
                        new_idx = tmp_data{2};
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
        if ~isnumeric(new_idx)
            error('Unknown type of input for new_idx');
        end
    end
end

% Check if new_idx is a column vector or not
if isrow(new_idx)
    new_idx = new_idx';
end

% Check if zero exists in new_idx
if isempty(intersect(0, new_idx))
    new_idx = [0; new_idx];
end

%% Evaluate new_names input
% If new_idx had names and fourth argument was not passed, names passed
% with new_idx names get selected
if flag == 1 && nargin <=3
    new_names = new_names_tmp;
else
    % Quick test for the empty case
    if isempty(new_names)
        new_names = '';
    else
        if ischar(new_names)
            % Check if text file is input
            [~,~,ext] = fileparts(new_names);
            if strcmpi(ext, '.txt')
                fid = fopen(new_names, 'r');
                tmp_data = textscan(fid, '%s %s', 'Delimiter', '\t');
                % Check if second column exists
                if isempty(tmp_data{2}{1})
                    tmp_data(2) = [];
                    new_names = tmp_data{1};
                else
                    % If two columns exist, figure out which is new_names and
                    % which is new_idx column
                    if isnumeric(str2double(tmp_data{1}))
                        new_names = tmp_data{2};
                    else
                        if isnumeric(str2double(tmp_data{2}))
                            new_names = tmp_data{1};
                        else
                            error('Text file is not organized properly');
                        end
                    end
                end
            else
                switch(lower(new_names))
                    case 'lr sh prefix'
                        new_names = [{'Undefined'}; ...
                            strcat({'L '},      deblank(lookup_data{1,2})); ...
                            strcat({'R '},      deblank(lookup_data{1,2}))];
                    case 'lr sh postfix'
                        new_names = [{'Undefined'}; ...
                            strcat(deblank(lookup_data{1,2}), {' L'}); ...
                            strcat(deblank(lookup_data{1,2}), {' R'})];
                    case 'lr prefix'
                        new_names = [{'Undefined'}; ...
                            strcat({'Left '},   deblank(lookup_data{1,2})); ...
                            strcat({'Right '},  deblank(lookup_data{1,2}))];
                    case 'lr postfix'
                        new_names = [{'Undefined'}; ...
                            strcat(deblank(lookup_data{1,2}), {' Left'}); ...
                            strcat(deblank(lookup_data{1,2}), {' Right'})];
                    case 'default'
                        new_names = [{'Undefined'}; ...
                            strcat({'Left '},   deblank(lookup_data{1,2})); ...
                            strcat({'Right '},  deblank(lookup_data{1,2}))];
                    otherwise
                        error('Unable to process new_names input');
                end
            end
        else
            if iscell(new_names)
                % Check if 1D cell is input
                if size(new_names,2) == 1
                    new_names = new_names{1};
                else
                    % Check if 2D cell is input
                    if size(new_names,2) == 2
                        tmp_data = new_idx;
                        % Figure out which column is index and which is names
                        if isnumeric(str2double(tmp_data{1}))
                            new_names = tmp_data{2};
                        else
                            if isnumeric(str2double(tmp_data{2}))
                                new_names = tmp_data{1};
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

% Check if Undefined entry exists
if ~isempty(new_names) && isempty(intersect('undefined', lower(new_names)))
    new_names = [{'Undefined'}; new_names];
end

%% Sanity check
% Poofing
assignin('base','new_idx',new_idx);
assignin('base','new_names',new_names);

% Number of entries in new_idx should be equal to twice the number of
% unique entries in the atlas (excluding the zero entry)
if length(new_idx) ~= (num_labels*2)-1
    error('Incorrect number of new_idx');
end

% Number of entries in the new_names should be equal to twice the number of
% unique entries in the atlas (excluding the zero entry)
if ~isempty(new_names) && length(new_names) ~= (num_labels*2)-1
    error('Incorrect number of new_labels');
end

% Check each entry of new_names to ensure that no empty entries exist
if ~isempty(new_names)
    for tmp = 1:length(new_names)
        if isempty(new_names{tmp})
            error('Incorrect number of new_labels');
        end
    end
end

% Checking for duplicate new values
new_uniques = unique(new_idx);
if length(new_uniques) ~= length(new_idx)
    error('Duplicate values in new_idx');
end

% Checking overlap of new and old indices
if ~isempty(intersect(nonzeros(new_idx), nonzeros(all_labels)))
    warning('Old and new indices overlap!');
end

% Checking if new indices have any fractional values
if sum(floor(new_idx) == new_idx) ~= length(new_idx)
    error('Non-integer indices');
end

%% Left and right coordinates and new indices 
% All left and right coordinates
all_left = atlas_xyz(:,1)  <  0;
all_right = atlas_xyz(:,1) >= 0;

% All left and right new coordinates (except zero)
new_idx_left  = new_idx(2:num_labels);      % Skipping first entry (zero)
new_idx_right = new_idx(num_labels+1:end);

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
atlas_header.fname = fullfile(atlas_path, 'Modified', [atlas_name, '.nii']);

% Writing the modified atlas
cd(atlas_path);
if ~exist('Modified', 'dir')
    mkdir('Modified');
end
spm_write_vol(atlas_header, atlas_data_mod);

% Writing the lookup file
if ~isempty(new_names)
    filename = fullfile(atlas_path, 'Modified', [atlas_name, '.txt']);
    fid = fopen(filename, 'w');
    for i = 1:length(new_idx)
        fprintf(fid, '%d\t%s\r\n', new_idx(i), new_names{i});
    end
    fclose(fid);
end
