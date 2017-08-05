function modify_lookup(path_to_lookup, new_names_list, look_for, rep_underscores)
% Function to modify the lookup file for an atlas which already contains a
% left and right definition. This is useful to bring consistency between
% lookup files
%% Inputs:
% path_to_lookup:   full path to a text file having lookup entries
% new_names_list:   determine how left and right is specified in the new
%                   lookup table (optional; see Notes)
% rep_underscores:  replace underscores in names with white space [1/0]
%                   (optional)
% look_for:         explicitely tell the script how left and right entries
%                   are present in the lookup file (optional; see Notes)
%
%% The following inputs for new_names_list are supported:
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
% The index values are retained as such by the script (except in cases when
% "Undefined" entry is not already present)
%
% Undefined entry is added automatically to new_names_list, even if it is
% not present in the original file
%
% Modified lookup file is written in the same location with "_Modified"
% suffix
% 
%% Defaults:
% If new_names_list is not provided, "Left" is prefixed to existing name
% for left side and "Right" is prefixed to existing name for right side
%
% rep_underscores = 0
%
%% Author(s)
% Parekh, Pravesh
% July 10, 2017
% MBIAL

%% Check inputs
if nargin == 1
    new_names_list = 'lr prefix';
    rep_underscores = 0;
    look_for = 'search';
else
    if nargin == 2
        rep_underscores = 0;
        look_for = 'search';
    else
        if nargin == 3
            rep_underscores = 0;
        end  
    end
end

%% Read lookup file
[lookup_path, lookup_name, lookup_idx, old_names] = get_lookup_data(path_to_lookup, 1);
num_old_names = size(old_names, 1);

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
old_names_rem   = cell(num_old_names,1);
count_left      = 0;
count_right     = 0;
count_mid       = 0;
loc_left        = [];
loc_right       = [];
loc_mid         = [];

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
new_names = cell(size(old_names_rem));
switch(lower(new_names_list))
    case 'lr sh prefix'
        new_names(loc_left(:))  = strcat('L', {' '}, old_names_rem(loc_left));
        new_names(loc_right(:)) = strcat('R', {' '}, old_names_rem(loc_right));
        new_names(loc_mid(:))   = strcat(old_names_rem(loc_mid));
    case 'lr sh postfix'
        new_names(loc_left(:))  = strcat(old_names_rem(loc_left),  {' '}, 'L');
        new_names(loc_right(:)) = strcat(old_names_rem(loc_right), {' '}, 'R');
        new_names(loc_mid(:))   = strcat(old_names_rem(loc_mid));
    case 'lr prefix'
        new_names(loc_left(:))  = strcat('Left',  {' '}, old_names_rem(loc_left));
        new_names(loc_right(:)) = strcat('Right', {' '}, old_names_rem(loc_right));
        new_names(loc_mid(:))   = strcat(old_names_rem(loc_mid));
    case 'lr postfix'
        new_names(loc_left(:))  = strcat(old_names_rem(loc_left),  {' '}, 'Left');
        new_names(loc_right(:)) = strcat(old_names_rem(loc_right), {' '}, 'Right');
        new_names(loc_mid(:))   = strcat(old_names_rem(loc_mid));
    otherwise
        error('Unable to create new_names');
end

%% Handle underscores
% If underscores were replaced, and user wants them, put them back in
if underscore_flag == 1 && rep_underscores == 0
    new_names= strrep(strtrim(new_names), ' ', '_');
end

%% Add indices to new_names before writing
new_names = [num2cell(lookup_idx), new_names];

%% Write new lookup table
filename = fullfile(lookup_path, [lookup_name, '_Modified.txt']);
fid = fopen(filename, 'w');
for i = 1:size(new_names,1)
    if i == size(new_names,1)
        % Prevent extra line to be written at the end of file
        fprintf(fid, '%d\t%s', new_names{i,1}, new_names{i,2});
    else
        fprintf(fid, '%d\t%s\r\n', new_names{i,1}, new_names{i,2});
    end
end
fclose(fid);