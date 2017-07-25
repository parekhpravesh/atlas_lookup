function [lookup_path, lookup_name, lookup_idx, lookup_names] = get_lookup_data(path_to_lookup)
% Function that returns information about lookup tables
%% Input
% path_to_lookup:       Tab separated text file with full path to lookup
%                       table; first column should have indices and
%                       second column should have names
%
%% Outputs
% lookup_path:          Path to the lookup table
% lookup_name:          Name of the lookup table file
% lookup_idx:           Indices in the lookup table (numeric)
% lookup_names:         Names in the lookup table   (cell type string)
%
%% Author(s)
% Parekh, Pravesh
% July 24, 2017
% MBIAL
%

%%
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
        else
            error('File is not organized correctly');
        end
    end
end