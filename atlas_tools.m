function atlas_tools
% Function to create and run GUI for AtlasTools
%% Author(s)
% Parekh, Pravesh
% July 24, 2017
% MBIAL
%
%% Setting global variables
global parent_figure panel_left panel_middle panel_right panel_dim_spacing ...
    panel_text_font_size button_font_size
%% Initializing and drawing parent figure components
% -------------------------------------------------------------------------
% // Begin: Initializing ad drawing parent figure //

% Getting screen dimensions in characters
set(0, 'units', 'characters');
display_properties = get(0, 'ScreenSize');
max_width  = display_properties(3);
max_height = display_properties(4);

% Setting parent figure height and width
parent_height = max_height/1.2;
parent_width  = max_width /2;

% Setting parent figure position
parent_position = [(max_width/2)-(parent_width/2)  ...
    (max_height/2)-(parent_height/2) ...
    parent_width parent_height];

% pushbutton dimensions in normalized units
button_height   = 0.10;
button_width    = 0.90;
button_left     = 0.05;
button_spacing  = 0.05;
button_bottom   = 0.80;

% Font sizes for various components
header_font_size     = 24;
footer_font_size     = 12;
panel_text_font_size = 14;
button_font_size     = 12;

% Dimensions for Coordinates for left, middle, and right panels
panel_dim_left    = 0.02;
panel_dim_bot     = 0.15;
panel_dim_width   = 0.30;
panel_dim_height  = 0.70;
panel_dim_spacing = 0.03;

% Drawing parent figure
parent_figure = figure('units', 'characters', 'position', parent_position, ...
    'Name', 'Atlas Tools', 'numbertitle', 'off', 'MenuBar', 'none');

% Creating panels in the parent figure
panel_header  = uipanel('parent', parent_figure, 'units', 'normalized', ...
    'position', [0.02 0.88 0.96 0.09], 'HighlightColor', 'blue');

panel_footer  = uipanel('parent', parent_figure, 'units', 'normalized', ...
    'position', [0.02 0.03 0.96 0.09], 'HighlightColor', 'blue');

% Creating left, middle, and right panels
position_left_panel    = [panel_dim_left panel_dim_bot panel_dim_width panel_dim_height];
position_middle_panel  = [panel_dim_left+panel_dim_width+panel_dim_spacing panel_dim_bot panel_dim_width panel_dim_height];
position_right_panel   = [panel_dim_left+(panel_dim_width*2)+(panel_dim_spacing*2) panel_dim_bot panel_dim_width panel_dim_height];

panel_left    = uipanel('parent', parent_figure, 'units', 'normalized', ...
    'position', position_left_panel, 'HighlightColor', 'blue');

panel_middle  = uipanel('parent', parent_figure, 'units', 'normalized', ...
    'position', position_middle_panel, 'HighlightColor', 'blue');

panel_right  = uipanel('parent', parent_figure, 'units', 'normalized', ...
    'position', position_right_panel, 'HighlightColor', 'blue');

% Add text to the header panel
uicontrol('parent', panel_header, 'units', 'normalized', 'style', ...
    'text', 'position', [0.01 0.28 1 0.50], 'String', 'A T L A S     T O O L S', ...
    'FontName', 'Times', 'FontSize', header_font_size, 'FontWeight', 'bold');

% Add text to the footer panel
uicontrol('parent', panel_footer, 'units', 'normalized', 'style', ...
    'text', 'position', [0.01 0.10 0.99 0.70], 'FontSize', footer_font_size, ...
    'String', 'Multimodal Brain Image Analysis Laboratory (MBIAL)');

% Add text to the left panel
uicontrol('parent', panel_left, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.92 0.90 0.05], 'String', 'Atlas Editing', ...
    'FontSize', panel_text_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');

% Add text to the middle panel
uicontrol('parent', panel_middle, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.92 0.90 0.05], 'String', 'Database Utilities', ...
    'FontSize', panel_text_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');

% Add text to the right panel
uicontrol('parent', panel_right, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.92 0.90 0.05], 'String', 'Other Utilities', ...
    'FontSize', panel_text_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');

% Button list for all panels
button_list_left   = {'Create max prob atlas', 'Create macro regions', ...
    'Modify atlas L/R', 'Modify lookup L/R', ...
    'Create database'};

button_list_middle = {'Create voxel map', 'Label coordinates', ...
    'Calculate ROI overlap', 'Create meta-atlas', ...
    'Threshold meta-atlas'};

button_list_right  = {'Create ROI masks', 'Atlas to ROIs', ...
    'Check midline voxels', 'Map midline voxels', ...
    'Meta-atlas to ROIs'};

% Callback function for all buttons
callback_list_left   = {@create_max_prob; @create_macro_regions; ...
    @modify_atlas; @modify_lookup_lr; @create_db};

callback_list_middle = {@create_vox_map; @label_coordinates; ...
    @calculate_roi_overlap; @create_meta_atlas_file; ...
    @threshold_meta_atlas_file};

callback_list_right  = {@create_roi_mask; @atlas_to_rois; ...
    @check_midline_vox; @map_midline_vox; ...
    @meta_atlas_to_rois};

% Creating butons for left panel
for i = 1:length(button_list_left)
    position = [button_left button_bottom-(button_spacing+button_height)*(i-1) button_width button_height];
    uicontrol('parent', panel_left, 'units', 'normalized', 'style', ...
        'pushbutton', 'position', position, 'String', button_list_left{i}, ...
        'FontSize', button_font_size, 'callback', callback_list_left{i});
end

% Creating butons for middle panel
for i = 1:length(button_list_middle)
    position = [button_left button_bottom-(button_spacing+button_height)*(i-1) button_width button_height];
    uicontrol('parent', panel_middle, 'units', 'normalized', 'style', ...
        'pushbutton', 'position', position, 'String', button_list_middle{i}, ...
        'FontSize', button_font_size, 'callback', callback_list_middle{i});
end

% Creating butons for right panel
for i = 1:length(button_list_right)
    position = [button_left button_bottom-(button_spacing+button_height)*(i-1) button_width button_height];
    uicontrol('parent', panel_right, 'units', 'normalized', 'style', ...
        'pushbutton', 'position', position, 'String', button_list_right{i}, ...
        'FontSize', button_font_size, 'callback', callback_list_right{i});
end

% Add home button for easy navigation
home_location = which('atlas_tools');
[home_path, ~] = fileparts(home_location);
[home_icon, ~, home_transp] = imread(fullfile(home_path, 'icons', 'icon_home.png'));

home_icon_panel = uipanel('parent', panel_header, 'units', 'normalized', ...
    'position', [0.90 0.00 0.10 1.00], 'BorderType', 'none');
home_icon_ax = axes(home_icon_panel, 'units', 'normalized', 'position', [0 0 1 1]);
imagesc(home_icon_ax, home_icon, 'AlphaData', home_transp, 'ButtonDownFcn', @go_home);
axis off

% Add brain icon
[brain_icon, ~, brain_transp] = imread(fullfile(home_path, 'icons', 'icon_brain_alt.png'));
brain_icon_panel = uipanel('parent', panel_header, 'units', 'normalized', ...
    'position', [0.02 0.00 0.10 1.00], 'BorderType', 'none');
brain_icon_ax = axes(brain_icon_panel, 'units', 'normalized', 'position', [0 0 1 1]);
imagesc(brain_icon_ax, brain_icon, 'AlphaData', brain_transp);
axis off

% // End: Initializing and drawing parent figure //
% -------------------------------------------------------------------------

% =========================================================================
% // Begin: left panel functions //
% =========================================================================
% -------------------------------------------------------------------------
% // Begin: All functions for create_max_prob //
%% Callback for create_max_prob
function create_max_prob(~, ~)
global param_box_panel button_font_size atlas_location threshold ...
    output_location elapsed_time

% Setting default values for atlas_location and threshold
atlas_location  = '';
threshold       = 0.25;
output_location = '';
elapsed_time    = 0;

head_text = 'Create maximum probability atlas';
desc_text = 'Reads a probabilistic atlas file (4D) and assigns maximum probability value to each voxel';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for input file
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select a 4D probabilistic atlas file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Atlas file: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_max_prob);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Atlas file" to browse file', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_max_prob_input_loc');

% Create guide text, input button, and text box for threshold
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.65 0.70 0.05], 'String', ...
    'Set threshold', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.60 0.20 0.05], 'String', ...
    'Threshold: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.60 0.10 0.05], 'String', num2str(threshold), ...
    'FontSize', button_font_size, 'enable', ' on', 'tag', 'tag_max_prob_thresh', ...
    'HorizontalAlignment', 'left');

% Create guide text, input button, and text box for output location
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.50 0.70 0.05], 'String', ...
    'Output file location', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.45 0.20 0.05], 'String', ...
    'Output location: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_output_max_prob);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.45 0.70 0.05], 'String', ...
    'Click "Output location" to browse location', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_max_prob_output_loc');

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.39 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_create_max_prob);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.38 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_input_max_prob
function browse_input_max_prob(~, ~)
global atlas_location param_box_panel
text = 'Select 4D probabilistic atlas file';
atlas_location = browse_nii(text);
handles = guihandles(param_box_panel);
handles.tag_max_prob_input_loc.String = atlas_location;
handles.tag_run.Enable = 'on';

%% Callback for browse_output_max_prob
function browse_output_max_prob(~, ~)
global param_box_panel output_location
text = 'Select output folder';
output_location = browse_fldr(text);
handles = guihandles(param_box_panel);
handles.tag_max_prob_output_loc.String = output_location;

%% Run function run_create_max_prob
function run_create_max_prob(~, ~)
global param_box_panel atlas_location threshold output_location ...
    elapsed_time button_font_size
% Get final value of threshold
handles = guihandles(param_box_panel);
threshold = str2double(get(handles.tag_max_prob_thresh, 'String'));
% Disable the run button
handles.tag_run.Enable = 'off';
% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.30 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;
% Get cputime now
starttime = cputime;
% Call create_max_prob_atlas
create_max_prob_atlas(atlas_location, threshold, output_location);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.25 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for create_max_prob //
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% // Begin: All functions for create macro regions //
%% Callback for create_macro_regions
function create_macro_regions(~, ~)
global param_box_panel button_font_size atlas_location lookup_location ...
    idx_to_merge new_idx new_names elapsed_time

% Setting default values for input variables
atlas_location  = '';
lookup_location = '';
idx_to_merge    = '';
new_idx         = '';
new_names       = '';
elapsed_time    = 0;

head_text = 'Create macro regions';
desc_text = 'Reads an atlas and combines regions to create macro regions';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for input atlas file
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select an atlas file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Atlas file: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_atlas_macro);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Atlas file" to browse file', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_macro_input_atlas');

% Create guide text, input button, and text box for input lookup file
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.65 0.70 0.05], 'String', ...
    'Select corresponding lookup file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.60 0.20 0.05], 'String', ...
    'Lookup file: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_lookup_macro);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.60 0.70 0.05], 'String', ...
    'Click "Lookup file" to browse file', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_macro_lookup_atlas');

% Create guide text, input button, and text box for idx_to_merge
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.50 0.70 0.05], 'String', ...
    'Select file having indices to merge', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.45 0.20 0.05], 'String', ...
    'To merge file: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_idx_to_merge_macro);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.45 0.70 0.05], 'String', ...
    'Click "To merge file" to browse file', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_macro_input_idx_to_merge');

% Create guide text, input button, and text box for new_idx_list
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.35 0.70 0.05], 'String', ...
    'Select file having new indices', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.30 0.20 0.05], 'String', ...
    'New indices file: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_new_idx_macro);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.30 0.70 0.05], 'String', ...
    'Click "New indices file" to browse file', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_macro_new_idx');

% Create guide text, input button, and text box for new_names_list
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.20 0.70 0.05], 'String', ...
    'Select file having new names', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.15 0.20 0.05], 'String', ...
    'New names file: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_new_names_macro);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.15 0.70 0.05], 'String', ...
    'Click "New names file" to browse file', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_macro_new_names');

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.09 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_create_macro);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.08 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_input_atlas_macro
function browse_input_atlas_macro(~, ~)
global atlas_location param_box_panel
text = 'Select atlas file';
atlas_location = browse_nii(text);
handles = guihandles(param_box_panel);
handles.tag_macro_input_atlas.String = atlas_location;
check_merge_idx_ready

%% Callback for browse_input_lookup_macro
function browse_input_lookup_macro(~, ~)
global lookup_location param_box_panel
text = 'Select lookup file';
lookup_location = browse_txt(text);
handles = guihandles(param_box_panel);
handles.tag_macro_lookup_atlas.String = lookup_location;
check_merge_idx_ready

%% Callback for browse_input_idx_to_merge_macro
function browse_input_idx_to_merge_macro(~, ~)
global idx_to_merge param_box_panel
text = 'Select file having indices to merge';
idx_to_merge = browse_txt(text);
handles = guihandles(param_box_panel);
handles.tag_macro_input_idx_to_merge.String = idx_to_merge;
check_merge_idx_ready

%% Callback for browse_input_new_idx_macro
function browse_input_new_idx_macro(~, ~)
global new_idx param_box_panel
text = 'Select file having new indices';
new_idx = browse_txt(text);
handles = guihandles(param_box_panel);
handles.tag_macro_new_idx.String = new_idx;
check_merge_idx_ready

%% Callback for browse_input_new_names_macro
function browse_input_new_names_macro(~, ~)
global new_names param_box_panel
text = 'Select file having new names';
new_names = browse_txt(text);
handles = guihandles(param_box_panel);
handles.tag_macro_new_names.String = new_names;
check_merge_idx_ready

%% Check if all inputs for merge_idx are ready
function check_merge_idx_ready
global param_box_panel atlas_location lookup_location idx_to_merge ...
    new_idx new_names
handles = guihandles(param_box_panel);
if isempty(atlas_location) || isempty(lookup_location) || ...
        isempty(idx_to_merge) || isempty(new_idx) || isempty(new_names)
    handles.tag_run.Enable = 'off';
else
    handles.tag_run.Enable = 'on';
end

%% Callback for run_create_macro
function run_create_macro(~, ~)
global param_box_panel atlas_location lookup_location idx_to_merge ...
    new_idx new_names elapsed_time button_font_size
% Disable the run button
handles = guihandles(param_box_panel);
handles.tag_run.Enable = 'off';
% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.01 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;
% Get cputime now
starttime = cputime;
% Call merge_idx
merge_idx(atlas_location, lookup_location, idx_to_merge, new_idx, new_names);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.01 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for create macro regions //
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% // Begin: All functions for modify atlas L/R //
%% Callback for modify_atlas
function modify_atlas(~, ~)
global param_box_panel button_font_size atlas_location lookup_location ...
    new_idx new_names elapsed_time

% Setting default values for input variables
atlas_location  = '';
lookup_location = '';
new_idx         = '';
new_names       = '';
elapsed_time    = 0;

head_text = 'Modify atlas L/R';
desc_text = 'Create separate regions for left and right from one region';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for input atlas file
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select an atlas file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Atlas file: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_atlas_modify_lr);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Atlas file" to browse file', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_modify_lr_input_atlas');

% Create guide text, input button, and text box for input lookup file
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.65 0.70 0.05], 'String', ...
    'Select corresponding lookup file (optional)', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.60 0.20 0.05], 'String', ...
    'Lookup file: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_lookup_modify_lr);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.60 0.70 0.05], 'String', ...
    'Click "Lookup file" to browse file', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_modify_lr_lookup_atlas');

% Create guide text and input button for new_idx_list
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.50 0.70 0.05], 'String', ...
    'Define new indices', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'popupmenu', 'position', [0.05 0.45 0.20 0.05], 'String', ...
    {'serialize', 'add n m', 'sub n m', 'mul n m', 'div n m', 'file'},...
    'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'tag', 'tag_modify_lr_new_idx', 'callback', @update_modify_lr_new_idx_ui);

% Create guide text and input button for new_names_list
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.35 0.70 0.05], 'String', ...
    'Define new names', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'popupmenu', 'position', [0.05 0.30 0.20 0.05], 'String', ...
    {'lr sh prefix', 'lr sh postfix', 'lr prefix', 'lr postfix', 'file'}, ...
    'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'tag', 'tag_modify_lr_new_names', ...
    'callback', @update_modify_lr_new_names_ui);

% Set default values for new_idx_list and new_names_list
handles = guihandles(param_box_panel);
set(handles.tag_modify_lr_new_idx,    'Value', 2);
set(handles.tag_modify_lr_new_names', 'Value', 3);
update_modify_lr_new_idx_ui
update_modify_lr_new_names_ui

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.24 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_modify_atlas_lr);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.23 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_input_atlas_modify_lr
function browse_input_atlas_modify_lr(~, ~)
global atlas_location param_box_panel
text = 'Select atlas file';
atlas_location = browse_nii(text);
handles = guihandles(param_box_panel);
handles.tag_modify_lr_input_atlas.String = atlas_location;
handles.tag_run.Enable = 'on';

%% Callback for browse_input_lookup_modify_lr
function browse_input_lookup_modify_lr(~, ~)
global lookup_location param_box_panel
text = 'Select lookup file';
lookup_location = browse_txt(text);
handles = guihandles(param_box_panel);
handles.tag_modify_lr_lookup_atlas.String = lookup_location;

%% Callback for browse_input_atlas_modify_lr_new_idx
function browse_input_atlas_modify_lr_new_idx
global new_idx param_box_panel
text = 'Select new_idx file';
new_idx = browse_txt(text);
handles = guihandles(param_box_panel);
handles.tag_modify_lr_new_idx_file.String = new_idx;

%% Callback for browse_input_atlas_modify_lr_new_names
function browse_input_atlas_modify_lr_new_names
global new_names param_box_panel
text = 'Select new_names file';
new_names = browse_txt(text);
handles = guihandles(param_box_panel);
handles.tag_modify_lr_new_names_file.String = new_names;

%% Update GUI interface for new_idx
function update_modify_lr_new_idx_ui(~, ~)
global param_box_panel button_font_size 
handles = guihandles(param_box_panel);
curr_val = get(handles.tag_modify_lr_new_idx, 'Value');
switch(curr_val)
    % Case serialize
    case 1
        % Delete all other ui components in this location
        clear_modify_atlas_lr_input_idx
        
    % Case add n m
    case 2
        % Delete all other ui components in this location
        clear_modify_atlas_lr_input_idx
        % Show text 'left'
        uicontrol('parent', param_box_panel, 'units', 'normalized', ...
            'position', [0.26 0.45 0.15 0.05], 'style', 'edit', 'String', ...
            'Left (n): ', 'FontSize', button_font_size, ...
            'HorizontalAlignment', 'left', 'tag', 'text_left_idx', ...
            'FontWeight', 'bold', 'enable', 'off');
        % Create input box for left value
        uicontrol('parent', param_box_panel', 'units', 'normalized', ...
            'position', [0.36 0.45 0.15 0.05], 'style', 'edit', 'String', '1000', ...
            'FontSize', button_font_size, 'HorizontalAlignment', 'left', ...
            'tag', 'box_left_idx');
        % Show text 'right'
        uicontrol('parent', param_box_panel, 'units', 'normalized', ...
            'position', [0.69 0.45 0.15 0.05], 'style', 'edit', 'String', ...
            'Right (m): ', 'FontSize', button_font_size, ...
            'HorizontalAlignment', 'left', 'tag', 'text_right_idx', ...
            'FontWeight', 'bold', 'enable', 'off');
        % Create input box for left value
        uicontrol('parent', param_box_panel', 'units', 'normalized', ...
            'position', [0.81 0.45 0.15 0.05], 'style', 'edit', 'String', '2000', ...
            'FontSize', button_font_size, 'HorizontalAlignment', 'left', ...
            'tag', 'box_right_idx');
        
    % Case sub n m
    case 3
        % Delete all other ui components in this location
        clear_modify_atlas_lr_input_idx
        % Show text 'left'
        uicontrol('parent', param_box_panel, 'units', 'normalized', ...
            'position', [0.26 0.45 0.15 0.05], 'style', 'edit', 'String', ...
            'Left (n): ', 'FontSize', button_font_size, ...
            'HorizontalAlignment', 'left', 'tag', 'text_left_idx', ...
            'FontWeight', 'bold', 'enable', 'off');
        % Create input box for left value
        uicontrol('parent', param_box_panel', 'units', 'normalized', ...
            'position', [0.36 0.45 0.15 0.05], 'style', 'edit', 'String', '1000', ...
            'FontSize', button_font_size, 'HorizontalAlignment', 'left', ...
            'tag', 'box_left_idx');
        % Show text 'right'
        uicontrol('parent', param_box_panel, 'units', 'normalized', ...
            'position', [0.69 0.45 0.15 0.05], 'style', 'edit', 'String', ...
            'Right (m): ', 'FontSize', button_font_size, ...
            'HorizontalAlignment', 'left', 'tag', 'text_right_idx', ...
            'FontWeight', 'bold', 'enable', 'off');
        % Create input box for left value
        uicontrol('parent', param_box_panel', 'units', 'normalized', ...
            'position', [0.81 0.45 0.15 0.05], 'style', 'edit', 'String', '2000', ...
            'FontSize', button_font_size, 'HorizontalAlignment', 'left', ...
            'tag', 'box_right_idx');
        
    % Case mul n m
    case 4
        % Delete all other ui components in this location
        clear_modify_atlas_lr_input_idx
         uicontrol('parent', param_box_panel, 'units', 'normalized', ...
            'position', [0.26 0.45 0.15 0.05], 'style', 'edit', 'String', ...
            'Left (n): ', 'FontSize', button_font_size, ...
            'HorizontalAlignment', 'left', 'tag', 'text_left_idx', ...
            'FontWeight', 'bold', 'enable', 'off');
        % Create input box for left value
        uicontrol('parent', param_box_panel', 'units', 'normalized', ...
            'position', [0.36 0.45 0.15 0.05], 'style', 'edit', 'String', '1000', ...
            'FontSize', button_font_size, 'HorizontalAlignment', 'left', ...
            'tag', 'box_left_idx');
        % Show text 'right'
        uicontrol('parent', param_box_panel, 'units', 'normalized', ...
            'position', [0.69 0.45 0.15 0.05], 'style', 'edit', 'String', ...
            'Right (m): ', 'FontSize', button_font_size, ...
            'HorizontalAlignment', 'left', 'tag', 'text_right_idx', ...
            'FontWeight', 'bold', 'enable', 'off');
        % Create input box for left value
        uicontrol('parent', param_box_panel', 'units', 'normalized', ...
            'position', [0.81 0.45 0.15 0.05], 'style', 'edit', 'String', '2000', ...
            'FontSize', button_font_size, 'HorizontalAlignment', 'left', ...
            'tag', 'box_right_idx');
        
    % Case div n m
    case 5
        % Delete all other ui components in this location
        clear_modify_atlas_lr_input_idx
         uicontrol('parent', param_box_panel, 'units', 'normalized', ...
            'position', [0.26 0.45 0.15 0.05], 'style', 'edit', 'String', ...
            'Left (n): ', 'FontSize', button_font_size, ...
            'HorizontalAlignment', 'left', 'tag', 'text_left_idx', ...
            'FontWeight', 'bold', 'enable', 'off');
        % Create input box for left value
        uicontrol('parent', param_box_panel', 'units', 'normalized', ...
            'position', [0.36 0.45 0.15 0.05], 'style', 'edit', 'String', '1000', ...
            'FontSize', button_font_size, 'HorizontalAlignment', 'left', ...
            'tag', 'box_left_idx');
        % Show text 'right'
        uicontrol('parent', param_box_panel, 'units', 'normalized', ...
            'position', [0.69 0.45 0.15 0.05], 'style', 'edit', 'String', ...
            'Right (m): ', 'FontSize', button_font_size, ...
            'HorizontalAlignment', 'left', 'tag', 'text_right_idx', ...
            'FontWeight', 'bold', 'enable', 'off');
        % Create input box for left value
        uicontrol('parent', param_box_panel', 'units', 'normalized', ...
            'position', [0.81 0.45 0.15 0.05], 'style', 'edit', 'String', '2000', ...
            'FontSize', button_font_size, 'HorizontalAlignment', 'left', ...
            'tag', 'box_right_idx');
        
    % Case file
    case 6
        % Delete all other ui components in this location
        clear_modify_atlas_lr_input_idx
        % Create file input box
        uicontrol('parent', param_box_panel, 'units', 'normalized', ...
            'position', [0.26 0.45 0.70 0.05], 'style', 'edit', ...
            'FontSize', button_font_size, 'HorizontalAlignment', 'left', ...
            'tag', 'tag_modify_lr_new_idx_file', 'enable', 'off');
        browse_input_atlas_modify_lr_new_idx;
end

%% Update GUI interface for new_names
function update_modify_lr_new_names_ui(~, ~)
global param_box_panel button_font_size 
handles = guihandles(param_box_panel);
curr_val = get(handles.tag_modify_lr_new_names, 'Value');
switch(curr_val)
    % Case lr sh prefix
    case 1
        % Delete all other ui components in this location
        clear_modify_atlas_lr_input_names
        
    % Case lr sh postfix
    case 2
        % Delete all other ui components in this location
        clear_modify_atlas_lr_input_names
        
    % Case lr prefix
    case 3
        % Delete all other ui components in this location
        clear_modify_atlas_lr_input_names
        
    % Case lr postfix
    case 4
        % Delete all other ui components in this location
        clear_modify_atlas_lr_input_names
       
    % Case file
    case 5
        % Delete all other ui components in this location
        clear_modify_atlas_lr_input_names
        % Create file input box
        uicontrol('parent', param_box_panel, 'units', 'normalized', ...
            'position', [0.26 0.30 0.70 0.05], 'style', 'edit', ...
            'FontSize', button_font_size, 'HorizontalAlignment', 'left', ...
            'tag', 'tag_modify_lr_new_names_file', 'enable', 'off');
        browse_input_atlas_modify_lr_new_names;
end

%% Delete UI components from modify atlas L/R (new_idx)
function clear_modify_atlas_lr_input_idx
global param_box_panel
handles = guihandles(param_box_panel);
if isfield(handles, 'text_left_idx')
    delete(handles.text_left_idx);
    delete(handles.text_right_idx);
    delete(handles.box_left_idx);
    delete(handles.box_right_idx);
end
if isfield(handles, 'tag_modify_lr_new_idx_file')
    delete(handles.tag_modify_lr_new_idx_file);
end

%% Delete UI components from modify atlas L/R (new_names)
function clear_modify_atlas_lr_input_names
global param_box_panel
handles = guihandles(param_box_panel);
if isfield(handles, 'text_left_names')
    delete(handles.text_left_names);
    delete(handles.text_right_names);
    delete(handles.box_left_names);
    delete(handles.box_right_names);
end
if isfield(handles, 'tag_modify_lr_new_names_file')
    delete(handles.tag_modify_lr_new_names_file);
end

%% Run function run_modify_atlas_lr
function run_modify_atlas_lr(~, ~)
global param_box_panel atlas_location lookup_location ...
    new_idx new_names elapsed_time button_font_size

% Get values for new_idx
handles = guihandles(param_box_panel);
curr_val_new_idx = get(handles.tag_modify_lr_new_idx, 'Value');
switch(curr_val_new_idx)
    case 1
        new_idx = 'serialize';
    case 2
        n = get(handles.box_left_idx,  'String');
        m = get(handles.box_right_idx, 'String');
        new_idx = ['add ', n, ' ', m];
    case 3
        n = get(handles.box_left_idx,  'String');
        m = get(handles.box_right_idx, 'String');
        new_idx = ['sub ', n, ' ', m];
    case 4
        n = get(handles.box_left_idx,  'String');
        m = get(handles.box_right_idx, 'String');
        new_idx = ['mul ', n, ' ', m];
    case 5
        n = get(handles.box_left_idx,  'String');
        m = get(handles.box_right_idx, 'String');
        new_idx = ['div ', n, ' ', m];
end

% Get values for new_names
curr_val_new_names = get(handles.tag_modify_lr_new_names, 'Value');
switch(curr_val_new_names)
    case 1
        new_names = 'lr sh prefix';
    case 2
        new_names = 'lr sh postfix';
    case 3
        new_names = 'lr prefix';
    case 4
        new_names = 'lr postfix';
end

% Disable the run button
handles.tag_run.Enable = 'off';

% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.18 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;
% Get cputime now
starttime = cputime;
% Call merge_idx
modify_atlas_lr(atlas_location, lookup_location, new_idx, new_names);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.12 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for modify atlas L/R //
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% // Begin: All functions for modify lookup L/R //
%% Callback for modify_lookup
function modify_lookup_lr(~, ~)
global param_box_panel button_font_size lookup_location new_names ...
       look_for rep_underscores elapsed_time 

% Setting default values for input variables
lookup_location = '';
new_names       = '';
look_for        = '';
rep_underscores = '';
elapsed_time    = 0;

head_text = 'Modify lookup file';
desc_text = 'Modifies how left and right are labeled in a lookup file';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for input lookup file
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select a lookup file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Lookup file: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_lookup_modify);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Lookup file" to browse file', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_input_lookup_modify');

% Create guide text and input button for new_names
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.65 0.70 0.05], 'String', ...
    'Define new names', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'popupmenu', 'position', [0.05 0.60 0.20 0.05], 'String', ...
    {'lr sh prefix', 'lr sh postfix', 'lr prefix', 'lr postfix'},...
    'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'tag', 'tag_new_names_modify_lookup');

% Create guide text and input button for look_for
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.50 0.70 0.05], 'String', ...
    'Define new names', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'popupmenu', 'position', [0.05 0.45 0.20 0.05], 'String', ...
    {'search', 'lr sh prefix', 'lr sh postfix', 'lr prefix', 'lr postfix'},...
    'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'tag', 'tag_look_for_modify_lookup');

% Create guide text and checkbox for rep_underscore
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.35 0.40 0.05], 'String', ...
    'Replace underscores (if any) in lookup file? ', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left', 'tag', 'tag_rep_undersc');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'checkbox', 'position', [0.46 0.35 0.05 0.05]);

% Set default values for new_names and look_for
handles = guihandles(param_box_panel);
set(handles.tag_new_names_modify_lookup, 'Value', 3);
set(handles.tag_look_for_modify_lookup', 'Value', 1);

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.29 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_modify_lookup);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.28 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_input_lookup_modify
function browse_input_lookup_modify(~, ~)
global lookup_location param_box_panel
text = 'Select lookup file';
lookup_location = browse_txt(text);
handles = guihandles(param_box_panel);
handles.tag_input_lookup_modify.String = lookup_location;
handles.tag_run.Enable = 'on';

%% Run function run_modify_lookup
function run_modify_lookup(~, ~)
global param_box_panel lookup_location new_names look_for rep_underscores ...
    elapsed_time button_font_size

handles = guihandles(param_box_panel);

% Get value for new_names
curr_val_new_names = get(handles.tag_new_names_modify_lookup, 'Value');
switch(curr_val_new_names)
    case 1
        new_names = 'lr sh prefix';
    case 2
        new_names = 'lr sh postfix';
    case 3
        new_names = 'lr prefix';
    case 4
        new_names = 'lr postfix';
end

% Get value for look_for
curr_val_look_for = get(handles.tag_look_for_modify_lookup, 'Value');
switch(curr_val_look_for)
    case 1
        look_for = 'search';
    case 2
        look_for = 'lr sh prefix';
    case 3
        look_for = 'lr sh postfix';
    case 4
        look_for = 'lr prefix';
    case 5
        look_for = 'lr postfix';
end

% Get value for rep_underscore
curr_val_undercs = get(handles.tag_rep_undersc, 'Value');
switch curr_val_undercs 
    case 0
        rep_underscores = 0;
    case 1
        rep_underscores = 1;
end

% Disable the run button
handles.tag_run.Enable = 'off';

% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.22 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;
% Get cputime now
starttime = cputime;
% Call modify_lookup
modify_lookup(lookup_location, new_names, look_for, rep_underscores);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.16 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for modify lookup L/R //
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% // Begin: All functions for create_db //
%% Callback function for create_db
function create_db(~, ~)
global param_box_panel button_font_size atlas_paths lookup_paths ...
       elapsed_time output_location

% Setting default values for input variables
atlas_paths     = '';
lookup_paths    = '';
output_location = '';
elapsed_time    = 0;

head_text = 'Create database';
desc_text = 'Create database using atlases and their lookup tables';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for atlas paths
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select folder having atlas files', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Atlas Paths: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_atlas_paths_db);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Atlas Paths" to browse for atlas folder', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_input_atlas_paths_db');

% Create guide text, input button, and text box for lookup paths
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.65 0.70 0.05], 'String', ...
    'Select folder having lookup files', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.60 0.20 0.05], 'String', ...
    'Lookup Paths: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_lookup_paths_db);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.60 0.70 0.05], 'String', ...
    'Click "Lookup Paths" to browse for lookup folder', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_input_lookup_paths_db');

% Create guide text, input button, and text box for output folder
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.50 0.70 0.05], 'String', ...
    'Select output location ', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.45 0.20 0.05], 'String', ...
    'Output Location: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_output_path_db);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.45 0.70 0.05], 'String', ...
    'Click "Output Location" to browse for output folder', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_input_output_paths_db');

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.39 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_create_db);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.38 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_atlas_paths_db
function browse_atlas_paths_db(~, ~)
global param_box_panel atlas_paths
text = 'Select folder having atlas files';
atlas_paths = browse_fldr(text);
handles = guihandles(param_box_panel);
handles.tag_input_atlas_paths_db.String = atlas_paths;
check_create_db_ready

%% Callback for browse_lookup_paths_db
function browse_lookup_paths_db(~, ~)
global param_box_panel lookup_paths
text = 'Select folder having lookup files';
lookup_paths = browse_fldr(text);
handles = guihandles(param_box_panel);
handles.tag_input_lookup_paths_db.String = lookup_paths;
check_create_db_ready

%% Callback for browse_output_path_db
function browse_output_path_db(~, ~)
global param_box_panel output_location
text = 'Select output location';
output_location = browse_fldr(text);
handles = guihandles(param_box_panel);
handles.tag_input_output_paths_db.String = output_location;
check_create_db_ready

%% Check if all inputs for create_database are ready
function check_create_db_ready
global param_box_panel atlas_paths lookup_paths output_location
handles = guihandles(param_box_panel);
if isempty(atlas_paths) || isempty(lookup_paths) || ...
        isempty(output_location)
    handles.tag_run.Enable = 'off';
else
    handles.tag_run.Enable = 'on';
end

%% Run function run_create_db
function run_create_db(~, ~)
global param_box_panel atlas_paths lookup_paths output_location ...
    elapsed_time button_font_size

handles = guihandles(param_box_panel);

% Disable the run button
handles.tag_run.Enable = 'off';

% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.32 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;
% Get cputime now
starttime = cputime;
% Call modify_lookup
create_database(atlas_paths, lookup_paths, output_location);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.26 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);


% // End: All functions for create_db //
% -------------------------------------------------------------------------

% =========================================================================
% // End: left panel functions //
% =========================================================================

% =========================================================================
% // Begin: middle panel functions //
% =========================================================================
% -------------------------------------------------------------------------
% // Begin: All functions for create_vox_map //
%% Callback for create_vox_map
function create_vox_map(~, ~)
global param_box_panel button_font_size db_file output_location elapsed_time 

% Setting default values for input variables
db_file         = '';
output_location = '';
elapsed_time    = 0;

head_text = 'Create voxel map';
desc_text = 'Create voxel map using database information';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for db_file
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select database.mat file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Database File:', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_db_file_voxmap);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Database File" to browse for database.mat file', ...
    'FontSize', button_font_size, 'enable', ' off', ...
    'HorizontalAlignment', 'left', 'tag', 'tag_db_location_voxmap');

% Create guide text, input button, and text box for output_location
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.65 0.70 0.05], 'String', ...
    'Select folder to save voxel map', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.60 0.20 0.05], 'String', ...
    'Output Location: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_output_location_voxmap);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.60 0.70 0.05], 'String', ...
    'Click "Output Location" to browse for lookup folder', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_output_location_voxmap');

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.54 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_create_voxmap);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.53 1.00 0.002] , 'HighlightColor', 'black');

%% Callback function browse_db_file_voxmap
function browse_db_file_voxmap(~, ~)
global param_box_panel db_file
text = 'Select database file';
db_file = browse_db(text);
handles = guihandles(param_box_panel);
handles.tag_db_location_voxmap.String = db_file;
check_voxmap_ready

%% Callback function browse_output_location_voxmap
function browse_output_location_voxmap(~, ~)
global param_box_panel output_location
text = 'Select output location';
output_location = browse_fldr(text);
handles = guihandles(param_box_panel);
handles.tag_output_location_voxmap.String = output_location;
check_voxmap_ready

%% Check if all inputs for create_vox_map are ready
function check_voxmap_ready
global param_box_panel db_file output_location
handles = guihandles(param_box_panel);
if isempty(db_file) || isempty(output_location)
    handles.tag_run.Enable = 'off';
else
    handles.tag_run.Enable = 'on';
end

%% Run function run_create_voxmap
function run_create_voxmap(~, ~)
global param_box_panel db_file output_location elapsed_time button_font_size

handles = guihandles(param_box_panel);

% Disable the run button
handles.tag_run.Enable = 'off';

% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.48 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;

% Get cputime now
starttime = cputime;
% Call modify_lookup
voxel_map(db_file, output_location);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.42 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for create_vox_map //
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% // Begin: All functions for label_coordinates //
%% Callback for label_coordinates
function label_coordinates(~, ~)
global param_box_panel button_font_size db_file input_file threshold elapsed_time 

% Setting default values for input variables
db_file         = '';
input_file      = '';
threshold       = 0;
elapsed_time    = 0;

head_text = 'Label coordinates';
desc_text = 'Label coordinates/image using database information';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for db_file
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select database.mat file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Database File:', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_db_file_label);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Database File" to browse for database.mat file', ...
    'FontSize', button_font_size, 'enable', ' off', ...
    'HorizontalAlignment', 'left', 'tag', 'tag_db_location_label');

% Create guide text, input button, and text box for input_file
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.65 0.70 0.05], 'String', ...
    'Select file to label (.nii/.txt)', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.60 0.20 0.05], 'String', ...
    'Input file: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_label);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.60 0.70 0.05], 'String', ...
    'Click "Input file" to browse for input file', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_input_label');

% Create guide text, input button, and text box for threshold
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.50 0.70 0.05], 'String', ...
    'Set threshold (optional)', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.45 0.20 0.05], 'String', ...
    'Threshold: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.45 0.10 0.05], 'String', num2str(threshold), ...
    'FontSize', button_font_size, 'enable', ' on', 'tag', 'tag_label_thresh', ...
    'HorizontalAlignment', 'left');

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.39 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_label_coordinates);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.38 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_db_file_label
function browse_db_file_label(~, ~)
global param_box_panel db_file
text = 'Select database file';
db_file = browse_db(text);
handles = guihandles(param_box_panel);
handles.tag_db_location_label.String = db_file;
check_label_ready

%% Callback for browse_input_label
function browse_input_label(~, ~)
global param_box_panel input_file
text = 'Select input file (.nii/.txt)';
input_file = browse_txt_nii(text);
handles = guihandles(param_box_panel);
handles.tag_input_label.String = input_file;
check_label_ready

%% Check if all inputs for create_vox_map are ready
function check_label_ready
global param_box_panel db_file input_file
handles = guihandles(param_box_panel);
if isempty(db_file) || isempty(input_file)
    handles.tag_run.Enable = 'off';
else
    handles.tag_run.Enable = 'on';
end

%% Run function run_label_coordinates
function run_label_coordinates(~, ~)
global param_box_panel db_file input_file threshold elapsed_time ...
    button_font_size

% Get final value of threshold
handles = guihandles(param_box_panel);
threshold = str2double(get(handles.tag_label_thresh, 'String'));

% Disable the run button
handles.tag_run.Enable = 'off';

% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.32 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;

% Get cputime now
starttime = cputime;
% Call modify_lookup
label_brain(db_file, input_file, threshold);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.26 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for label_coordinates //
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% // Begin: All functions for calculate_roi_overlap //
function calculate_roi_overlap(~, ~)
global param_box_panel button_font_size db_file output_location num_rois ...
       elapsed_time 

% Setting default values for input variables
db_file         = '';
output_location = '';
num_rois        = 3;
elapsed_time    = 0;

head_text = 'ROI overlap';
desc_text = 'Calculate overlap of ROIs of an atlas with all other atlases using database information';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for db_file
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select database.mat file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Database File:', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_db_file_overlap);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Database File" to browse for database.mat file', ...
    'FontSize', button_font_size, 'enable', ' off', ...
    'HorizontalAlignment', 'left', 'tag', 'tag_db_location_overlap');

% Create guide text, input button, and text box for output_location
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.65 0.70 0.05], 'String', ...
    'Select output location', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.60 0.20 0.05], 'String', ...
    'Input file: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_output_location_overlap);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.60 0.70 0.05], 'String', ...
    'Click "Input file" to browse for input file', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_output_location_overlap');

% Create guide text, input button, and text box for num_rois
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.50 0.70 0.05], 'String', ...
    'Number of ROIs to report', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.45 0.20 0.05], 'String', ...
    'No. of ROIs: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.45 0.10 0.05], 'String', num2str(num_rois), ...
    'FontSize', button_font_size, 'enable', ' on', 'tag', 'tag_num_rois_overlap', ...
    'HorizontalAlignment', 'left');

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.39 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_calculate_roi_overlap);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.38 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_db_file_overlap
function browse_db_file_overlap(~, ~)
global param_box_panel db_file
text = 'Select database file';
db_file = browse_db(text);
handles = guihandles(param_box_panel);
handles.tag_db_location_overlap.String = db_file;
check_calculate_roi_overlap_ready

%% Callback for browse_output_location_overlap
function browse_output_location_overlap(~, ~)
global param_box_panel output_location
text = 'Select output location';
output_location = browse_fldr(text);
handles = guihandles(param_box_panel);
handles.tag_output_location_overlap.String = output_location;
check_calculate_roi_overlap_ready

%% Check if all inputs for calculate_roi_overlap_ready are ready
function check_calculate_roi_overlap_ready
global param_box_panel db_file output_location
handles = guihandles(param_box_panel);
if isempty(db_file) || isempty(output_location)
    handles.tag_run.Enable = 'off';
else
    handles.tag_run.Enable = 'on';
end

%% Run function run_calculate_roi_overlap
function run_calculate_roi_overlap(~, ~)
global param_box_panel db_file output_location num_rois elapsed_time ...
    button_font_size

% Get final value of threshold
handles = guihandles(param_box_panel);
num_rois = str2double(get(handles.tag_num_rois_overlap, 'String'));

% Disable the run button
handles.tag_run.Enable = 'off';

% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.32 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;

% Get cputime now
starttime = cputime;
% Call modify_lookup
calculate_overlap(db_file, output_location, num_rois);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.26 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for calculate_roi_overlap //
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% // Begin: All functions for create_meta_atlas_file //
function create_meta_atlas_file(~, ~)
global param_box_panel button_font_size db_file voxel_map synonym_file ...
       elapsed_time 

% Setting default values for input variables
db_file         = '';
voxel_map       = '';
synonym_file    = '';
elapsed_time    = 0;

head_text = 'Create meta atlas';
desc_text = 'Create meta atlas using database information and voxel map';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for db_file
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select database.mat file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Database File:', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_db_file_meta);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Database File" to browse for database.mat file', ...
    'FontSize', button_font_size, 'enable', ' off', ...
    'HorizontalAlignment', 'left', 'tag', 'tag_db_location_meta');

% Create guide text, input button, and text box for voxel_map
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.65 0.70 0.05], 'String', ...
    'Select voxel map', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.60 0.20 0.05], 'String', ...
    'Voxel map: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_voxel_map_meta);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.60 0.70 0.05], 'String', ...
    'Click "Input file" to browse for input file', 'FontSize', button_font_size, ...
    'enable', ' off', 'HorizontalAlignment', 'left', 'tag', 'tag_voxel_map_meta');

% Create guide text, input button, and text box for synonym file
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.50 0.70 0.05], 'String', ...
    'Select synonym file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.45 0.20 0.05], 'String', ...
    'Synonym file: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_synonym_meta);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.45 0.70 0.05], 'String', ...
    'Click "Synonym File" to browse for synonym file', 'FontSize', button_font_size, ...
    'enable', ' off', 'tag', 'tag_synonym_file_meta', ...
    'HorizontalAlignment', 'left');

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.39 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_create_meta_atlas_file);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.38 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_db_file_meta
function browse_db_file_meta(~, ~)
global param_box_panel db_file
text = 'Select database file';
db_file = browse_db(text);
handles = guihandles(param_box_panel);
handles.tag_db_location_meta.String = db_file;
check_create_meta_atlas_file_ready

%% Callback for browse_voxel_map_meta
function browse_voxel_map_meta(~, ~)
global param_box_panel voxel_map
text = 'Select voxel_map file';
voxel_map = browse_mat(text);
handles = guihandles(param_box_panel);
handles.tag_voxel_map_meta.String = voxel_map;
check_create_meta_atlas_file_ready

%% Callback for browse_synonym_meta
function browse_synonym_meta(~, ~)
global param_box_panel synonym_file
text = 'Select synonym file';
synonym_file = browse_txt(text);
handles = guihandles(param_box_panel);
handles.tag_synonym_file_meta.String = synonym_file;
check_create_meta_atlas_file_ready

%% Check if all inputs for create_meta_atlas_file_ready are ready
function check_create_meta_atlas_file_ready
global param_box_panel db_file voxel_map synonym_file
handles = guihandles(param_box_panel);
if isempty(db_file) || isempty(voxel_map) || isempty(synonym_file)
    handles.tag_run.Enable = 'off';
else
    handles.tag_run.Enable = 'on';
end

%% Run function run_create_meta_atlas_file
function run_create_meta_atlas_file(~, ~)
global param_box_panel db_file voxel_map synonym_file elapsed_time ...
    button_font_size

% Disable the run button
handles = guihandles(param_box_panel);
handles.tag_run.Enable = 'off';

% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.32 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;

% Get cputime now
starttime = cputime;
% Call modify_lookup
create_meta_atlas(db_file, voxel_map, synonym_file);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.26 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for create_meta_atlas_file //
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% // Begin: All functions for threshold_meta_atlas_file //
function threshold_meta_atlas_file(~, ~)
global param_box_panel button_font_size meta_atlas_loc threshold ...
       elapsed_time 

% Setting default values for input variables
meta_atlas_loc  = '';
threshold       = 0.25;
elapsed_time    = 0;

head_text = 'Threshold meta atlas';
desc_text = 'Threshold meta atlas to create deterministic atlas file';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for meta_atlas input
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select meta-atlas file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Meta-Atlas File:', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_meta_atlas_thresh);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Meta-Atlas File" to browse for meta-atlas file', ...
    'FontSize', button_font_size, 'enable', ' off', ...
    'HorizontalAlignment', 'left', 'tag', 'tag_meta_atlas_loc_thresh');

% Create guide text, input button, and text box for threshold
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.65 0.70 0.05], 'String', ...
    'Threshold', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.60 0.20 0.05], 'String', ...
    'Threshold: ', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.60 0.10 0.05], 'String', num2str(threshold), ...
    'FontSize', button_font_size, 'enable', ' on', 'tag', 'tag_threshold_thresh', ...
    'HorizontalAlignment', 'left');

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.54 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_threshold_meta_atlas_file);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.53 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_db_file_meta
function browse_meta_atlas_thresh(~, ~)
global param_box_panel meta_atlas_loc
text = 'Select database file';
meta_atlas_loc = browse_nii(text);
handles = guihandles(param_box_panel);
handles.tag_meta_atlas_loc_thresh.String = meta_atlas_loc;
handles.tag_run.Enable = 'on';

%% Run function run_threshold_meta_atlas_file
function run_threshold_meta_atlas_file(~, ~)
global param_box_panel meta_atlas_loc threshold elapsed_time button_font_size

% Get final value of threshold
handles   = guihandles(param_box_panel);
threshold = str2double(get(handles.tag_threshold_thresh, 'String'));

% Disable the run button
handles.tag_run.Enable = 'off';

% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.48 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;

% Get cputime now
starttime = cputime;
% Call modify_lookup
threshold_meta_atlas(meta_atlas_loc, threshold);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.42 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for threshold_meta_atlas_file //
% -------------------------------------------------------------------------

% =========================================================================
% // End: Middle panel functions //
% =========================================================================

% =========================================================================
% // Begin: Right panel functions //
% =========================================================================

% -------------------------------------------------------------------------
% // Begin: All functions for create_roi_mask //
function create_roi_mask(~, ~)
global param_box_panel path_to_atlas roi_merge_idx elapsed_time button_font_size

% Setting default values for input variables
path_to_atlas   = '';
roi_merge_idx   = '';
elapsed_time    = 0;

head_text = 'Create binary ROI mask';
desc_text = 'Create a single binary ROI mask by merging ROIs from an atlas';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for atlas input
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select atlas file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Atlas File:', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_atlas_roi_merge);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Atlas File" to browse for meta-atlas file', ...
    'FontSize', button_font_size, 'enable', ' off', ...
    'HorizontalAlignment', 'left', 'tag', 'tag_atlas_roi_merge');

% Create guide text and input button for roi_merge_idx
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.65 0.70 0.05], 'String', ...
    'Select ROIs to merge', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'popupmenu', 'position', [0.05 0.60 0.20 0.05], 'String', ...
    {'left', 'right', 'midline', 'left+midline', 'right+midline', ...
    'left+right', 'whole brain', 'custom'},...
    'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'tag', 'tag_list_roi_merge', 'callback', @update_create_roi_ui);

% Set default values for roi_merge_idx and update UI
handles = guihandles(param_box_panel);
set(handles.tag_list_roi_merge, 'Value', 7);
update_create_roi_ui
drawnow

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.54 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_create_roi_mask);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.53 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_atlas_roi_merge
function browse_atlas_roi_merge(~, ~)
global param_box_panel path_to_atlas
text = 'Select database file';
path_to_atlas = browse_nii(text);
handles = guihandles(param_box_panel);
handles.tag_atlas_roi_merge.String = path_to_atlas;
handles.tag_run.Enable = 'on';

%% Update GUI interface for roi_merge_idx
function update_create_roi_ui(~, ~)
global param_box_panel button_font_size
handles = guihandles(param_box_panel);
curr_val = get(handles.tag_list_roi_merge, 'Value');
switch(curr_val)
    % Case left
    case 1
        % Delete all other ui components in this location
        clear_create_roi_ui
        
    % Case right
    case 2
        % Delete all other ui components in this location
        clear_create_roi_ui
        
    % Case midline
    case 3
        % Delete all other ui components in this location
        clear_create_roi_ui
    
    % Case left+midline
    case 4
        % Delete all other ui components in this location
        clear_create_roi_ui
        
    % Case right+midline
    case 5
        % Delete all other ui components in this location
        clear_create_roi_ui
        
    % Case left+right    
    case 6
        % Delete all other ui components in this location
        clear_create_roi_ui
        
    % Case whole brain
    case 7
        % Delete all other ui components in this location
        clear_create_roi_ui
        
    % Case custom
    case 8
        % Delete all other ui components in this location
        clear_create_roi_ui
        % Create input box for indices
        uicontrol('parent', param_box_panel', 'units', 'normalized', ...
            'position', [0.26 0.60 0.70 0.05], 'style', 'edit', 'String', ...
            'Enter indices separated by commas', ...
            'FontSize', button_font_size, 'HorizontalAlignment', 'left', ...
            'tag', 'box_indices');
end

%% Delete UI components from roi_merge_idx
function clear_create_roi_ui
global param_box_panel
handles = guihandles(param_box_panel);
if isfield(handles, 'box_indices')
    delete(handles.box_indices);
end

%% Run function run_create_roi_mask
function run_create_roi_mask(~, ~)
global param_box_panel path_to_atlas roi_merge_idx elapsed_time button_font_size

% Get values for roi_merge_idx
handles = guihandles(param_box_panel);
curr_val_roi_merge_idx = get(handles.tag_list_roi_merge, 'Value');
switch(curr_val_roi_merge_idx)
    case 1
        roi_merge_idx = 'L';
    case 2
        roi_merge_idx = 'R';
    case 3
        roi_merge_idx = 'M';
    case 4
        roi_merge_idx = 'LM';
    case 5
        roi_merge_idx = 'RM';
    case 6
        roi_merge_idx = 'LR';
    case 7
        roi_merge_idx = 'LRM';
    case 8
        roi_merge_idx = str2double(strsplit((get(handles.box_indices, 'String')),','));
end

% Disable the run button
handles.tag_run.Enable = 'off';

% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.48 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;

% Get cputime now
starttime = cputime;
% Call modify_lookup
merge_rois(path_to_atlas, roi_merge_idx);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.42 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for create_roi_mask //
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% // Begin: All functions for atlas_to_rois //
function atlas_to_rois(~, ~)
global param_box_panel path_to_atlas output_location roi_idx roi_labels ...
       elapsed_time button_font_size

% Setting default values for input variables
path_to_atlas   = '';
output_location = '';
roi_idx         = '';
roi_labels      = '';
elapsed_time    = 0;

head_text = 'Create ROI files from atlas';
desc_text = 'Create separate binary ROI files from an atlas';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for atlas input
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select atlas file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Atlas File:', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_atlas_to_rois);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Atlas File" to browse for atlas file', ...
    'FontSize', button_font_size, 'enable', ' off', ...
    'HorizontalAlignment', 'left', 'tag', 'tag_input_atlas_to_rois');

% Create guide text and input button for roi_merge_idx
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.65 0.70 0.05], 'String', ...
    'Select ROIs', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'popupmenu', 'position', [0.05 0.60 0.20 0.05], 'String', ...
    {'all rois', 'all left', 'all right', 'custom'},...
    'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'tag', 'tag_list_roi_idx_atlas_to_rois', ...
    'callback', @update_atlas_to_rois_ui);

% Create guide text, input button, and text box for output location
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.50 0.70 0.05], 'String', ...
    'Select output location', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.45 0.20 0.05], 'String', ...
    'Output Location:', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_output_atlas_to_rois);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.45 0.70 0.05], 'String', ...
    'Click "Output Location" to browse for output location', ...
    'FontSize', button_font_size, 'enable', 'off', ...
    'HorizontalAlignment', 'left', 'tag', 'tag_output_atlas_to_rois');

% Create guide text, input button, and text box for roi_labels
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.35 0.70 0.05], 'String', ...
    'Select labels file (optional)', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.30 0.20 0.05], 'String', ...
    'Labels file:', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_labels_atlas_to_rois);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.30 0.70 0.05], 'String', ...
    'Click "Labels file" to browse for labels file', ...
    'FontSize', button_font_size, 'enable', 'off', ...
    'HorizontalAlignment', 'left', 'tag', 'tag_labels_atlas_to_rois');

% Set default values for roi_idx and update UI
handles = guihandles(param_box_panel);
set(handles.tag_list_roi_idx_atlas_to_rois, 'Value', 1);
update_atlas_to_rois_ui
drawnow

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.24 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_atlas_to_rois);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.23 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_input_atlas_to_rois
function browse_input_atlas_to_rois(~, ~)
global param_box_panel path_to_atlas
text = 'Select input atlas file';
path_to_atlas = browse_nii(text);
handles = guihandles(param_box_panel);
handles.tag_input_atlas_to_rois.String = path_to_atlas;
check_atlas_to_rois_ready

%% Update GUI interface for update_atlas_to_rois_ui
function update_atlas_to_rois_ui(~, ~)
global param_box_panel button_font_size
handles = guihandles(param_box_panel);
curr_val = get(handles.tag_list_roi_idx_atlas_to_rois, 'Value');
switch(curr_val)
    % Case all rois
    case 1
        % Delete all other ui components in this location
        clear_atlas_to_rois_ui
        
    % Case all left
    case 2
        % Delete all other ui components in this location
        clear_atlas_to_rois_ui
        
    % Case all right
    case 3
        % Delete all other ui components in this location
        clear_atlas_to_rois_ui
    
    % Case custom
    case 4
        % Delete all other ui components in this location
        clear_atlas_to_rois_ui
        % Create input box for indices
        uicontrol('parent', param_box_panel', 'units', 'normalized', ...
            'position', [0.26 0.60 0.70 0.05], 'style', 'edit', 'String', ...
            'Enter indices separated by commas', ...
            'FontSize', button_font_size, 'HorizontalAlignment', 'left', ...
            'tag', 'box_indices');
end

%% Delete UI components from atlas_to_rois_ui
function clear_atlas_to_rois_ui
global param_box_panel
handles = guihandles(param_box_panel);
if isfield(handles, 'box_indices')
    delete(handles.box_indices);
end

%% Callback for browse_output_atlas_to_rois
function browse_output_atlas_to_rois(~, ~)
global param_box_panel output_location
text = 'Select output location';
output_location = browse_fldr(text);
handles = guihandles(param_box_panel);
handles.tag_output_atlas_to_rois.String = output_location;
check_atlas_to_rois_ready

%% Callbackfor browse_labels_atlas_to_rois
function browse_labels_atlas_to_rois(~, ~)
global param_box_panel roi_labels
text = 'Select labels file';
roi_labels = browse_txt(text);
handles = guihandles(param_box_panel);
handles.tag_labels_atlas_to_rois.String = roi_labels;
check_atlas_to_rois_ready

%% Check if all inputs for atlas_to_rois are ready
function check_atlas_to_rois_ready
global param_box_panel path_to_atlas output_location 
handles = guihandles(param_box_panel);
if isempty(path_to_atlas) || isempty(output_location)
    handles.tag_run.Enable = 'off';
else
    handles.tag_run.Enable = 'on';
end

%% Run function run_atlas_to_rois
function run_atlas_to_rois(~, ~)
global param_box_panel path_to_atlas roi_idx output_location roi_labels ...
       elapsed_time button_font_size

% Get values for roi_idx
handles = guihandles(param_box_panel);
curr_val_roi_merge_idx = get(handles.tag_list_roi_idx_atlas_to_rois, 'Value');
switch(curr_val_roi_merge_idx)
    case 1
        roi_idx = 'all';
    case 2
        roi_idx = 'left';
    case 3
        roi_idx = 'right';
    case 4
        roi_idx = str2double(strsplit((get(handles.box_indices, 'String')),','));
end

% Disable the run button
handles.tag_run.Enable = 'off';

% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.18 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;

% Get cputime now
starttime = cputime;
% Call modify_lookup
atlas_to_roi(path_to_atlas, output_location, roi_idx, roi_labels);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.12 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for atlas_to_rois //
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% // Begin: All functions for check_midline_vox //
function check_midline_vox(~, ~)
global param_box_panel path_to_atlas msg elapsed_time button_font_size

% Setting default values for input variables
path_to_atlas   = '';
msg             = '';
elapsed_time    = 0;

head_text = 'Check midline voxels';
desc_text = 'Check how midline voxels of an atlas are defined';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for atlas input
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select atlas file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Atlas File:', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_check_midline);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Atlas File" to browse for atlas file', ...
    'FontSize', button_font_size, 'enable', ' off', ...
    'HorizontalAlignment', 'left', 'tag', 'tag_input_check_midline');

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.69 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_check_midline);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.68 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_input_atlas_to_rois
function browse_input_check_midline(~, ~)
global param_box_panel path_to_atlas
text = 'Select input atlas file';
path_to_atlas = browse_nii(text);
handles = guihandles(param_box_panel);
handles.tag_input_check_midline.String = path_to_atlas;
handles.tag_run.Enable = 'on';

%% Run function run_check_midline
function run_check_midline(~, ~)
global param_box_panel path_to_atlas msg elapsed_time button_font_size

% Disable the run button
handles = guihandles(param_box_panel);
handles.tag_run.Enable = 'off';

% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.63 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;

% Get cputime now
starttime = cputime;
% Call modify_lookup
msg = check_atlas_midline(path_to_atlas);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.57 0.90 0.05], 'String', ...
    [msg, ' (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for check_midline_vox //
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% // Begin: All functions for map_midline_vox //
function map_midline_vox(~, ~)
global param_box_panel path_to_atlas elapsed_time button_font_size

% Setting default values for input variables
path_to_atlas   = '';
elapsed_time    = 0;

head_text = 'Map midline voxels';
desc_text = 'Map how midline voxels of an atlas are defined';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for atlas input
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select atlas file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Atlas File:', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_map_midline);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Atlas File" to browse for atlas file', ...
    'FontSize', button_font_size, 'enable', ' off', ...
    'HorizontalAlignment', 'left', 'tag', 'tag_input_map_midline');

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.69 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_map_midline);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.68 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_input_map_midline
function browse_input_map_midline(~, ~)
global param_box_panel path_to_atlas
text = 'Select input atlas file';
path_to_atlas = browse_nii(text);
handles = guihandles(param_box_panel);
handles.tag_input_map_midline.String = path_to_atlas;
handles.tag_run.Enable = 'on';

%% Run function run_map_midline
function run_map_midline(~, ~)
global param_box_panel path_to_atlas elapsed_time button_font_size

% Disable the run button
handles = guihandles(param_box_panel);
handles.tag_run.Enable = 'off';

% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.63 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;

% Get cputime now
starttime = cputime;
% Call modify_lookup
map_atlas_midline(path_to_atlas);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.57 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for map_midline_vox //
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% // Begin: All functions for meta_atlas_to_rois //
function meta_atlas_to_rois(~, ~)
global param_box_panel path_to_atlas output_location elapsed_time button_font_size

% Setting default values for input variables
path_to_atlas   = '';
output_location = '';
elapsed_time    = 0;

head_text = 'Meta-atlas to ROIs';
desc_text = 'Convert meta-atlas into individual binary ROI files';
create_parameter_box(head_text, desc_text)

% Create guide text, input button, and text box for atlas input
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.80 0.70 0.05], 'String', ...
    'Select atlas file', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.75 0.20 0.05], 'String', ...
    'Atlas File:', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_input_meta_atlas_to_rois);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.75 0.70 0.05], 'String', ...
    'Click "Atlas File" to browse for atlas file', ...
    'FontSize', button_font_size, 'enable', ' off', ...
    'HorizontalAlignment', 'left', 'tag', 'tag_input_meta_atlas_to_rois');

% Create guide text, input button, and text box for output location
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.65 0.70 0.05], 'String', ...
    'Select output location', 'FontSize', button_font_size, ...
    'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.05 0.60 0.20 0.05], 'String', ...
    'Output Locatin:', 'FontSize', button_font_size, 'FontWeight', 'bold', ...
    'enable', 'on', 'callback', @browse_output_meta_atlas_to_rois);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'edit', 'position', [0.26 0.60 0.70 0.05], 'String', ...
    'Click "Output Location" to browse for output location', ...
    'FontSize', button_font_size, 'enable', ' off', ...
    'HorizontalAlignment', 'left', 'tag', 'tag_output_meta_atlas_to_rois');

% Draw the run button
uicontrol('parent', param_box_panel , 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.54 0.10 0.05], 'String', 'Run', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'off', ...
    'tag', 'tag_run', 'callback', @run_meta_atlas_to_rois);

% Draw a frame a little below the input buttons (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.53 1.00 0.002] , 'HighlightColor', 'black');

%% Callback for browse_input_meta_atlas_to_rois
function browse_input_meta_atlas_to_rois(~, ~)
global param_box_panel path_to_atlas
text = 'Select input atlas file';
path_to_atlas = browse_nii(text);
handles = guihandles(param_box_panel);
handles.tag_input_meta_atlas_to_rois.String = path_to_atlas;
check_meta_atlas_to_rois_ready

%% Callback for browse_output_meta_atlas_to_rois
function browse_output_meta_atlas_to_rois(~, ~)
global param_box_panel output_location
text = 'Select input atlas file';
output_location = browse_fldr(text);
handles = guihandles(param_box_panel);
handles.tag_output_meta_atlas_to_rois.String = output_location;
check_meta_atlas_to_rois_ready

%% Check if all inputs for meta_atlas_to_rois are ready
function check_meta_atlas_to_rois_ready
global param_box_panel path_to_atlas output_location 
handles = guihandles(param_box_panel);
if isempty(path_to_atlas) || isempty(output_location)
    handles.tag_run.Enable = 'off';
else
    handles.tag_run.Enable = 'on';
end

%% Run function run_meta_atlas_to_rois
function run_meta_atlas_to_rois(~, ~)
global param_box_panel path_to_atlas output_location elapsed_time button_font_size

% Disable the run button
handles = guihandles(param_box_panel);
handles.tag_run.Enable = 'off';

% Start waiting
clean_wait_area;
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.48 0.90 0.05], 'String', ...
    'Running script; please wait...', 'tag', 'tag_wait_running', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');
drawnow;

% Get cputime now
starttime = cputime;
% Call modify_lookup
meta_atlas_to_roi(path_to_atlas, output_location);
% Get cputime now
endtime = cputime;
% Time elapsed
elapsed_time = endtime - starttime;
% Enable the run button again
handles.tag_run.Enable = 'on';
% End waiting
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.42 0.90 0.05], 'String', ...
    ['Finished running (', num2str(elapsed_time), ' seconds)'], ...
    'tag', 'tag_wait_finished', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', [0 0.5 0]);

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'pushbutton', 'position', [0.45 0.01 0.10 0.05], 'String', 'Close', ...
    'FontSize', button_font_size, 'FontWeight', 'bold', 'enable', 'on', ...
    'callback', @delete_param_box);

% // End: All functions for meta_atlas_to_rois //
% -------------------------------------------------------------------------

% =========================================================================
% // End: Right panel functions //
% =========================================================================

% =========================================================================
% // Begin: All general functions //
% =========================================================================
%% Create parameter input box
function create_parameter_box(head_text, desc_text)
global parent_figure panel_left panel_dim_spacing param_box_panel ...
    panel_text_font_size button_font_size

param_box_head = head_text;
param_box_text = desc_text;

% Get current position of the left panel of parent figure
[param_box_left, param_box_bot, param_box_width, param_box_height] = ...
    get_current_position(panel_left);

% Adjust width to reach the right panel of parent figure
param_box_width = (param_box_width*3) + (panel_dim_spacing*2);

% Set drawing position for parameter box panel
param_box_position = [param_box_left param_box_bot param_box_width param_box_height];

% Draw parameter box panel
param_box_panel = uipanel('parent', parent_figure, 'units', 'normalized', ...
    'position', param_box_position, 'HighlightColor', 'black');

% Add text to the parameter box panel
uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.94 0.90 0.05], 'String', param_box_head, ...
    'FontSize', panel_text_font_size, 'FontWeight', 'bold', 'FontAngle', ...
    'italic', 'HorizontalAlignment', 'left');

uicontrol('parent', param_box_panel, 'units', 'normalized', 'style', ...
    'text', 'position', [0.05 0.88 0.90 0.05], 'String', param_box_text, ...
    'FontSize', button_font_size, 'HorizontalAlignment', 'left');

% Draw a frame below the text (to resemble a line)
uipanel('parent', param_box_panel, 'units', 'normalized', 'position', ...
    [0.00 0.87 1.00 0.002] , 'HighlightColor', 'black');

%% Delete parameter box
function delete_param_box(~, ~)
global param_box_panel
delete(param_box_panel);

%% Get current position of a figure or figure component
function [left, bot, width, height] = get_current_position(fig)
curr_position = get(fig, 'position');
left   = curr_position(1);
bot    = curr_position(2);
width  = curr_position(3);
height = curr_position(4);

%% Browse nifti file
function selected_file = browse_nii(which_file)
[atlas_name, path_to_atlas] = uigetfile('*.nii', which_file);
[~, ~, ext] = fileparts(atlas_name);
if strcmp(ext, '.nii')
    selected_file = fullfile(path_to_atlas, atlas_name);
end

%% Browse output folder
function selected_folder = browse_fldr(which_folder)
selected_folder = uigetdir(pwd, which_folder);

%% Browse text file
function selected_file = browse_txt(which_file)
[selected_file, path_to_file] = uigetfile('*.txt', which_file);
[~, ~, ext] = fileparts(selected_file);
if strcmp(ext, '.txt')
    selected_file = fullfile(path_to_file, selected_file);
end

%% Browse database mat file
function selected_file = browse_db(which_file)
[selected_file, path_to_file] = uigetfile('database.mat', which_file);
[~, ~, ext] = fileparts(selected_file);
if strcmp(ext, '.mat')
    selected_file = fullfile(path_to_file, selected_file);
end

%% Browse mat file
function selected_file = browse_mat(which_file)
[selected_file, path_to_file] = uigetfile('*.mat', which_file);
[~, ~, ext] = fileparts(selected_file);
if strcmp(ext, '.mat')
    selected_file = fullfile(path_to_file, selected_file);
end

%% Browse text/nifti file
function selected_file = browse_txt_nii(which_file)
[file_name, file_path] = uigetfile({'*.nii; *.txt'}, which_file);
[~, ~, ext] = fileparts(file_name);
if strcmp(ext, '.nii') || strcmp(ext, '.txt') 
    selected_file = fullfile(file_path, file_name);
end

%% Clean waiting area
function clean_wait_area
global param_box_panel
handles = guihandles(param_box_panel);
if isfield(handles, 'tag_wait_running')
    delete(handles.tag_wait_running);
end
if isfield(handles, 'tag_wait_finished')
    delete(handles.tag_wait_finished);
end
drawnow

%% Function go_home
function go_home(~, ~)
global param_box_panel
if ~isempty(param_box_panel)
    delete(param_box_panel);
end

% =========================================================================
% // End: All general functions //
% =========================================================================