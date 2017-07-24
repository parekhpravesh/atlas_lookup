function modify_lookup(lookup_name, new_names, rep_underscores, output_dir, look_for)
% Function to modify the lookup file for an atlas which already contains a
% left and right definition. This is useful to bring consistency between
% lookup files
%% Inputs:
% lookup_name:      full path to a text file having lookup entries
% new_names:        determine how left and right is specified in the new
%                   lookup table (optional; see Notes)
% rep_underscores:  replace underscores in names with white space [1/0]
%                   (optional)
% output_dir:       path where the new lookup file will be written
%                   (optional; see Notes)
% look_for:         explicitely tell the script how left and right entries
%                   are present in the lookup file (optional; see Notes)
%
%% The following inputs for new_names are supported:
% 'lr sh prefix'	changes left and right to 'L' and 'R' prefix
% 'lr sh postfix'	changes left and right to 'L' and 'R' postfix
% 'lr prefix'       changes left and right to 'Left' and 'Right' as prefix
% 'lr postfix'      changes left and right to 'Left' and 'Right' as postfix
%
%%  The following inputs for look_for are supported (case insensitive):
% 'lr sh prefix'    left and right are defined as 'L' and 'R' prefix
% 'lr sh postfix'   left and right are defined as 'L' and 'R' postfix
% 'lr prefix'       left and right are defined as 'Left' and 'Right' prefix
% 'lr postfix'      left and right are defined as 'Left' and 'Right' postfix
%
%% Notes
% If look_for variable is provided, the script will skip pattern searching
% and follow the style mentioned in look_for
%
% If output_dir already contains a file of the same name, the old file will
% be backed up and the new file will be created
%
% The index values are retained as such by the script (except in cases when
% "Undefined" entry is not already present)
%
% Undefined entry is added automatically to new_names, even if it is not
% present in the original file; script checks the first entry of
% lookup_name and if it is not "Undefined", it will be added to new_names;
% an index value of "0" is added at the top to correspond to "Undefined"
%
%% Default cases:
% If new_names is not provided, "Left" is prefixed to existing name for
% left side and "Right" is prefixed to existing name for right side
%
% If output_dir is not provided, a folder named 'Modified' is created and
% the new lookup file is written inside it
%
% By default, underscores are not replaced with white space
%
%% Author(s)
% Parekh, Pravesh
% July 10, 2017
% MBIAL

%% Check inputs
if nargin == 1
    new_names = 'lr prefix';
    rep_underscores = 0;
    output_dir = 'default';
    look_for = 'search';
else
    if nargin == 2
        rep_underscores = 0;
        output_dir = 'default';
        look_for = 'search';
    else
        if nargin == 3
            output_dir = 'default';
            look_for = 'search';
        else
            if nargin == 4
                look_for = 'search';
            end
        end
    end
end

%% Evaluate lookup_name
if ~exist(lookup_name, 'file')
    error('Cannot find lookup_name file');
else
    % Read the text file and figure out the content
    [rootdir, file_name, ~] = fileparts(lookup_name);
    fid = fopen(lookup_name, 'r');
    tmp_data = textscan(fid, '%s %s', 'Delimiter', '\t');
    % Check if second column exists
    if isempty(tmp_data{2}{1})
        tmp_data(2) = [];
        old_names = tmp_data{1};
    else
        % If two columns exist, figure out which is new_names and
        % which is new_idx column
        if isnumeric(str2double(tmp_data{1}))
            old_names = tmp_data{2};
        else
            if isnumeric(str2double(tmp_data{2}))
                old_names = tmp_data{1};
            else
                error('Text file is not organized properly');
            end
        end
    end
    num_old_names = size(old_names, 1);
end

%% Evaluate output_dir
if strcmpi(output_dir, 'default')
    output_dir = fullfile(rootdir, 'Modified');
    if ~exist(fullfile(rootdir, 'Modified'), 'dir')
        mkdir(fullfile(rootdir, 'Modified'));
    end
else
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
end

%% Checking Undefined entry
if strcmpi(old_names{1}, 'Undefined')
    undef_flag = 1;
else
    undef_flag = 0;
end

%% Check and replace all underscores in existing names with spaces
tmp = strsplit(old_names{2}, '_');
if length(tmp) > 1
    old_names = strrep(strtrim(old_names), '_', ' ');
    underscore_flag = 1;
else
    underscore_flag = 0;
end

%% Evaluate look_for and get names after removing left and right
% Initialize old_names_rem and counter variables
old_names_rem = cell(num_old_names,1);
count_left  = 0;
count_right = 0;
count_mid   = 0;
loc_left = [];
loc_right = [];
loc_mid = [];

% Search for look_for pattern
if strcmpi(look_for, 'search')
    % Loop till a pattern is found
    for i = 1:num_old_names
        to_search_in = strsplit(strtrim(old_names{i}), ' ');
        % Check if 'lr sh prefix' pattern exists
        if strcmpi(to_search_in{1}, 'l') || ...
                strcmpi(to_search_in{1}, 'r')
            look_for = 'lr sh prefix';
            break
        else
            % Check if 'lr sh postfix' pattern exists
            if strcmpi(to_search_in{end}, 'l') || ...
                    strcmpi(to_search_in{end}, 'r')
                look_for = 'lr sh postfix';
                break
            else
                % Check if 'lr prefix' pattern exists
                if strcmpi(to_search_in{1}, 'left') || ...
                        strcmpi(to_search_in{1}, 'right')
                    look_for = 'lr prefix';
                    break
                else
                    % Check if 'lr postfix' pattern exists
                    if strcmpi(to_search_in{end}, 'left') || ...
                            strcmpi(to_search_in{end}, 'right')
                        look_for = 'lr postfix';
                        break
                    else
                        continue
                    end
                end
            end
        end
    end
end

% Now remove the left and right tags
switch(lower(look_for))
    case 'lr sh prefix'
        for i = 1:num_old_names
            to_search_in = strsplit(strtrim(old_names{i}), ' ');
            if strcmpi(to_search_in{1}, 'l')
                count_left = count_left + 1;
                loc_left(count_left) = i;
                to_search_in = strcat(to_search_in, {' '});
                old_names_rem{i} = strtrim([to_search_in{2:end}]);
            else
                if strcmpi(to_search_in{1}, 'r')
                    count_right = count_right + 1;
                    loc_right(count_right) = i;
                    to_search_in = strcat(to_search_in, {' '});
                    old_names_rem{i} = strtrim([to_search_in{2:end}]);
                else
                    count_mid = count_mid + 1;
                    loc_mid(count_mid) = i;
                    to_search_in = strcat(to_search_in, {' '});
                    old_names_rem{i} = strtrim([to_search_in{1:end}]);
                end
            end
        end
    case 'lr sh postfix'
        for i = 1:num_old_names
            to_search_in = strsplit(strtrim(old_names{i}), ' ');
            if strcmpi(to_search_in{end}, 'l')
                count_left = count_left + 1;
                loc_left(count_left) = i;
                to_search_in = strcat(to_search_in, {' '});
                old_names_rem{i} = strtrim([to_search_in{1:end-1}]);
            else
                if strcmpi(to_search_in{end}, 'r')
                    count_right = count_right + 1;
                    loc_right(count_right) = i;
                    to_search_in = strcat(to_search_in, {' '});
                    old_names_rem{i} = strtrim([to_search_in{1:end-1}]);
                else
                    count_mid = count_mid + 1;
                    loc_mid(count_mid) = i;
                    old_names_rem{i} = strtrim([to_search_in{1:end}]);
                end
            end
        end
    case 'lr prefix'
        for i = 1:num_old_names
            to_search_in = strsplit(strtrim(old_names{i}), ' ');
            if strcmpi(to_search_in{1}, 'left')
                count_left = count_left + 1;
                loc_left(count_left) = i;
                to_search_in = strcat(to_search_in, {' '});
                old_names_rem{i} = strtrim([to_search_in{2:end}]);
            else
                if strcmpi(to_search_in{1}, 'right')
                    count_right = count_right + 1;
                    loc_right(count_right) = i;
                    to_search_in = strcat(to_search_in, {' '});
                    old_names_rem{i} = strtrim([to_search_in{2:end}]);
                else
                    count_mid = count_mid + 1;
                    loc_mid(count_mid) = i;
                    old_names_rem{i} = strtrim([to_search_in{1:end}]);
                end
            end
        end
    case 'lr postfix'
        for i = 1:num_old_names
            to_search_in = strsplit(strtrim(old_names{i}), ' ');
            if strcmpi(to_search_in{end}, 'left')
                count_left = count_left + 1;
                loc_left(count_left) = i;
                to_search_in = strcat(to_search_in, {' '});
                old_names_rem{i} = strtrim([to_search_in{1:end-1}]);
            else
                if strcmpi(to_search_in{end}, 'right')
                    count_right = count_right + 1;
                    loc_right(count_right) = i;
                    to_search_in = strcat(to_search_in, {' '});
                    old_names_rem{i} = strtrim([to_search_in{1:end-1}]);
                else
                    count_mid = count_mid + 1;
                    loc_mid(count_mid) = i;
                    old_names_rem{i} = strtrim([to_search_in{1:end}]);
                end
            end
        end
    otherwise
        error('Unknown look_for pattern');
end

%% Evaluate new_names
new_names_list = cell(size(old_names_rem));
switch(lower(new_names))
    case 'lr sh prefix'
        new_names_list(loc_left(:))  = strcat('L', {' '}, old_names_rem(loc_left));
        new_names_list(loc_right(:)) = strcat('R', {' '}, old_names_rem(loc_right));
        new_names_list(loc_mid(:))   = strcat(old_names_rem(loc_mid));
    case 'lr sh postfix'
        new_names_list(loc_left(:))  = strcat(old_names_rem(loc_left),  {' '}, 'L');
        new_names_list(loc_right(:)) = strcat(old_names_rem(loc_right), {' '}, 'R');
        new_names_list(loc_mid(:))   = strcat(old_names_rem(loc_mid));
    case 'lr prefix'
        new_names_list(loc_left(:))  = strcat('Left',  {' '}, old_names_rem(loc_left));
        new_names_list(loc_right(:)) = strcat('Right', {' '}, old_names_rem(loc_right));
        new_names_list(loc_mid(:))   = strcat(old_names_rem(loc_mid));
    case 'lr postfix'
        new_names_list(loc_left(:))  = strcat(old_names_rem(loc_left),  {' '}, 'Left');
        new_names_list(loc_right(:)) = strcat(old_names_rem(loc_right), {' '}, 'Right');
        new_names_list(loc_mid(:))   = strcat(old_names_rem(loc_mid));
    otherwise
        error('Unable to create new_names');
end

%% Handle underscores
% If underscores were replaced, and user wants them, put them back in
if underscore_flag == 1 && rep_underscores == 0
    new_names_list = strrep(strtrim(new_names_list), ' ', '_');
end

%% Handle undefined entry
tmp_data{:,2} = new_names_list;
if undef_flag == 0
    tmp_data{1,1} = ['0'; tmp_data{1,1}];
    tmp_data{1,2} = [{'Undefined'}; tmp_data{1,2}];
end

%% Write new lookup table
filename = fullfile(output_dir, [file_name, '.txt']);
% Don't overwrite existing file
if exist(filename, 'file')
    filename = fullfile(output_dir, [file_name, '_Modified.txt']);
end
fid = fopen(filename, 'w');
for i = 1:length(tmp_data{1})
    if i == length(tmp_data{1})
        % Prevent extra line to be written at the end of file
        fprintf(fid, '%s\t%s', tmp_data{1}{i}, tmp_data{2}{i});
    else
        fprintf(fid, '%s\t%s\r\n', tmp_data{1}{i}, tmp_data{2}{i});
    end
end
fclose(fid);