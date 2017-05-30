function [results, overlap_results] = calculate_overlap(num_rois)
% Function to calculate overlap percentage of regions between different
% brain atlases that have been defined in the database
% Parekh, Pravesh
% MBIAL
% May 10, 2017

if nargin == 0
    num_rois = 3;
end

load('database.mat');
num_atlases = abs(size(database_intensity,2)-3);
overall_set = 1:num_atlases;
database_intensity_work = database_intensity(:, 4:end);

% Loop over atlases (source)
for source = 1:num_atlases
    destination = setdiff(overall_set, source);
    rois_source = cell2mat(database_labels{source}(:, 1));
    num_source_rois = length(rois_source);
    
    % Get source atlas name and replace blanks with underscores
    source_name = header{source+3};
    source_name = strrep(source_name, ' ', '_');
    results.(source_name).name = header{source+3};
     
    % Loop over each ROI in source atlas
    for rois = 1:num_source_rois
        
        % Assigning number for source atlas ROIs
        source_roi_loc = cell2mat(database_labels{source}(:,1)) == rois_source(rois);
        source_roi_name = database_labels{source}(source_roi_loc,2);
        source_roi_number = ['ROI', num2str(rois)];
        
        % Find rows of source atlas which correspond to this ROI
        source_rows = (database_intensity_work(:, source) == rois_source(rois));
        
        % Loop over all non-source (destination) atlases
        for dest = 1:length(destination)
            
            % Get destination atlas name and replace blanks with
            % underscores
            destination_name = header{destination(dest)+3};
            destination_name = strrep(destination_name, ' ', '_');
            
            % Tabulate results and assign in structure
            
            % Tabulate sorted results (descending) as matrix
            results.(source_name).(destination_name).(source_roi_number).mat = sortrows(tabulate(database_intensity_work(source_rows, destination(dest))), -3);

            % Save source ROI index/number
            results.(source_name).(destination_name).(source_roi_number).source_idx = rois_source(rois);
            
            % Save source ROI name
            results.(source_name).(destination_name).(source_roi_number).source_name = source_roi_name;
            
            % Making a vector of all ROI indices in destination atlas
            tmp_dest_mat = cell2mat(database_labels{destination(dest)}(:,1));
            
            % Loop over every tabulated entry to find name of the ROI in
            % destination atlas
            for i = 1:size(results.(source_name).(destination_name).(source_roi_number).mat,1)
                loc = tmp_dest_mat == results.(source_name).(destination_name).(source_roi_number).mat(i,1);
                read_out{i,1} = database_labels{destination(dest)}(loc,2);
            end
            
            % Concatenating the tabulated matrix and the names
            results.(source_name).(destination_name).(source_roi_number).res = [read_out, num2cell(results.(source_name).(destination_name).(source_roi_number).mat)];
            
            num_tab_rows = size(results.(source_name).(destination_name).(source_roi_number).res,1);
            if num_tab_rows >= num_rois
                overlap_results.(source_name).(destination_name).(source_roi_number).mat = results.(source_name).(destination_name).(source_roi_number).res(1:num_rois,:);
            else
                tmp = num_rois - size(results.(source_name).(destination_name).(source_roi_number).res,1);
                overlap_results.(source_name).(destination_name).(source_roi_number).mat = [results.(source_name).(destination_name).(source_roi_number).res(1:num_tab_rows,:); cell(tmp,4)];
            end
            
            clear read_out loc tmp_dest_mat tmp num_tab_rows
        end
    end
end