function atlas_lookup
% GUI for creation of database and labeling brain
% Parekh, Pravesh
% MBIAL
% May 02, 2017

% -------------------------------------------------------------------------
% Global variables
% -------------------------------------------------------------------------
global help_icon parent_figure max_width max_height fig_height fig_width ...
    but_height but_width

help_icon = imread(fullfile(matlabroot, 'help', 'warning.gif'));

% Set globals for drawing figures
set(0, 'units', 'characters');
display_properties = get(0, 'ScreenSize');
max_width = display_properties(3);
max_height = display_properties(4);
fig_height = 30;
fig_width = 65;
but_height = 12;
but_width = 65;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Create parent user interface
% -------------------------------------------------------------------------
parent_figure = figure('units', 'characters', 'position', ...
    [max_width/2-fig_width/2 max_height/4 fig_width fig_height],...
    'Name', 'Atlas Lookup', 'numbertitle', 'off', 'MenuBar', 'none');

% Panels
head_panel = uipanel('parent', parent_figure, 'units', 'normalized', ...
    'position', [0.02 0.90 0.96 0.09], 'HighlightColor', 'black');

parent_panel = uipanel('parent', parent_figure, 'units', 'normalized', ...
    'position', [0.02 0.15 0.96 0.70], 'HighlightColor', 'black');

options_panel = uipanel('parent', parent_figure, 'units', 'normalized', ...
    'position', [0.02 0.01 0.96 0.09], 'HighlightColor', 'black');

% Heading
uicontrol('parent', head_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.01 0.01 1 1], 'String', 'A T L A S     L O O K U P', ...
    'FontName', 'Times', 'FontSize', 16, 'FontWeight', 'bold');

% Buttons in parent panel
uicontrol('parent', parent_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.28 0.77 0.5 0.18], 'String', ...
    'Create Database', 'FontSize', 12, 'callback', @create_db);

uicontrol('parent', parent_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.28 0.53 0.5 0.18], 'String', ...
    'Label Brain', 'FontSize', 12, 'callback', @label_call);

uicontrol('parent', parent_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.28 0.29 0.5 0.18], 'String', ...
    'Calculate Overlap', 'FontSize', 12', 'callback', @cal_overlap);

uicontrol('parent', parent_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.28 0.05 0.5 0.18], 'String', ...
    'Quit', 'FontSize', 12, 'callback', @quit);

% Footer
uicontrol('parent', options_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.01 0.10 0.99 0.70], 'FontSize', 9, ...
    'String', 'Multimodal Brain Image Analysis Laboratory (MBIAL)');
% -------------------------------------------------------------------------


% /////////////////////////////////////////////////////////////////////// %
% Main Callback functions (for buttons in parent figure)
% /////////////////////////////////////////////////////////////////////// %


% -------------------------------------------------------------------------
% Callback for creating database
% -------------------------------------------------------------------------
function create_db(~, ~)
global file_select_box atlas_files_path label_files_path output_dir
atlas_files_path = '';
label_files_path = '';
output_dir = '';

% Create figure for selecting files
create_file_select_box('create_db');

% Button for create database
uicontrol(file_select_box, 'units', 'normalized', 'style', 'pushbutton', ...
    'position', [0.35 0.04 0.35 0.18], 'String', 'Create Database', ...
    'FontSize', 10, 'tag', 'tag_fetch_button', 'callback', @fetch_create_db);
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Callback for labeling brain
% -------------------------------------------------------------------------
function label_call(~, ~)
global file_select_box input_file_location save_location_label ...
    threshold
input_file_location = '';
save_location_label = '';
threshold = 0;

set_db_location;
% Create figure for selecting files
create_file_select_box('label_brain');

uicontrol(file_select_box, 'units', 'normalized', 'style', 'pushbutton', ...
    'position', [0.02 0.02 0.22 0.18], 'String', 'Threshold ', ...
    'FontSize', 10, 'enable', 'off');

uicontrol(file_select_box, 'units', 'normalized', 'style', 'edit', ...
    'position', [0.26 0.04 0.15 0.15], 'String', num2str(threshold), ...
    'callback', @get_threshold);

uicontrol(file_select_box, 'units', 'normalized', 'style', 'pushbutton', ...
    'position', [0.68 0.04 0.30 0.18], 'String', 'Fetch Labels', ...
    'FontSize', 10, 'tag', 'tag_fetch_button', 'callback', @fetch_label_brain);
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Callback for calculating overlap
% -------------------------------------------------------------------------
function cal_overlap(~, ~)
global file_select_box num_rois save_location_overlap
num_rois = 3;
save_location_overlap = '';
set_db_location;

create_file_select_box('calculate_overlap');

uicontrol(file_select_box, 'units', 'normalized', 'style', 'pushbutton', ...
    'position', [0.02 0.02 0.22 0.18], 'String', '# of ROIs ', ...
    'FontSize', 10, 'enable', 'off');

uicontrol(file_select_box, 'units', 'normalized', 'style', 'edit', ...
    'position', [0.26 0.04 0.15 0.15], 'String', num2str(num_rois), ...
    'callback', @get_num_rois);

uicontrol(file_select_box, 'units', 'normalized', 'style', 'pushbutton', ...
    'position', [0.55 0.04 0.40 0.18], 'String', 'Calculate Overlap', ...
    'FontSize', 10, 'tag', 'tag_fetch_button', 'callback', @fetch_cal_overlap);
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Callback to exit program
% -------------------------------------------------------------------------
function quit(~, ~)
global parent_figure
close(parent_figure);
% -------------------------------------------------------------------------


% /////////////////////////////////////////////////////////////////////// %
% File selection box function
% /////////////////////////////////////////////////////////////////////// %


% -------------------------------------------------------------------------
% Function to create file select box
% -------------------------------------------------------------------------
function create_file_select_box(button)
global file_select_box db_location input_file_location save_location_label ...
    save_location_overlap atlas_files_path label_files_path output_dir ...
    max_height max_width but_height but_width fig_height fig_width

file_select_box = figure('units', 'characters', 'position', ...
    [max_width/2+fig_width/2+5 max_height/4+fig_height-but_height ...
    but_width but_height], 'Name', 'File Locations', ...
    'numbertitle', 'off', 'MenuBar', 'none');

switch(button)
    case 'create_db'
        text_button1 = 'Atlas Dir';
        text_button2 = 'Label Dir';
        text_button3 = 'Save Dir';
        text_String1 = atlas_files_path;
        text_String2 = label_files_path;
        text_String3 = output_dir;
        callback1 = @browse_atlas_dir;
        callback2 = @browse_label_dir;
        callback3 = @browse_output_dir;
        
    case 'label_brain'
        text_button1 = 'Database';
        text_button2 = 'To Label';
        text_button3 = 'Save Dir';
        text_String1 = db_location;
        text_String2 = input_file_location;
        text_String3 = save_location_label;
        callback1 = @browse_db;
        callback2 = @browse_input;
        callback3 = @browse_save_label;
        
    case 'calculate_overlap'
        text_button1 = 'Database';
        text_button2 = 'Save Dir';
        text_String1 = db_location;
        text_String2 = save_location_overlap;
        callback1 = @browse_db;
        callback2 = @browse_save_overlap;
end

uicontrol(file_select_box, 'units', 'normalized', 'style', 'pushbutton', ...
    'position', [0.02 0.80 0.22 0.18], 'String', text_button1, ...
    'FontSize', 10, 'HorizontalAlignment', 'left', 'callback', callback1);

uicontrol(file_select_box, 'units', 'normalized', 'style', 'edit', ...
    'position', [0.26 0.80 0.72 0.18], 'enable', 'off', 'tag', ...
    'tag_button1', 'String', text_String1, 'HorizontalAlignment', 'left');

uicontrol(file_select_box, 'units', 'normalized', 'style', 'pushbutton', ...
    'position', [0.02 0.55 0.22 0.18], 'String', text_button2, ...
    'FontSize', 10, 'HorizontalAlignment', 'left','callback', callback2);

uicontrol(file_select_box, 'units', 'normalized', 'style', 'edit', ...
    'position', [0.26 0.55 0.72 0.18], 'enable', 'off', 'tag', ...
    'tag_button2', 'String', text_String2, 'HorizontalAlignment', 'left');

if strcmp(button, 'create_db') || strcmp(button, 'label_brain')
    
    uicontrol(file_select_box, 'units', 'normalized', 'style', ...
        'pushbutton', 'position', [0.02 0.30 0.22 0.18], 'String', ...
        text_button3, 'FontSize', 10, 'HorizontalAlignment', 'left', ...
        'callback', callback3);
    
    uicontrol(file_select_box, 'units', 'normalized', 'style', 'edit', ...
        'position', [0.26 0.30 0.72 0.18], 'enable', 'off', 'tag',...
        'tag_button3', 'String', text_String3, 'HorizontalAlignment', 'left');
end
% -------------------------------------------------------------------------


% /////////////////////////////////////////////////////////////////////// %
% All browse callback functions
% /////////////////////////////////////////////////////////////////////// %


% -------------------------------------------------------------------------
% Callback for browse database
% -------------------------------------------------------------------------
function browse_db(~, ~)
global db_location file_select_box
db_location = uigetdir(pwd, 'Select database directory');

if exist(fullfile(db_location, 'database.mat'), 'file')
    db_location = fullfile(db_location, 'database.mat');
else
    db_location = '';
    warndlg('Database file not found in this location', 'Database not found');
end
handles_db = guihandles(file_select_box);
handles_db.tag_button1.String = db_location;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Callback for browse input file (label_brain)
% -------------------------------------------------------------------------
function browse_input(~, ~)
global file_select_box input_file_location
[input_file, input_path] = uigetfile({'*.txt'; '*.nii'; '*.img'; '*.hdr'},...
    'Select the file to label');
if exist(fullfile(input_path, input_file), 'file')
    input_file_location = fullfile(input_path, input_file);
else
    input_file_location = '';
end
handles_input = guihandles(file_select_box);
update_save
handles_input.tag_button2.String = input_file_location;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Callback for browse save location (label)
% -------------------------------------------------------------------------
function browse_save_label(~, ~)
global file_select_box save_location_label input_file_location
if ~strcmp(input_file_location, '')
    save_path = uigetdir(input_file_location, 'Select save directory');
    [~, input_file_name, input_file_ext] = fileparts(input_file_location);
    save_location_label = fullfile(save_path, [input_file_name, '_labeled', input_file_ext]);
else
    save_path = uigetdir(pwd, 'Select save directory');
    save_location_label = fullfile(save_path, '_labeled.txt');
end
handles_save = guihandles(file_select_box);
handles_save.tag_button3.String = save_location_label;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Callback for browse save location (overlap)
% -------------------------------------------------------------------------
function browse_save_overlap(~, ~)
global file_select_box save_location_overlap
save_location_overlap = uigetdir(pwd, 'Select save directory');
handles_save = guihandles(file_select_box);
handles_save.tag_button2.String = save_location_overlap;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Callback for browse atlas directory
% -------------------------------------------------------------------------
function browse_atlas_dir(~, ~)
global file_select_box atlas_files_path
atlas_files_path = uigetdir(pwd, 'Select atlas directory');
handles_atlas = guihandles(file_select_box);
handles_atlas.tag_button1.String = atlas_files_path;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Callback for browse label directory
% -------------------------------------------------------------------------
function browse_label_dir(~, ~)
global file_select_box label_files_path
label_files_path = uigetdir(pwd, 'Select labels directory');
handles_atlas = guihandles(file_select_box);
handles_atlas.tag_button2.String = label_files_path;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Callback for browse output directory (save database)
% -------------------------------------------------------------------------
function browse_output_dir(~, ~)
global file_select_box output_dir
output_dir = uigetdir(pwd, 'Select output directory');
handles_atlas = guihandles(file_select_box);
handles_atlas.tag_button3.String = output_dir;
% -------------------------------------------------------------------------


% /////////////////////////////////////////////////////////////////////// %
% All Other utility functions
% /////////////////////////////////////////////////////////////////////// %


% -------------------------------------------------------------------------
% Function to update the save location
% -------------------------------------------------------------------------
function update_save
global file_select_box save_location_label input_file_location
handles_save = guihandles(file_select_box);
if ~strcmp(input_file_location, '')
    [input_file_path, input_file_name, ~] = fileparts(input_file_location);
    save_location_label = fullfile(input_file_path, [input_file_name, '_labeled.txt']);
else
    save_location_label = fullfile(pwd, '_labeled.txt');
end
handles_save.tag_button3.String = save_location_label;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Function to get threshold
% -------------------------------------------------------------------------
function get_threshold(hObject, ~)
global threshold
threshold = get(hObject, 'String');
threshold = str2double(threshold);
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Function to get number of ROIs
% -------------------------------------------------------------------------
function get_num_rois(hObject, ~)
global num_rois
num_rois = get(hObject, 'String');
num_rois = str2double(num_rois);
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Function to set database location
% -------------------------------------------------------------------------
function set_db_location
global db_location

% Locate database file
install_dir = fileparts(which('label_brain'));
if ~exist(fullfile(install_dir, 'database', 'database.mat'), 'file')
    warndlg('Database file not found; please locate manually',...
        'Database not found');
    db_location = '';
else
    db_location = fullfile(install_dir, 'database', 'database.mat');
end
% -------------------------------------------------------------------------


% /////////////////////////////////////////////////////////////////////// %
% All fetch functions
% /////////////////////////////////////////////////////////////////////// %


% -------------------------------------------------------------------------
% Callback for fetch label button (calls label_brain function)
% -------------------------------------------------------------------------
function fetch_label_brain(~, ~)
global file_select_box wait_box db_location input_file_location ...
    save_location_label threshold

if ~strcmp(db_location, '') || ~strcmp(input_file_location, '')
    close(file_select_box);
    create_wait_box('label');
    label_brain(db_location, input_file_location, save_location_label, threshold);
    handles_create_db = guihandles(wait_box);
    handles_create_db .tag_wait_text.String = 'Finished labeling file!';
    handles_create_db .tag_wait_okay.Enable = 'on';
else
    warndlg('Specify all fields', 'Missing Inputs');
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Callback for fetch create database (calls create_database function)
% -------------------------------------------------------------------------
function fetch_create_db(~, ~)
global file_select_box wait_box atlas_files_path label_files_path output_dir

if ~strcmp(atlas_files_path, '') || ~strcmp(label_files_path, '') ...
        || ~strcmp(output_dir, '')
    close(file_select_box);
    create_wait_box('db');
    create_database(atlas_files_path, label_files_path, output_dir);
    handles_create_db = guihandles(wait_box);
    handles_create_db .tag_wait_text.String = 'Database Created!';
    handles_create_db .tag_wait_okay.Enable = 'on';
else
    warndlg('Specify all fields', 'Missing Inputs');
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Callback for fetch calculate overlap (calls calculate_overlap function)
% -------------------------------------------------------------------------
function fetch_cal_overlap(~, ~)
global file_select_box wait_box db_location num_rois save_location_overlap

if ~strcmp(db_location, '') || ~strcmp(save_location_overlap, '')
    close(file_select_box);
    create_wait_box('overlap');
    calculate_overlap(db_location, save_location_overlap, num_rois);
    handles_create_db = guihandles(wait_box);
    handles_create_db .tag_wait_text.String = 'Done calculating overlap!';
    handles_create_db .tag_wait_okay.Enable = 'on';
else
   warndlg('Specify all fields', 'Missing Inputs');
end
% -------------------------------------------------------------------------


% /////////////////////////////////////////////////////////////////////// %
% Wait box functions
% /////////////////////////////////////////////////////////////////////// %


% -------------------------------------------------------------------------
% Function to create wait box
% -------------------------------------------------------------------------
function create_wait_box(module)
global wait_box help_icon max_width fig_width max_height fig_height ...
    but_height but_width

switch(module)
    case 'db'
        title = 'Creating Database';
    case 'label'
        title = 'Labeling Brain';
    case 'overlap'
        title = 'Calculating Overlap';
end

wait_box = figure('units', 'characters', 'position', ...
    [max_width/2+fig_width/2+5 max_height/4+fig_height-but_height+but_height/3 ...
    but_width but_height-but_height/3], 'Name', title, 'numbertitle', 'off', ...
    'MenuBar', 'none');

ax = axes('parent', wait_box, 'units', 'normalized', 'position', ...
    [0.02 0.4 0.20 0.5]);
imagesc(ax, help_icon);
axis off;

uicontrol(wait_box, 'units', 'normalized', 'style', 'text', ...
    'position', [0.25 0.60 0.80 0.25], 'String', 'Please Wait!', ...
    'FontSize', 12, 'HorizontalAlignment', 'left', 'tag', 'tag_wait_text');

uicontrol(wait_box, 'units', 'normalized', 'style', 'pushbutton', ...
    'position', [0.45 0.10 0.2 0.3], 'String', 'OK', 'enable', 'off', ...
    'FontSize', 12, 'tag', 'tag_wait_okay', 'callback', @close_wait_box);
drawnow
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Function to close wait_box (create database module)
% -------------------------------------------------------------------------
function close_wait_box(~, ~)
global wait_box
close(wait_box);
% -------------------------------------------------------------------------