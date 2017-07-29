function [lookup_path, lookup_name, lookup_idx, lookup_names] = ...
    get_lookup_data(path_to_lookup, append_undef, sort_data)
% Function that returns information about lookup tables
%% Input
% path_to_lookup:       tab separated text file with full path to lookup
%                       table; first column should have indices and
%                       second column should have names
% append_undef:         If 1, "0" and "Undefined" are added to lookup_idx
%                       and lookup_names respectively (after checking to
%                       ensure that they are not present)
% sort_data:            If 1, lookup_data is sorted in ascending order and
%                       lookup_names is sorted accordingly
%
%% Outputs
% lookup_path:          Path to the lookup table
% lookup_name:          Name of the lookup table file
% lookup_idx:           Indices in the lookup table (numeric)
% lookup_names:         Names in the lookup table   (cell type string)
%
%% Notes
% If append_undef is 1, lookup_idx is internally sorted in ascending order
% first, before checking if the first entry is defined as "0"; "0" and
% "Undefined" are always added to the top of the list.
%
% The order of lookup_idx and lookup_names is only modified if sort_data is
% 1; if append_undef is 1 but sort_data is 0, "0" and "Undefined" are added
% to the top of the list but the rest of the list remains in the original
% order
%
%% Defaults
% append_undef    =     0
% sort_data       =     0
%
%% Author(s)
% Parekh, Pravesh
% July 24, 2017
% MBIAL

%% Evaluate inputs
if nargin < 1
    error('Insufficient number of inputs');
else
    if nargin == 1
        append_undef = 0;
        sort_data    = 0;
    else
        if nargin == 2
            sort_data = 0;
        else
            if isempty(append_undef)
                append_undef = 0;
            end
            if isempty(sort_data)
                sort_data = 0;
            end
        end
    end
end

%% Read and return lookup information
% Check if lookup table exists
if ~exist(path_to_lookup, 'file')
    error('Lookup file not found');
else
    [lookup_path, lookup_name, ext] = fileparts(path_to_lookup);
    % Make sure its a text file
    if ~strcmpi(ext, '.txt')
        error('Unrecognized extension; please specify text file');
    else
        % Read in data
        fid = fopen(path_to_lookup);
        lookup_data = textscan(fid, '%d %s', 'Delimiter', '\t');
        fclose(fid);
        % Check if data is of correct type
        if isnumeric(lookup_data{1}) && iscellstr(lookup_data{2})
            % Assign into output variables
            lookup_idx   = lookup_data{1};
            lookup_names = lookup_data{2};
            % Checking if append_undef is 1
            if append_undef == 1
                tmp_idx_list = sort(lookup_idx);
                if tmp_idx_list(1) ~= 0
                    lookup_idx      =   [0;             lookup_idx];
                    lookup_names    =   [{'Undefined'}; lookup_names];
                end
            end
            % Checking if sort_data is 1
            if sort_data == 1
                [lookup_idx, new_order] = sort(lookup_idx);
                lookup_names            = lookup_names(new_order);
            end
        else
            error('File is not organized correctly');
        end
    end
end