function atlas_lookup
% GUI for creation of database and labeling brain
% Parekh, Pravesh
% MBIAL
% May 02, 2017


% -------------------------------------------------------------------------
% Some variables/tags/functions described
% -------------------------------------------------------------------------
% help_icon:                icon file for dlgbox
% parent_figure:            main program figure
% button_save_enable_opts:  toggling save from options box in parent_figure
% disp_results:             toggling display of results in parent_figure
% save_results:             value for toggle save object in parent_figure
% toggle_save_results:      function for toggle save in parent_figure
% toggle_disp_results:      function for toggle display of results in
%                           parent figure
% tag_save_results:         tag for toggle saving results in parent figure
% tag_disp_results:         tag for toggle display of results in parent
%                           figure
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Global variables
% -------------------------------------------------------------------------
global help_icon parent_figure button_save_enable_opts disp_results save_results

help_icon = (fullfile(matlabroot, 'toolbox', 'matlab', 'uitools',...
    'private', 'icon_help_32.png'));

if exist(help_icon, 'file')
    help_icon = imread(help_icon);
else
    help_icon = imread('helpicon.gif');
end

button_save_enable_opts  = 'off';
disp_results = 0;
save_results = 0;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Create parent user interface
% -------------------------------------------------------------------------

% Parent figure
parent_figure = figure('units', 'normalized', 'position', ...
    [0.45 0.45 0.10 0.20], 'Name', 'Atlas Lookup', ...
    'numbertitle', 'off', 'MenuBar', 'none');

% Panels
head_panel = uipanel('parent', parent_figure, 'units', 'normalized', ...
    'position', [0.02 0.90 0.96 0.09], 'HighlightColor', 'black');

parent_panel = uipanel('parent', parent_figure, 'units', 'normalized', ...
    'position', [0.02 0.32 0.96 0.55], 'HighlightColor', 'black');

options_panel = uipanel('parent', parent_figure, 'units', 'normalized', ...
    'position', [0.02 0.02 0.96 0.27], 'HighlightColor', 'black');

% Heading
uicontrol('parent', head_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.01 0.01 1 1], 'String', 'A T L A S     L O O K U P', ...
    'FontName', 'Times', 'FontSize', 16, 'FontWeight', 'bold');

% Buttons in parent panel
uicontrol('parent', parent_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.28 0.70 0.5 0.20], 'String', ...
    'Create Database', 'FontSize', 12, 'callback', @create_db);

uicontrol('parent', parent_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.28 0.40 0.5 0.20], 'String', ...
    'Label Brain', 'FontSize', 12, 'callback', @label_call);

uicontrol('parent', parent_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.28 0.10 0.5 0.20], 'String', ...
    'Quit', 'FontSize', 12, 'callback', @quit);

% Options button
uicontrol('parent', options_panel, 'units', 'normalized', 'style', ...
    'togglebutton', 'position', [0.01 0.66 0.15 0.30], 'String', 'OFF', ...
    'FontSize', 12, 'ForegroundColor', 'red', 'tag', 'tag_disp_results', ...
    'callback', @toggle_disp_results, 'Value', 0);

uicontrol('parent', options_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.18 0.58 0.50 0.33], 'String', 'Display Results', ...
    'FontSize', 12, 'HorizontalAlignment', 'left');

uicontrol('parent', options_panel, 'units', 'normalized', 'style', ...
    'togglebutton', 'position', [0.01 0.28 0.15 0.30], 'String', 'OFF', ...
    'FontSize', 12, 'ForegroundColor', 'red', 'tag', 'tag_save_results', ...
    'callback', @toggle_save_results, 'Value', 0);

uicontrol('parent', options_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.18 0.20 0.50 0.33], 'String', 'Save Results', ...
    'FontSize', 12, 'HorizontalAlignment', 'left');

% Footer
uicontrol('parent', options_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.01 0.01 0.99 0.15], 'String', ...
    'Multimodal Brain Image Analysis Laboratory (MBIAL)');
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Callback functions
% -------------------------------------------------------------------------

% Callback for creating database
% -------------------------------------------------------------------------
function create_db(~, ~)
global db_wait_box help_icon

db_wait_box = figure('units', 'normalized', 'position', ...
    [0.45 0.45 0.10 0.05], 'Name', 'Creating Database', ...
    'numbertitle', 'off', 'MenuBar', 'none');

ax = axes('parent', db_wait_box, 'units', 'normalized', 'position', ...
    [0.02 0.4 0.15 0.5]);
imagesc(ax, help_icon);
axis off;

uicontrol(db_wait_box, 'units', 'normalized', 'style', 'text', ...
    'position', [0.20 0.60 0.60 0.20], 'String', 'Please Wait!', ...
    'FontSize', 12, 'HorizontalAlignment', 'left', 'tag', 'tag_db_text');

uicontrol(db_wait_box, 'units', 'normalized', 'style', 'pushbutton', ...
    'position', [0.45 0.10 0.2 0.3], 'String', 'OK', 'enable', 'off', ...
    'FontSize', 12, 'tag', 'tag_db_okay', 'callback', @close_db_wait_box);

shg
create_database

figure(db_wait_box);
handles_create_db = guihandles(db_wait_box);
handles_create_db .tag_db_text.String = 'Database Created!';
handles_create_db .tag_db_okay.Enable = 'on';
% -------------------------------------------------------------------------


% Callback for labeling brain
% -------------------------------------------------------------------------
function label_call(~, ~)
global db_location file_select_box input_file_location save_location ...
    button_label_enable
input_file_location = '';
save_location = '';

% Locate database file
install_dir = fileparts(which('label_brain'));
if ~exist(fullfile(install_dir, 'database', 'database.mat'), 'file')
    warndlg('Database file not found; please locate manually',...
        'Database not found');
    db_location = '';
    button_label_enable = 'off';
else
    db_location = fullfile(install_dir, 'database', 'database.mat');
    button_label_enable = 'on';
end

% Create figure for selecting files
file_select_box = figure('units', 'normalized', 'position', ...
    [0.56 0.57 0.10 0.08], 'Name', 'File Locations', ...
    'numbertitle', 'off', 'MenuBar', 'none');

uicontrol(file_select_box, 'units', 'normalized', 'style', 'pushbutton', ...
    'position', [0.02 0.80 0.22 0.18], 'String', 'Database ', ...
    'FontSize', 10, 'HorizontalAlignment', 'left', 'callback', @browse_db);

uicontrol(file_select_box, 'units', 'normalized', 'style', 'edit', ...
    'position', [0.26 0.80 0.72 0.18], 'enable', 'off', ...
    'tag', 'tag_db_loc_text', 'String', db_location, ...
    'HorizontalAlignment', 'left');

uicontrol(file_select_box, 'units', 'normalized', 'style', 'pushbutton', ...
    'position', [0.02 0.55 0.22 0.18], 'String', 'To Label ', ...
    'FontSize', 10, 'HorizontalAlignment', 'left','tag', 'tag_button_label', ...
    'callback', @browse_input, 'enable', button_label_enable);

uicontrol(file_select_box, 'units', 'normalized', 'style', 'edit', ...
    'position', [0.26 0.55 0.72 0.18], 'enable', 'off', ...
    'tag', 'tag_input_loc_text', 'String', input_file_location, ...
    'HorizontalAlignment', 'left');

uicontrol(file_select_box, 'units', 'normalized', 'style', 'pushbutton', ...
    'position', [0.02 0.30 0.22 0.18], 'String', 'Save Path', ...
    'FontSize', 10, 'HorizontalAlignment', 'left', 'tag', 'tag_button_save', ...
    'enable', 'off', 'callback', @browse_save);

uicontrol(file_select_box, 'units', 'normalized', 'style', 'edit', ...
    'position', [0.26 0.30 0.72 0.18], 'enable', 'off', ...
    'tag', 'tag_save_loc', 'String', save_location, ...
    'HorizontalAlignment', 'left');

uicontrol(file_select_box, 'units', 'normalized', 'style', 'text', ...
    'position', [0.02 0.02 0.22 0.18], 'String', 'Threshold ', ...
    'FontSize', 10);

uicontrol(file_select_box, 'units', 'normalized', 'style', 'edit', ...
    'position', [0.23 0.04 0.15 0.15], 'String', '0', ...
    'callback', @get_threshold);

uicontrol(file_select_box, 'units', 'normalized', 'style', 'pushbutton', ...
    'position', [0.68 0.04 0.30 0.15], 'String', 'Fetch Labels', ...
    'FontSize', 10, 'tag', 'tag_fetch_button', 'enable', 'off', ...
    'callback', @fetch_label_brain);
% -------------------------------------------------------------------------


% Callback for browse database
% -------------------------------------------------------------------------
function browse_db(~, ~)
global db_location file_select_box input_file_location button_label_enable
db_location = uigetdir(pwd, 'Select database directory');

if exist(fullfile(db_location, 'database.mat'), 'file')
    db_location = fullfile(db_location, 'database.mat');
    button_label_enable = 'on';
else
    db_location = '';
    warndlg('Database file not found in this location', 'Database not found');
    button_label_enable = 'off';
end

handles_db = guihandles(file_select_box);
handles_db.tag_button_label.Enable = button_label_enable;
handles_db.tag_db_loc_text.String = db_location;

if ~isempty(db_location) && ~isempty(input_file_location)
    handles_db.tag_fetch_button.Enable = 'on';
else
    handles_db.tag_fetch_button.Enable = 'off';
end
% -------------------------------------------------------------------------


% Callback for browse input file
% -------------------------------------------------------------------------
function browse_input(~, ~)
global file_select_box input_file_location db_location button_save_enable_opts save_location
[input_file, input_path] = uigetfile({'*.txt'; '*.nii'; '*.img'; '*.hdr'},...
    'Select the file to label');
if exist(fullfile(input_path, input_file), 'file')
    input_file_location = fullfile(input_path, input_file);
else
    input_file_location = '';
end

handles_input = guihandles(file_select_box);
handles_input.tag_button_save.Enable = button_save_enable_opts;
update_save

handles_input.tag_input_loc_text.String = input_file_location;

if (~strcmp(db_location, '') && ~strcmp(input_file_location, ''))
    if (strcmp(button_save_enable_opts, 'on') && ~strcmp(save_location, '')) ||...
            strcmp(button_save_enable_opts, 'off')
        handles_input.tag_fetch_button.Enable = 'on';
    end
else
    handles_input.tag_fetch_button.Enable = 'off';
end
% -------------------------------------------------------------------------


% Callback for browse save location
% -------------------------------------------------------------------------
function browse_save(~, ~)
global file_select_box save_location input_file_location button_save_enable_opts
if strcmp(button_save_enable_opts, 'on')
    if ~strcmp(input_file_location, '')
        save_path = uigetdir(input_file_location, 'Select save directory');
        [~, input_file_name, input_file_ext] = fileparts(input_file_location);
        save_location = fullfile(save_path, [input_file_name, '_labeled', input_file_ext]);
    else
        save_path = uigetdir(pwd, 'Select save directory');
        save_location = fullfile(save_path, '_labeled.txt');
    end
else
    save_location = '';
end

handles_save = guihandles(file_select_box);
handles_save.tag_save_loc.String = save_location;
% -------------------------------------------------------------------------


% Function to update the save location
% -------------------------------------------------------------------------
function update_save
global file_select_box save_location input_file_location button_save_enable_opts

handles_save = guihandles(file_select_box);
if strcmp(button_save_enable_opts, 'on')
    if ~strcmp(input_file_location, '')
        [input_file_path, input_file_name, ~] = fileparts(input_file_location);
        save_location = fullfile(input_file_path, [input_file_name, '_labeled.txt']);
    else
        save_location = fullfile(pwd, '_labeled.txt');
    end
else
    save_location = '';
end
handles_save.tag_button_save.Enable = button_save_enable_opts;
handles_save.tag_save_loc.String = save_location;
% -------------------------------------------------------------------------


% Function to get threshold
% -------------------------------------------------------------------------
function get_threshold(hObject, ~)
global threshold
threshold = get(hObject, 'String');
threshold = str2double(threshold);
% -------------------------------------------------------------------------


% Callback for fetch label button (calls label_brain function)
% -------------------------------------------------------------------------
function fetch_label_brain(~, ~)
global file_select_box db_location input_file_location disp_results ...
    save_results save_location threshold labeled_coordinates
labeled_coordinates = label_brain(db_location, input_file_location, threshold);

if disp_results == 1
    disp(labeled_coordinates);
    display_label_brain;
    assignin('base', 'labeled_coordinates', labeled_coordinates);
end
if save_results == 1
    fid = fopen(save_location, 'w');
    [num_rows, num_text_cols] = size(labeled_coordinates);
    formatSpec = ['%2.2f\t%2.2f\t%2.2f', repmat('\t%s\t', 1, num_text_cols-3), '\r\n'];
    formatSpec_header = repmat('%s\t', 1, num_text_cols);
    
    % Write header
    fprintf(fid, formatSpec_header, labeled_coordinates{1,:});
    
    for row = 2:num_rows
        fprintf(fid, formatSpec, labeled_coordinates{row,:});
    end
    fclose(fid);
end
close(file_select_box);
input_file_location = '';
% -------------------------------------------------------------------------


% Function for displaying output of brain labeling
% -------------------------------------------------------------------------
function display_label_brain
global labeled_coordinates

disp_figure = figure('units', 'normalized', 'position', ...
    [0.56 0.45 0.30 0.20], 'Name', 'Labeled Coordinates', ...
    'numbertitle', 'off', 'MenuBar', 'none');

col_names = labeled_coordinates(1,:);
col_format = [repmat({'numeric'},1,3), repmat({'char'},1,size(labeled_coordinates, 2))];
data = labeled_coordinates(2:end, :);

uitable('parent', disp_figure, 'units', 'normalized', ...
    'position', [0.02 0.02 0.97 0.97], 'ColumnName', col_names, ...
    'ColumnFormat', col_format, 'ColumnWidth', ...
    [repmat({30}, 1, 3), repmat({90}, 1, size(labeled_coordinates, 2))], ...
    'Data', data);


% Callback to close warning dlgbox "OK" (create database module)
% -------------------------------------------------------------------------
function close_db_wait_box(~, ~)
global db_wait_box
close(db_wait_box);
% -------------------------------------------------------------------------


% Callback to toggle display results options
% -------------------------------------------------------------------------
function toggle_disp_results(hObject, ~)
global disp_results parent_figure
disp_results = get(hObject, 'Value');
handles_disp_results = guihandles(parent_figure);
if disp_results == 0
    handles_disp_results.tag_disp_results.String = 'OFF';
    handles_disp_results.tag_disp_results.ForegroundColor = 'red';
else
    handles_disp_results.tag_disp_results.String = 'ON';
    handles_disp_results.tag_disp_results.ForegroundColor = 'green';
end
% -------------------------------------------------------------------------


% Callback to save results options
% -------------------------------------------------------------------------
function toggle_save_results(hObject, ~)
global save_results parent_figure button_save_enable_opts file_select_box
save_results = get(hObject, 'Value');
handles_save_results = guihandles(parent_figure);
if save_results == 0
    handles_save_results.tag_save_results.String = 'OFF';
    handles_save_results.tag_save_results.ForegroundColor = 'red';
    button_save_enable_opts = 'off';
else
    handles_save_results.tag_save_results.String = 'ON';
    handles_save_results.tag_save_results.ForegroundColor = 'green';
    button_save_enable_opts = 'on';
end

% If file select box is open, update the figure
if ishandle(file_select_box)
    update_save
end
% -------------------------------------------------------------------------


% Callback to exit program
% -------------------------------------------------------------------------
function quit(~, ~)
global parent_figure
close(parent_figure);
% -------------------------------------------------------------------------