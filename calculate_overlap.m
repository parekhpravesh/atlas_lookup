function [results, overlap_results] = calculate_overlap(db_location, save_dir, num_rois)
% Function to calculate overlap percentage of regions between different
% brain atlases that have been defined in the database
% Parekh, Pravesh
% MBIAL
% May 10, 2017

load(db_location);
num_atlases = abs(size(database_intensity,2)-3);
overall_set = 1:num_atlases;
database_intensity_work = database_intensity(:, 4:end);

fid_all = fopen(fullfile(save_dir, ['overlap_all_', num2str(num_rois), '.txt']), 'w');
formatSpec = [repmat('%s\t', 1, num_atlases-1), '\r\n'];

% Loop over atlases (source)
for source = 1:num_atlases
    destination = setdiff(overall_set, source);
    rois_source = cell2mat(database_labels{source}(:, 1));
    num_source_rois = length(rois_source);
    
    % Get source atlas name and replace blanks with underscores
    source_name = header{source+3};
    source_name = strrep(source_name, ' ', '_');
    results.(source_name).name = header{source+3};
    
    fid_source = fopen(fullfile(save_dir, ['overlap_', source_name, '_', num2str(num_rois), '.txt']), 'w');
    
    % Write all destination atlases as header
    fprintf(fid_all, '%s\r\n', source_name);
    fprintf(fid_all, '%s\t', 'Source_ROI_Name');
    fprintf(fid_all, formatSpec, header{3+destination});
    fprintf(fid_source, '%s\t', 'Source_ROI_Name');
    fprintf(fid_source, formatSpec, header{3+destination});
    
    % Loop over each ROI in source atlas
    for rois = 1:num_source_rois
        
        % Assigning number for source atlas ROIs
        source_roi_loc = cell2mat(database_labels{source}(:,1)) == rois_source(rois);
        source_roi_name = database_labels{source}(source_roi_loc, 2);
        source_roi_number = ['ROI', num2str(rois)];
        
        % Find rows of source atlas which correspond to this ROI
        source_rows = (database_intensity_work(:, source) == rois_source(rois));
        
        % Write ROI name in file
        fprintf(fid_all, '%s\t', source_roi_name{:});
        fprintf(fid_source, '%s\t', source_roi_name{:});
        
        % Loop over all non-source (destination) atlases
        for dest = 1:length(destination)
            
            % Get destination atlas name and replace blanks with
            % underscores
            destination_name = header{destination(dest)+3};
            destination_name = strrep(destination_name, ' ', '_');
            
            % Tabulate results and assign in structure
            
            % Tabulate sorted results (descending) as matrix
            results.(source_name).(destination_name).(source_roi_number).mat = ...
                sortrows(tabulate(database_intensity_work(source_rows, destination(dest))), -3);
            
            % Save source ROI index/number
            results.(source_name).(destination_name).(source_roi_number).source_idx = ...
                rois_source(rois);
            
            % Save source ROI name
            results.(source_name).(destination_name).(source_roi_number).source_name = ...
                source_roi_name;
            
            % Making a vector of all ROI indices in destination atlas
            tmp_dest_mat = cell2mat(database_labels{destination(dest)}(:,1));
            
            % Loop over every tabulated entry to find name of the ROI in
            % destination atlas
            for i = 1:size(results.(source_name).(destination_name).(source_roi_number).mat,1)
                loc = tmp_dest_mat == results.(source_name).(destination_name).(source_roi_number).mat(i,1);
                read_out{i,1} = database_labels{destination(dest)}(loc,2);
            end
            
            % Concatenating the tabulated matrix and the names
            results.(source_name).(destination_name).(source_roi_number).res = ...
                [read_out, num2cell(results.(source_name).(destination_name).(source_roi_number).mat)];
            
            % Handling cases when number of overlapping ROIs are lesser than num_rois
            num_tab_rows = size(results.(source_name).(destination_name).(source_roi_number).res,1);
            if num_tab_rows >= num_rois
                overlap_results.(source_name).(destination_name).(source_roi_number).mat = ...
                    results.(source_name).(destination_name).(source_roi_number).res(1:num_rois,:);
            else
                tmp = num_rois - size(results.(source_name).(destination_name).(source_roi_number).res,1);
                overlap_results.(source_name).(destination_name).(source_roi_number).mat = ...
                    [results.(source_name).(destination_name).(source_roi_number).res(1:num_tab_rows,:); cell(tmp,4)];
            end
            
            clear read_out loc tmp_dest_mat tmp num_tab_rows
        end
        
        % Write name and percentage overlap in file
        for write_rois = 1:num_rois
            for dest = 1:length(destination)
                % Get destination atlas name and replace blanks with
                % underscores
                destination_name = header{destination(dest)+3};
                destination_name = strrep(destination_name, ' ', '_');
                
                % Merging name and percentage as a string
                if ~isempty(overlap_results.(source_name).(destination_name).(source_roi_number).mat{write_rois, 1})
                    tmp_text = [overlap_results.(source_name).(destination_name).(source_roi_number).mat{write_rois, 1}{1}, ' (', num2str(overlap_results.(source_name).(destination_name).(source_roi_number).mat{write_rois, 4}), '%)'];
                else
                    tmp_text = 'None (0.0%)';
                end
                
                % Writing to file
                fprintf(fid_all, '%s\t', tmp_text);
                fprintf(fid_source, '%s\t', tmp_text);
                clear tmp_text;
            end

            if write_rois == num_rois
                fprintf(fid_all, '\r\n');
                fprintf(fid_source, '\r\n');
            else
                fprintf(fid_all, '\r\n\t');
                fprintf(fid_source, '\r\n\t');
            end
        end
        % Blank line after every source ROI
        fprintf(fid_all, '\r\n');
        fprintf(fid_source, '\r\n');
        
    end
    % Two blank lines after every atlas
    fprintf(fid_all, '\r\n\r\n');
    fclose(fid_source);
end
fclose(fid_all);

% Saving variables
cd(save_dir);
save(fullfile(save_dir, 'overlap_all.mat'), 'results', 'overlap_results');
save(fullfile(save_dir, ['overlap_', num2str(num_rois), '.mat']), 'overlap_results');