 function varargout = evt_GUI(varargin)
% EVT_GUI creates a new evt_GUI or raises the existing singleton
%
% 3DFM function
% GUIs/evt_GUI
% last modified 08/26/10
%
% evt_GUI M-file for evt_GUI.fig
%      evt_GUI, by itself, creates a new evt_GUI or raises the existing
%      singleton*.
%
%      H = evt_GUI returns the handle to a new evt_GUI or the handle to
%      the existing singleton*.
%
%      evt_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in evt_GUI.M with the given input arguments.
%
%      evt_GUI('Property','Value',...) creates a new evt_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before evt_GUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to evt_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help evt_GUI

% Last Modified by GUIDE v2.5 10-Feb-2011 11:41:25

	% Begin initialization code - DO NOT EDIT
	gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @evt_GUI_OpeningFcn, ...
                       'gui_OutputFcn',  @evt_GUI_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
	if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
	end
	
	if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
	else
        gui_mainfcn(gui_State, varargin{:});
	end
	% End initialization code - DO NOT EDIT
    

function evt_GUI_OpeningFcn(hObject, eventdata, handles, varargin)

	% Choose default command line output for evt_GUI
	handles.output = hObject;
	
	% Update handles structure
	guidata(hObject, handles);
	
	% UIWAIT makes evt_GUI wait for user response (see UIRESUME)
	% uiwait(handles.evt_GUI);


% --- Outputs from this function are returned to the command line.
function varargout = evt_GUI_OutputFcn(hObject, eventdata, handles)
	
	% Get default command line output from handles structure
	varargout{1} = handles.output;

    
% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles) %#ok<DEFNU>
    if isfield(handles, 'XYfig');
        try
            close(handles.XYfig);
        catch
        end
    end

    if isfield(handles, 'XTfig');
        try
            close(handles.XTfig);
        catch
        end
    end

    if isfield(handles, 'AUXfig');
        try
            close(handles.AUXfig);
        catch
        end
    end

	close(evt_GUI);

    
% --- Executes on button press in radio_selected_dataset.
function radio_selected_dataset_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 1);
	set(handles.radio_boundingbox, 'Value', 0);
	set(handles.radio_deletetimebefore, 'Value', 0);
	set(handles.radio_deletetimeafter, 'Value', 0);

    
% --- Executes on button press in radio_boundingbox.
function radio_boundingbox_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_boundingbox, 'Value', 1);
	set(handles.radio_deletetimebefore, 'Value', 0);
	set(handles.radio_deletetimeafter, 'Value', 0);
    
    
% --- Executes on button press in radio_deletetimebefore.
function radio_deletetimebefore_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_boundingbox, 'Value', 0);
	set(handles.radio_deletetimebefore, 'Value', 1);
	set(handles.radio_deletetimeafter, 'Value', 0);

    
% --- Executes on button press in radio_deletetimebefore.
function radio_deletetimeafter_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_boundingbox, 'Value', 0);
	set(handles.radio_deletetimebefore, 'Value', 0);
	set(handles.radio_deletetimeafter, 'Value', 1);
    
    
% --- Executes on button press in radio_XYfig.
function radio_XYfig_Callback(hObject, eventdata, handles)
    set(handles.radio_XYfig,  'Value', 1);
    set(handles.radio_XTfig,  'Value', 0);    
    set(handles.radio_AUXfig, 'Value', 0);

    
% --- Executes on button press in radio_XTfig.
function radio_XTfig_Callback(hObject, eventdata, handles)
    set(handles.radio_XYfig,  'Value', 0);
    set(handles.radio_XTfig,  'Value', 1);
    set(handles.radio_AUXfig, 'Value', 0);

% --- Executes on button press in radio_AUXfig.
function radio_AUXfig_Callback(hObject, eventdata, handles)
    set(handles.radio_XYfig,  'Value', 0);
    set(handles.radio_XTfig,  'Value', 0);
    set(handles.radio_AUXfig, 'Value', 1);    
    
% --- Executes during object creation, after setting all properties.
function edit_infile_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_infile_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_loadfile.
function pushbutton_loadfile_Callback(hObject, eventdata, handles)
    video_tracking_constants;

    % reset the Active Bead to 0
    set(handles.edit_BeadID, 'String', '0');
    set(handles.slider_BeadID, 'Value', 0);
    
    filename = get(handles.edit_infile, 'String');
    
    if(isempty(filename))
		[fname, pname] = uigetfile({'*.mat';'*.csv';'*.*'});
        
        if sum(length(fname), length(pname)) <= 1
            logentry('No tracking file selected. No tracking file loaded.');
            return;
        end        
        
		filename = strcat(pname, fname);
        logentry(['Setting Path to: ' pname]);
        cd(pname);
		set(handles.edit_infile,'String', filename);
        set(handles.edit_outfile, 'String', '');
    end   

    filenameroot = strrep(filename,     '.raw', '');
    filenameroot = strrep(filenameroot, '.vrpn', '');
    filenameroot = strrep(filenameroot, '.mat', '');
    filenameroot = strrep(filenameroot, '.evt', '');

    % load the datafile
    logentry('Loading dataset... ');
    
    % assign "filter by" values if they're selected
    if get(handles.checkbox_minFrames, 'Value')
        minFrames = str2num(get(handles.edit_minFrames, 'String'));
    else
        minFrames = 1;
    end
        
    if get(handles.checkbox_minPixelRange, 'Value')
        minPixelRange = str2num(get(handles.edit_minPixelRange, 'String'));
    else
        minPixelRange = 0;
    end

    if get(handles.checkbox_tCrop, 'Value')
        tCrop = str2num(get(handles.edit_tCrop, 'String'));
    else
        tCrop = 0;
    end
    
    if get(handles.checkbox_xyCrop, 'Value')
        xyCrop = str2num(get(handles.edit_xyCrop, 'String'));
    else
        xyCrop = 0;
    end
    
    
    try
        d = load_video_tracking(filename, [], [], [], 'absolute', 'yes', 'table', minFrames, minPixelRange, tCrop, xyCrop);
    catch
        msgbox('File Not Loaded! Problem with load_video_tracking.', 'Error.');
        return;
    end
    set(handles.edit_infile, 'TooltipString', filename);
    set(handles.edit_infile, 'String', '');
    logentry(['Dataset, ' filename ', successfully loaded...']);
    
    % try loading the MIP file
    try 
        MIPfile = [filenameroot, '.MIP.bmp'];
        im = imread(MIPfile, 'BMP');
        logentry('Successfully loaded MIP image...');
        MIPexists = 1;
    catch
        try 
            MIPfile = [filenameroot, '.vrpn.composite.tif'];
            im = imread(MIPfile, 'tif');
            logentry('Successfully loaded MIP image...');
            MIPexists = 1;
        catch        
            logentry('MIP file was not found.  Trying to load first frame...');

            % or, try loading the first frame        
            try
                fimfile = [filenameroot, '0001.bmp'];
                im = imread(fimfile, 'BMP');
                logentry('Successfully loaded first frame image...');            
            catch
                logentry('first frame image was not found. Trying to extract first frame...');

                % last chance.... try extracting first frame
                try
                    rawfile = [filenameroot '.RAW'];
                    im = raw2img(rawfile, 'BMP', 1, 1);
                    logentry('Successfully extracted first frame image...');
                catch
                    logentry('Could not extract image; RAW file not found.  Giving up...');
                    im = 0;
                end
            end        
        end
    end
    
    % if the background MIP image exists, attach it to handles structure
    if exist('im', 'var')
        handles.im = im;
    end
    
    if exist('MIPexists', 'var') && get(handles.checkbox_LumiCrop, 'Value')
        desired_lum = str2num(get(handles.edit_LumiCrop, 'String'));
        threshmult = 1.0;
        
        [d,~,~] = filter_bead_aggregates(d, im, desired_lum, threshmult);
    elseif get(handles.checkbox_LumiCrop, 'Value')
        logentry('Cannot filter based on luminance because there no MIP exists');
    end
    % set the default output filename
    outfile = get(handles.edit_outfile, 'String');
    if isempty(outfile)
        outfile = [pname fname(1:end-3) 'evt.mat'];
        set(handles.edit_outfile, 'String', outfile);
    end
    set(handles.edit_outfile, 'TooltipString', outfile);

    % assign data variables
    table = d;
    mintime = min(table(:,TIME));
    maxtime = max(table(:,TIME));
    beadID = table(:,ID);

    % update fps editbox so there is an indicator of real timesteps
    idx = find(beadID == 0);
    tsfps = round(1/mean(diff(table(idx,TIME))));
    logentry(['Setting frame rate to ' num2str(tsfps) ' fps.']);
    set(handles.edit_frame_rate, 'String', num2str(tsfps));
    
    % construct figure handles if they don't already exist
    if isfield(handles, 'XYfig')
        XYfig = figure(handles.XYfig);
    else
        XYfig = figure;
    end
    
    if isfield(handles, 'XTfig')
        XTfig = figure(handles.XTfig);
    else
        XTfig = figure;
    end

    if isfield(handles, 'AUXfig')
        AUXfig = figure(handles.AUXfig);
    else            
        AUXfig = figure;         
        set(AUXfig, 'Visible', 'off');
    end    
    
    if ~isfield(handles, 'AUXtype')
        handles.AUXtype = 'OFF';
    end
    
    
    % set default figure parameters
    set(XYfig, 'Units', 'Normalized');
    set(XYfig, 'Position', [0.1 0.05 0.4 0.4]);
    set(XYfig, 'DoubleBuffer', 'on');
    set(XYfig, 'BackingStore', 'off');
    
    set(XTfig, 'Units', 'Normalized');
    set(XTfig, 'Position', [0.51 0.05 0.4 0.4]);
    set(XTfig, 'DoubleBuffer', 'on');
    set(XTfig, 'BackingStore', 'off');   
    
    set(AUXfig, 'Units', 'Normalized');
    set(AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
    set(AUXfig, 'DoubleBuffer', 'on');
    set(AUXfig, 'BackingStore', 'off');  

    % handle peculiarities of sliders (still not perfected)
	slider_max = max(beadID);
	slider_min = 0;
    if slider_min == slider_max
        slider_max = slider_min + 1;
    end
    
	slider_step = 1/(slider_max - slider_min);
    	
	set(handles.slider_BeadID, 'Min', slider_min);
	set(handles.slider_BeadID, 'Max', slider_max);
	set(handles.slider_BeadID, 'SliderStep', [slider_step slider_step]);

    % export important data to handles structure
    handles.XYfig = XYfig;
    handles.XTfig = XTfig;
    handles.AUXfig = AUXfig;
    handles.table = table;
    handles.mintime = mintime;
    handles.maxtime = maxtime;
    handles.tstamp_times = table(:,TIME);
    handles.recomputeMSD = 1;
    
    % Enable all of the controls now that data is loaded
    set(handles.checkbox_frame_rate                 , 'Enable', 'on');
    set(handles.text_frame_rate                     , 'Enable', 'on');
    set(handles.edit_BeadID                         , 'Enable', 'on');
    set(handles.slider_BeadID                       , 'Enable', 'on');
    set(handles.pushbutton_Select_Closest_xydataset , 'Enable', 'on');
    set(handles.radio_XYfig                         , 'Enable', 'on');
    set(handles.radio_XTfig                         , 'Enable', 'on');
    set(handles.radio_AUXfig                        , 'Enable', 'on');
    set(handles.checkbox_neutoffsets                , 'Enable', 'on');
    set(handles.checkbox_overlayxy                  , 'Enable', 'on');
    set(handles.radio_selected_dataset              , 'Enable', 'on');
    set(handles.radio_boundingbox                   , 'Enable', 'on');
    set(handles.radio_deletetimebefore              , 'Enable', 'on');
    set(handles.radio_deletetimeafter               , 'Enable', 'on');
    set(handles.pushbutton_Edit_Data                , 'Enable', 'on');
    set(handles.popup_AUXplot                       , 'Enable', 'on');
    set(handles.radio_relative                      , 'Enable', 'on');
    set(handles.radio_arb_origin                    , 'Enable', 'on');
    set(handles.edit_arb_origin                     , 'Enable', 'on');
    set(handles.radio_com                           , 'Enable', 'on');
    set(handles.radio_linear                        , 'Enable', 'on');
    set(handles.radio_linearmean                    , 'Enable', 'on');
    set(handles.pushbutton_select_drift_region      , 'Enable', 'on');
    set(handles.pushbutton_remove_drift             , 'Enable', 'on');
    set(handles.radio_pixels                        , 'Enable', 'on');
    set(handles.radio_microns                       , 'Enable', 'on');
    set(handles.edit_calib_um                       , 'Enable', 'on');
    set(handles.text_calib_um                       , 'Enable', 'on');
    set(handles.pushbutton_export_all_beads         , 'Enable', 'on');
    set(handles.pushbutton_export_bead              , 'Enable', 'on');
    set(handles.pushbutton_measure_distance         , 'Enable', 'on');
    
    set(handles.checkbox_msdmean, 'Value', 1);
    
    plot_data(hObject, eventdata, handles);
    guidata(hObject, handles);

    
% --- Executes on button press in pushbutton_savefile.
function pushbutton_savefile_Callback(hObject, eventdata, handles)
    video_tracking_constants;

	outfile = get(handles.edit_outfile, 'String');
    
    if (isempty(outfile))
        msgbox('No filename specified for output.', 'Error.');
        return;
    end
    
    tracking.spot3DSecUsecIndexFramenumXYZRPY = handles.table;
    save(outfile, 'tracking');
    logentry(['New tracking file, ' outfile ', saved...']);
    
    set(handles.edit_infile, 'String', '');
    set(handles.edit_outfile, 'String', '');    

       
% --- Executes during object creation, after setting all properties.
function edit_outfile_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_outfile_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_Edit_Data.
function pushbutton_Edit_Data_Callback(hObject, eventdata, handles)

    if get(handles.radio_AUXfig, 'Value')
        logentry('AUXfigs are not allowed to delete data');
        return;
    end
    
    global hand;
    
    set(handles.radio_selected_dataset, 'Enable', 'Off');
	set(handles.radio_boundingbox,      'Enable', 'Off');
    set(handles.radio_deletetimebefore, 'Enable', 'Off');
    set(handles.radio_deletetimeafter,  'Enable', 'Off');
    
	
	if (get(handles.radio_selected_dataset, 'Value'))
        set(handles.radio_XTfig, 'Enable', 'off');
        set(handles.radio_XYfig, 'Enable', 'off');
        set(handles.radio_AUXfig,'Enable', 'off');
        
        delete_selected_dataset(hObject, eventdata, handles);
        
        set(handles.radio_XTfig, 'Enable', 'on');
        set(handles.radio_XYfig, 'Enable', 'on');
        set(handles.radio_AUXfig,'Enable', 'on');        
        
    elseif (get(handles.radio_boundingbox, 'Value'))
        set(handles.radio_XTfig, 'Enable', 'off');
        set(handles.radio_XYfig, 'Enable', 'off');
        set(handles.radio_AUXfig,'Enable', 'off');
        
        delete_inside_boundingbox(hObject, eventdata, handles);
        
        set(handles.radio_XTfig, 'Enable', 'on');
        set(handles.radio_XYfig, 'Enable', 'on');
        set(handles.radio_AUXfig,'Enable', 'on');        
        
    elseif (get(handles.radio_deletetimebefore, 'Value'))
        set(handles.radio_XTfig, 'Value', 1, 'Enable', 'off');
        set(handles.radio_XYfig, 'Value', 0, 'Enable', 'off');
        set(handles.radio_AUXfig, 'Value', 0, 'Enable', 'off');

        delete_data_before_time(hObject, eventdata, handles);
        
        set(handles.radio_XTfig, 'Enable', 'on');
        set(handles.radio_XYfig, 'Enable', 'on');
        set(handles.radio_AUXfig, 'Enable', 'on');
    elseif (get(handles.radio_deletetimeafter, 'Value'))
        set(handles.radio_XTfig, 'Value', 1, 'Enable', 'off');
        set(handles.radio_XYfig, 'Value', 0, 'Enable', 'off');
        set(handles.radio_AUXfig, 'Value', 0, 'Enable', 'off');

        delete_data_after_time(hObject, eventdata, handles);
        
        set(handles.radio_XTfig, 'Enable', 'on');
        set(handles.radio_XYfig, 'Enable', 'on');
        set(handles.radio_AUXfig, 'Enable', 'on');
        
	else
        msgbox('One of the data handling methods must be selected.', ...
               'Error.');
    end

    handles = hand;
    
	set(handles.radio_selected_dataset, 'Enable', 'On');
	set(handles.radio_boundingbox, 'Enable', 'On');
    set(handles.radio_deletetimebefore, 'Enable', 'On');
    set(handles.radio_deletetimeafter, 'Enable', 'On');
    
    handles.recomputeMSD = 1;
    
    plot_data(hObject, eventdata, handles);
    
    guidata(hObject, handles);
    
    
% --- Executes during object creation, after setting all properties.
function slider_BeadID_CreateFcn(hObject, eventdata, handles)
	usewhitebg = 1;
	if usewhitebg
        set(hObject,'BackgroundColor',[.9 .9 .9]);
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


% --- Executes on slider movement.
function slider_BeadID_Callback(hObject, eventdata, handles)
	currentBead = round(get(handles.slider_BeadID, 'Value'));
	set(handles.edit_BeadID, 'String', num2str(currentBead));
    
    plot_data(hObject, eventdata, handles);
    drawnow;
    

% --- Executes during object creation, after setting all properties.
function edit_BeadID_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_BeadID_Callback(hObject, eventdata, handles)
	set(handles.slider_BeadID, 'Value', round(str2double(get(handles.edit_BeadID, 'String'))));

    
% --- Executes on button press in pushbutton_Select_Closest_xydataset.
function pushbutton_Select_Closest_xydataset_Callback(hObject, eventdata, handles)
    video_tracking_constants;
    
    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XYfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XYfig;
    elseif(get(handles.radio_AUXfig, 'Value'))
        active_fig = handles.AUXfig;
    end

    if get(handles.radio_XYfig, 'Value') || get(handles.radio_XTfig, 'Value')
        
        if get(handles.radio_XTfig, 'Value')
            logentry('Selecting closest dataset for XT plot does not make sense.  Resetting to XYplot');
            set(handles.radio_XTfig, 'Value', 0);
            set(handles.radio_XYfig, 'Value', 1);
        end
        
        figure(handles.XYfig);
        [xm, ym] = ginput(1);

        if get(handles.radio_microns, 'Value')
            calib_um = str2double(get(handles.edit_calib_um, 'String'));
            xm = xm / calib_um;
            ym = ym / calib_um;
        end        

        beadID = handles.table(:,ID);    
        x = handles.table(:,X);
        y = handles.table(:,Y);

        xval = repmat(xm, length(x), 1);
        yval = repmat(ym, length(y), 1);

        dist = sqrt((x - xval).^2 + (y - yval).^2);

        bead_to_select = beadID(find(dist == min(dist)));

        set(handles.slider_BeadID, 'Value', round(bead_to_select));
        set(handles.edit_BeadID, 'String', round(num2str(bead_to_select)));
    end
    
    if get(handles.radio_AUXfig, 'Value')
        
        AUXplottypes = get(handles.popup_AUXplot, 'String');
        AUXplotvalue = get(handles.popup_AUXplot, 'Value');
        
        myAUXplottype = AUXplottypes{AUXplotvalue};
        
        switch myAUXplottype
            case 'MSD'
                figure(handles.AUXfig);
                
                mymsd = handles.mymsd;

                [xm, ym] = ginput(1);

                
                xval = repmat(xm, size(mymsd.tau));
                yval = repmat(ym, size(mymsd.msd));
        
                beadID = handles.table(:,ID);    
                x = log10(mymsd.tau);
                y = log10(mymsd.msd);

                dist = sqrt((x - xval).^2 + (y - yval).^2);

                [mindist, bead_to_select] = min(min(dist));

                bead_to_select = round(bead_to_select);
                
                set(handles.slider_BeadID, 'Value', bead_to_select-1);
                set(handles.edit_BeadID, 'Value', bead_to_select-1);
                       
            otherwise
                logentry('Select closest dataset not yet written for AUXplot type you chose');                
                return;
        end
    end
    
    
    plot_data(hObject, eventdata, handles);
    

% --- Executes on button press in pushbutton_measure_distance.
function pushbutton_measure_distance_Callback(hObject, eventdata, handles)
    video_tracking_constants;

    figure(handles.XYfig);
	[xm, ym] = ginput(2);
    li = line(xm,ym);
    set(li, 'Color', 'k');
    set(li, 'Marker', 'o');
    set(li, 'MarkerSize', 8);
    
    if get(handles.radio_microns, 'Value')
        calib_um = str2double(get(handles.edit_calib_um, 'String'));
%         xm = xm / calib_um;
%         ym = ym / calib_um;
        units = 'um';
    else
        units = 'pixels';
    end        
        
    dist = sqrt((xm(2) - xm(1)).^2 + (ym(2) - ym(1)).^2);
    
    diststr = [num2str(round(dist)) ' ' units];
    set(handles.text_distance, 'String', diststr);


    
% --- Executes on button press in pushbutton_select_drift_region.
function pushbutton_select_drift_region_Callback(hObject, eventdata, handles)
    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_AUXfig, 'Value'))
        active_fig = handles.XTfig;
    end
    figure(active_fig);

    [xm, ym] = ginput(2);
   
    xlo = min(xm) + handles.mintime;
    xhi = max(xm) + handles.mintime;

    handles.drift_tzero = xlo;
	handles.drift_tend = xhi;
	guidata(hObject, handles);

    
% --- Executes on button press in radio_com.
function radio_com_Callback(hObject, eventdata, handles)
	set(handles.radio_com, 'Value', 1);
	set(handles.radio_linear, 'Value', 0);
    set(handles.radio_linearmean, 'Value', 0);

% --- Executes on button press in radio_linear.
function radio_linear_Callback(hObject, eventdata, handles)
	set(handles.radio_com, 'Value', 0);
	set(handles.radio_linear, 'Value', 1);
    set(handles.radio_linearmean, 'Value', 0);

    % --- Executes on button press in radio_linearmean.
function radio_linearmean_Callback(hObject, eventdata, handles)
	set(handles.radio_com, 'Value', 0);
	set(handles.radio_linear, 'Value', 0);
    set(handles.radio_linearmean, 'Value', 1);



% --- Executes on button press in pushbutton_export_bead.
function pushbutton_export_bead_Callback(hObject, eventdata, handles)
    video_tracking_constants;

    currentBead = round(get(handles.slider_BeadID, 'Value'));
    beadID = handles.table(:,ID);

    k = find(beadID == currentBead);

    bead.t      = handles.table(k,TIME);
    bead.t      = bead.t - min(handles.table(:,TIME));
    bead.x      = handles.table(k,X);
    bead.y      = handles.table(k,Y);
    if isfield(bead, 'yaw');
        bead.yaw    = handles.table(idx,YAW);
    end
    
    assignin('base', ['bead' num2str(currentBead)], bead);
    
    
% --- Executes on button press in pushbutton_export_all_beads.
function pushbutton_export_all_beads_Callback(hObject, eventdata, handles)
    video_tracking_constants;
    
    beadID = handles.table(:,ID);

    for k = 0:max(beadID)
    
        idx = find(beadID == k);

        bead(k+1).t      = handles.table(idx,TIME) - min(handles.table(:,TIME));
        bead(k+1).x      = handles.table(idx,X);
        bead(k+1).y      = handles.table(idx,Y);
        bead(k+1).yaw    = handles.table(idx,YAW);
        
    end
    
    assignin('base', 'beads', bead);
    
    
% --- Executes on button press in radio_pixels.
function radio_pixels_Callback(hObject, eventdata, handles)
    set(handles.radio_pixels, 'Value', 1);
    set(handles.radio_microns, 'Value', 0);

    diststr = get(handles.text_distance, 'String');
    
    if findstr(diststr, 'um')
    elseif findstr(diststr, 'pixels')
    else
    end
    
    plot_data(hObject, eventdata, handles);


% --- Executes on button press in radio_microns.
function radio_microns_Callback(hObject, eventdata, handles)
    set(handles.radio_pixels, 'Value', 0);
    set(handles.radio_microns, 'Value', 1);

    plot_data(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_calib_um_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_calib_um_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;
	guidata(hObject, handles);
    
    plot_data(hObject, eventdata, handles);    

% --- Executes on button press in pushbutton_remove_drift.
function pushbutton_remove_drift_Callback(hObject, eventdata, handles)

    if ~isfield(handles, 'drift_t0')
        start_time = [];
    else
        start_time = handles.drift_t0;
    end
    
    if ~isfield(handles, 'drift_tend')
        end_time = [];
    else
        end_time = handles.drift_tend;
    end
    
    if get(handles.radio_linear, 'Value')
        logentry('Removing Drift via linear method.');
        [v,q] = remove_drift(handles.table, start_time, end_time, 'linear');
    elseif get(handles.radio_com, 'Value')
        logentry('Removing Drift via center-of-mass method.');
        [v,q] = remove_drift(handles.table, start_time, end_time, 'center-of-mass');
    elseif get(handles.radio_linearmean, 'Value')
        logentry('Removing Drift via linear mean method.');
        [v,q] = remove_drift(handles.table, start_time, end_time, 'linearMean');
    end
    
    handles.table = v;
    handles.recomputeMSD = 1;
	guidata(hObject, handles);

    plot_data(hObject, eventdata, handles);
        

% --- Executes on button press in checkbox_frame_rate.
function checkbox_frame_rate_Callback(hObject, eventdata, handles)

    video_tracking_constants;
    table = handles.table;
    
    if get(hObject, 'Value')      
        set(handles.edit_frame_rate, 'Enable', 'on');

        table(:,TIME) = table(:,FRAME) / str2double(get(handles.edit_frame_rate, 'String'));
        mintime = min(table(:,TIME));
        maxtime = max(table(:,TIME));
	
        handles.table = table;
        handles.maxtime = maxtime;
        handles.mintime = mintime;
    else
        set(handles.edit_frame_rate, 'Enable', 'off');

        handles.table(:,TIME) = handles.tstamp_times;
        handles.mintime = min(handles.table(:,TIME));
        handles.maxtime = max(handles.table(:,TIME));
    end

    handles.recomputeMSD = 1;
	guidata(hObject, handles);
    
    plot_data(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_frame_rate_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_frame_rate_Callback(hObject, eventdata, handles)
    video_tracking_constants;

    table = handles.table;

    if get(handles.checkbox_frame_rate, 'Value');
        table(:,TIME) = table(:,FRAME) / str2double(get(hObject, 'String'));
        mintime = min(table(:,TIME));
        maxtime = max(table(:,TIME));
	
        handles.table = table;
        handles.maxtime = maxtime;
        handles.mintime = mintime;
        handles.recomputeMSD = 1;
        guidata(hObject, handles);
	
        plot_data(hObject, eventdata, handles);
        drawnow;
    end

    
% --- Executes on button press in radio_relative.
function radio_relative_Callback(hObject, eventdata, handles)
    set(handles.radio_relative, 'Value', 1);
    set(handles.radio_arb_origin, 'Value', 0);
    
    plot_data(hObject, eventdata, handles);
    drawnow;

    
% --- Executes on button press in radio_arb_origin.
function radio_arb_origin_Callback(hObject, eventdata, handles)

    set(handles.radio_relative, 'Value', 0);
    set(handles.radio_arb_origin, 'Value', 1);

    arb_origin = str2num(get(handles.edit_arb_origin, 'String'));  %#ok<ST2NM>

    if length(arb_origin) ~= 2
        logentry('Origin value is not valid.  Not plotting.')
        set(handles.radio_arb_origin, 'Value', 0);
        set(handles.radio_relative, 'Value', 1);
    else
        plot_data(hObject, eventdata, handles);
    end


function edit_arb_origin_Callback(hObject, eventdata, handles)
    arb_origin = str2num(get(hObject, 'String'));

    if length(arb_origin) ~= 2
        logentry('Origin value is not valid.  Not plotting.')
        set(handles.radio_arb_origin, 'Value', 0);
    else
        plot_data(hObject, eventdata, handles);
    end
    

% --- Executes during object creation, after setting all properties.
function edit_arb_origin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_arb_origin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function radio_AUXoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radio_AUXoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popup_AUXplot.
function popup_AUXplot_Callback(hObject, eventdata, handles)
% hObject    handle to popup_AUXplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_AUXplot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_AUXplot
    contents = get(hObject, 'String');
    AUXtype = contents(get(hObject, 'Value'));
    
    handles.AUXtype = AUXtype{1};
    guidata(hObject, handles);

    switch handles.AUXtype
        case 'OFF'
            set(handles.radio_relative       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            
        case 'radial vector'
            set(handles.radio_relative    ,  'Visible', 'on', 'Enable', 'on');
            set(handles.radio_arb_origin  ,  'Visible', 'on', 'Enable', 'on');
            set(handles.edit_arb_origin   ,  'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');

        case 'PSD'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');                        
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
        case 'Integrated Disp'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');                        
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%         case 'displacement hist'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta      ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');            
        case 'MSD'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_msdall   ,  'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_G       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_numtaus         ,  'Visible', 'on', 'Enable', 'on');
            set(handles.edit_numtaus         ,  'Visible', 'on', 'Enable', 'on');
       case 'MSD histogram'
            set(handles.radio_relative       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
       case 'temporal MSD'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');            
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
       case 'GSER'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G       ,  'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_eta      ,  'Visible', 'on', 'Enable', 'on');
            set(handles.edit_bead_diameter_um,  'Visible', 'on', 'Enable', 'on');
            set(handles.text_bead_diameter,  'Visible', 'on', 'Enable', 'on');
            set(handles.text_numtaus         ,  'Visible', 'on', 'Enable', 'on');
            set(handles.edit_numtaus         ,  'Visible', 'on', 'Enable', 'on');
        case 'pole locator'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');            
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
        case 'tracker avail'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
    end
    
    plot_data(hObject, eventdata, handles);
    

% --- Executes during object creation, after setting all properties.
function popup_AUXplot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_AUXplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_msdmean.
function checkbox_msdmean_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);


% --- Executes on button press in checkbox_msdall.
function checkbox_msdall_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);

    
% --- Executes on button press in checkbox_eta.
function checkbox_eta_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);


% --- Executes on button press in checkbox_G.
function checkbox_G_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);


function edit_bead_diameter_um_Callback(hObject, eventdata, handles)


function edit_bead_diameter_um_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_bead_diameter_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% =========================================================================
% Everything below this point are functions related to computation and data
% handling/display, and not the gui (though the handles structure is used).
% =========================================================================

function plot_data(hObject, eventdata, handles)
    video_tracking_constants;

    if get(handles.radio_pixels, 'Value');
        calib_um = 1;
        ylabel_string = 'displacement [pixels]';
    elseif get(handles.radio_microns, 'Value');
        calib_um = str2double(get(handles.edit_calib_um, 'String')); 
        ylabel_string = 'displacement [\mum]';
    end
    
    im     = handles.im;
    beadID = handles.table(:,ID);
    frame  = handles.table(:,FRAME);
    x      = handles.table(:,X) * calib_um;
    y      = handles.table(:,Y) * calib_um;
    t      = handles.table(:,TIME);
    
    if size(im,1) > 1
        [imy imx imc] = size(im);
    else
        imy = max(y) * 1.1;
        imx = max(x) * 1.1;
    end;
    
    currentBead = round(get(handles.slider_BeadID, 'Value'));
    
    mintime = handles.mintime;
    
	k  = find(beadID == (currentBead));
	nk = find(beadID ~= (currentBead));

    figure(handles.XYfig);   
        imagesc(0:imx * calib_um, 0:imy * calib_um, im);
    colormap(gray);
    
    
    if get(handles.checkbox_overlayxy, 'Value')
        hold on;
            plot(x(nk), y(nk), '.', x(k), y(k), 'r.'); 
        hold off;
    end
    
    if isfield(handles, 'poleloc')
        polex = handles.poleloc(1);
        poley = handles.poleloc(2);
        circradius = 50;
        
        if get(handles.radio_microns, 'Value');
            polex = polex * calib_um;
            poley = poley * calib_um;
            circradius = circradius * calib_um;
        end
        
        hold on;
            plot(polex, poley, 'r+', 'MarkerSize', 36);
            circle(polex, poley, circradius, 'r');
        hold off;
    end
    
    xlabel(ylabel_string);
    ylabel(ylabel_string);    
    axis([0 imx 0 imy] .* calib_um);
    set(handles.XYfig, 'Units', 'Normalized');
    set(handles.XYfig, 'Position', [0.1 0.05 0.4 0.4]);
    set(handles.XYfig, 'DoubleBuffer', 'on');
    set(handles.XYfig, 'BackingStore', 'off');
    drawnow;
    
    figure(handles.XTfig);
    if get(handles.checkbox_neutoffsets, 'Value')
        plot(t(k) - mintime, [x(k)-x(k(1)) y(k)-y(k(1))], '.');        
    else
        plot(t(k) - mintime, [x(k) y(k)], '.');
    end
    xlabel('time [s]');
    ylabel(ylabel_string);
    legend('x', 'y');    
    set(handles.XTfig, 'Units', 'Normalized');
    set(handles.XTfig, 'Position', [0.51 0.05 0.4 0.4]);
    set(handles.XTfig, 'DoubleBuffer', 'on');
    set(handles.XTfig, 'BackingStore', 'off');    
    drawnow;
    
    arb_origin = str2num(get(handles.edit_arb_origin, 'String'));
    calib_um = str2double(get(handles.edit_calib_um, 'String'));     
    
    AUXfig = handles.AUXfig;         
    AUXtype = handles.AUXtype;
    
    if strcmp(AUXtype, 'MSD') || strcmp(AUXtype, 'GSER') || strcmp(AUXtype, 'MSD histogram')
        if handles.recomputeMSD % && get(handles.checkbox_msdmean, 'Value')
            data = handles.table;
            frame_rate = str2num(get(handles.edit_frame_rate, 'String'));
            calib_um   = str2num(get(handles.edit_calib_um, 'String'));
            bead_diameter_um = str2num(get(handles.edit_bead_diameter_um, 'String'));
            numtaus = round(str2num(get(handles.edit_numtaus, 'String')));
            win = unique(floor(logspace(0,log10(max(frame)),numtaus)));
%             win = unique(floor(logspace(0,5,50)));
            mymsd = video_msd(data, win, frame_rate, calib_um, 'n');            
            myve = ve(mymsd, bead_diameter_um*1e-6/2, 'f', 'n', 1);
            
            handles.mymsd = mymsd;
            handles.myve  = myve;
            handles.recomputeMSD = 0;
            guidata(hObject, handles);
        end

        msdID   = unique(handles.table(:,ID))';    
        mymsd   = handles.mymsd;
        myve    = handles.myve;
        tau = mymsd.tau;
        msd = mymsd.msd;
        
        q  = find(msdID  == currentBead);
    end
    
    switch AUXtype
        case 'OFF'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'off');

            
        case 'radial vector'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');

            if get(handles.radio_relative, 'Value')
                xinit = x(k); xinit = xinit(1);
                yinit = y(k); yinit = yinit(1);        
            elseif get(handles.radio_arb_origin, 'Value')            
                xinit = arb_origin(1);
                yinit = arb_origin(2);

                % handle the case where 'microns' are selected
                if get(handles.radio_microns, 'Value');
                    xinit = xinit * calib_um;
                    yinit = yinit * calib_um;                
                end                        
            end

            r = magnitude(x(k) - xinit, y(k) - yinit);

            plot(t(k) - mintime, r, '.');
            xlabel('time (s)');
            ylabel(['radial ' ylabel_string]);
            set(handles.AUXfig, 'Units', 'Normalized');
            set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
            set(handles.AUXfig, 'DoubleBuffer', 'on');
            set(handles.AUXfig, 'BackingStore', 'off');    
            drawnow;
        case 'PSD'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            clf(AUXfig);
            
            [p, f, id] = mypsd([x(k)*1e-6 y(k)*1e-6], 120, 1, 'rectangle');

            loglog(f, p);
            xlabel('frequency [Hz]');
			ylabel('power [m^2/Hz]');

            
            set(handles.AUXfig, 'Units', 'Normalized');
            set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
            set(handles.AUXfig, 'DoubleBuffer', 'on');
            set(handles.AUXfig, 'BackingStore', 'off');    
        case 'Integrated Disp'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            clf(AUXfig);
            
            [p, f, id] = mypsd([x(k) y(k)], 120, 0.01, 'blackman');

            loglog(f, id);            
%         case 'displacement hist'
%             figure(handles.AUXfig);
%             set(AUXfig, 'Visible', 'on');
%             clf(AUXfig);
%             
%             [tau, bins, dist] = diffdist(t(k), [x(k) y(k)], []);
%             plot(dist(1,:,1), bins(1,:,1), '.');
            
        case 'MSD'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');

            plot_all = get(handles.checkbox_msdall, 'Value');
            plot_mean = get(handles.checkbox_msdmean, 'Value');            
            
            if plot_all && plot_mean
                plot_msd(mymsd, AUXfig, 'ame');
                
                figure(AUXfig);
                hold on;
                    plot(log10(tau(:,q)), log10(msd(:,q)), 'r.-');
                hold off;
            elseif plot_all
                plot_msd(mymsd, AUXfig, 'a');
                
                figure(AUXfig);
                hold on;
                    plot(log10(tau(:,q)), log10(msd(:,q)), 'r.-');
                    [rows,cols] = size(tau);
                    legend({num2str([0:cols-1]')});
                    legend off
                hold off;
            elseif plot_mean
                plot_msd(mymsd, AUXfig, 'me');                
            end
            
            grid on;
        case 'MSD histogram'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');

            numbins = 51;
            
            v = msdhist(mymsd, numbins);
            plot_msdhist(v, AUXfig, 's');
                       
        case 'temporal MSD'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            
            [tau, m, time] = msdt(t(k), [x(k) y(k)], [], []);
            
            surf(m);
            
        case 'GSER'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');

            plotG   = get(handles.checkbox_G, 'Value');
            ploteta = get(handles.checkbox_eta, 'Value');

            if (plotG && ploteta)
                plot_ve(myve, 'f', AUXfig, 'GgNn');
            elseif plotG
                plot_ve(myve, 'f', AUXfig, 'Gg');
            elseif ploteta
                plot_ve(myve, 'f', AUXfig, 'Nn');
            end
            
        case 'pole locator'
            set(AUXfig, 'Visible', 'on');

            handles.poleloc = pole_locator(handles.table, handles.im, 'y', AUXfig);
            guidata(hObject, handles);

            poleloctxt = [num2str(handles.poleloc(1)) ', ' num2str(handles.poleloc(2))]
            set(handles.edit_arb_origin, 'String', poleloctxt);
            
        case 'tracker avail'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');

            plot(frame, beadID, '.');
            xlabel('frame number');
            ylabel('Tracker ID');
            set(handles.AUXfig, 'Units', 'Normalized');
            set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
            set(handles.AUXfig, 'DoubleBuffer', 'on');
            set(handles.AUXfig, 'BackingStore', 'off');    
            drawnow;
    end
       
    refresh(handles.XYfig);
    refresh(handles.XTfig);
    refresh(handles.AUXfig);
    
    

    
function delete_selected_dataset(hObject, eventdata, handles)

global hand
    video_tracking_constants;
    
    table = handles.table;

    bead_to_remove = round(get(handles.slider_BeadID, 'Value'));
    
    bead_max = max(table(:,ID));

	k = find(table(:,ID) ~= bead_to_remove);
    
    table = table(k,:);
    
    if (bead_max ~= bead_to_remove) % otherwise I don't have to rearrange beadIDs
        for m = (bead_to_remove + 1) : bead_max
            k = find(table(:,ID) == m);
            table(k,ID) = m-1;
        end
    end
    
    if (bead_to_remove == 0)
        set(handles.slider_BeadID, 'Value', bead_to_remove+1);
        set(handles.edit_BeadID, 'String', num2str(bead_to_remove+1));
    else
    	set(handles.slider_BeadID, 'Value', bead_to_remove-1);
        set(handles.edit_BeadID, 'String', num2str(bead_to_remove-1));        
    end
    
    if bead_max ~= 1
        set(handles.slider_BeadID, 'Max', bead_max-1);
        set(handles.slider_BeadID, 'SliderStep', [1/(bead_max-1) 1/(bead_max-1)]);
    else
        set(handles.slider_BeadID, 'Max', bead_max);
        set(handles.slider_BeadID, 'SliderStep', [1/(bead_max) 1/(bead_max)]);
    end
    
    handles.table = table;
	guidata(hObject, handles);

    hand = handles;
    
function delete_inside_boundingbox(hObject, eventdata, handles)
    global hand;
    
    video_tracking_constants;

    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XYfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    else
        logentry('Deleting data from the AUXplot is not allowed.');
        return;
    end
    
    figure(active_fig);
    
    table = handles.table;
    
    beadID = table(:,ID);
    t = table(:,TIME) - handles.mintime;
    x = table(:,X);
    y = table(:,Y);
    currentbead = get(handles.slider_BeadID, 'Value');
    
    [xm, ym] = ginput(2);
    
    if get(handles.radio_microns, 'Value')
        calib_um = str2double(get(handles.edit_calib_um, 'String'));
        
        if(get(handles.radio_XYfig, 'Value'))
            xm = xm / calib_um;
            ym = ym / calib_um;
        elseif(get(handles.radio_XTfig, 'Value'))
            ym = ym / calib_um;
        end
        
    end
    
    xlo = min(xm);
    xhi = max(xm);
    ylo = min(ym);
    yhi = max(ym);
    
    if get(handles.radio_XYfig, 'Value')
        k = find(~(x > xlo & x < xhi & y > ylo & y < yhi & beadID == currentbead));
    elseif get(handles.radio_XTfig, 'Value')
        k = find(~( ( (x > ylo & x < yhi) | (y > ylo & y < yhi) ) & ...
                      (t > xlo & t < xhi) & (beadID == currentbead)));
    elseif get(handles.radio_AUXfig, 'Value')
        logentry('Deleting data from AUX plot is not allowed.');
    end
    handles.table = table(k,:);
    handles.tstamp_times = handles.tstamp_times(k);
    guidata(hObject, handles);

    hand = handles;

    
function delete_data_before_time(hObject, eventdata, handles) 

    global hand;
    
    video_tracking_constants;

    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_AUXfig, 'Value'))
        active_fig = handles.XTfig;
    end

    figure(active_fig);

    table = handles.table;
    % beadID = table(:,ID);

    t = table(:,TIME) - handles.mintime;
    x = table(:,X);
    y = table(:,Y);
    
    [tm, xm] = ginput(1);
    
    % find the closest time point to mouse click
    dists = abs(t - tm);    
    
    % identify time
    idx = find(dists == min(dists));
    closest_time = mean(t(idx));
    
    % remove any points in the table that have times eariler than our
    % prescribed beginning time point
    idx = find(table(:,TIME) > (closest_time + handles.mintime));
    table = table(idx,:);
    
    handles.table = table;
    handles.mintime = min(table(:,TIME));
    guidata(hObject, handles);

    hand = handles;
   
    
function delete_data_after_time(hObject, eventdata, handles)
    global hand;

    video_tracking_constants;

    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_AUXfig, 'Value'))
        active_fig = handles.XTfig;
    end

    figure(active_fig);

    table = handles.table;

    t = table(:,TIME) - handles.mintime;
    
    [tm, xm] = ginput(1);
    
    % find the closest time point to mouse click
    dists = abs(t - tm);    
    
    % identify index value that corresponds to this time
    idx = find(dists == min(dists));
    closest_time = t(idx);

    % remove any points in the table that are greater than the time value
    % selected by the mouse-click.
    idx = find(t <= closest_time(1));
    table = table(idx,:);
    
    handles.table = table;
    guidata(hObject, handles);

    hand = handles;

% function set_active_figure(hObject, eventdata, handles);

function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'evt_gui: '];
     
     fprintf('%s%s\n', headertext, txt);

   
% function [tau, mymsd, beadID] = evt_msd(data, window, calib_um)
% 
%     video_tracking_constants;
% 
%     % for every bead
%     beadID = unique(data(:,ID))';
%     for bead_idx = beadID;
% 
%         b = get_bead(data, bead_idx);    
%         % framemax = max(data(:,FRAME));
% 
%         % call up the MSD program to compute the MSD for each bead
%         [tau(:, bead_idx+1), mymsd(:, bead_idx+1)] = msd(b(:, TIME), b(:, X:Z)*calib_um*1e-6, window);
%         
%     end
%     
% return;


% --- Executes on button press in checkbox_minFrames.
function checkbox_minFrames_Callback(hObject, eventdata, handles)


function edit_minFrames_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_minFrames_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in checkbox_minPixelRange.
function checkbox_minPixelRange_Callback(hObject, eventdata, handles)


function edit_minPixelRange_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_minPixelRange_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in checkbox_tCrop.
function checkbox_tCrop_Callback(hObject, eventdata, handles)


function edit_tCrop_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_tCrop_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in checkbox_xyCrop.
function checkbox_xyCrop_Callback(hObject, eventdata, handles)


function edit_xyCrop_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_xyCrop_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in checkbox_neutoffsets.
function checkbox_neutoffsets_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);


% --- Executes on button press in checkbox_overlayxy.
function checkbox_overlayxy_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);


% --- Executes on button press in checkbox_LumiCrop.
function checkbox_LumiCrop_Callback(hObject, eventdata, handles)


function edit_LumiCrop_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_LumiCrop_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_numtaus_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;    
    plot_data(hObject, eventdata, handles);    
    guidata(hObject, handles);
    
    
% --- Executes during object creation, after setting all properties.
function edit_numtaus_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
