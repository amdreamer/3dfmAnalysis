function varargout = lt_analysis_gui(varargin)
% LT_ANALYSIS_GUI M-file for lt_analysis_gui.fig
%      LT_ANALYSIS_GUI, by itself, creates a new LT_ANALYSIS_GUI or raises the existing
%      singleton*.
%
%      H = LT_ANALYSIS_GUI returns the handle to a new LT_ANALYSIS_GUI or the handle to
%      the existing singleton*.
%
%      LT_ANALYSIS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LT_ANALYSIS_GUI.M with the given input arguments.
%
%      LT_ANALYSIS_GUI('Property','Value',...) creates a new LT_ANALYSIS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lt_analysis_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lt_analysis_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lt_analysis_gui

% Last Modified by GUIDE v2.5 23-Dec-2005 17:24:00
% % NOTES FOR PROGRAMMER: 
%  - add/load button adds new files into the database. Doesn't replace any files. 
%    if the requested file exists in the database already, then it skips loading that file and  warns user.
%  - Any file that is loaded in the database, is displayed with full name + tag in the file selection menu;
%  and only tag in the tag list. 
%  - Removing a file from the database removes it from the taglist and from the selection menu.
     
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lt_analysis_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @lt_analysis_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before lt_analysis_gui is made visible.
function lt_analysis_gui_OpeningFcn(hObject, eventdata, handles, varargin)
global g
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lt_analysis_gui (see VARARGIN)

% Choose default command line output for lt_analysis_gui
handles.output = hObject;

% a list of fields in the global dataset, useful to access each field by
% index rather than by absolute name.
handles.gfields = {'data','magdata','fname','path','tag','metadata','drift'};
% NOTE: if change any of the strings above, also change the field name of
% g in the whole file, and vice versa.

handles.default_path = pwd;
set(handles.button_add,'UserData',handles.default_path); 

% Names of signals in the structure given by load_laser_tracking
% If we want to add a signal later, just change all the fields below (e.g
% siganmes.intr, signmaes.disp, posid, and all figids accordingly. Rest of
% the program *should* still work unchanged.
handles.signames.intr = {'beadpos' ,'stageReport','qpd','laser'};
% Names of signals to be displayed on GUI control menu_signal
handles.signames.disp = {'Bead Pos','Stage Pos'  ,'QPD','Channel 8'};
handles.posid = [1, 2]; %index of the signals which are position measurements
% Figure numbers allocated to 'main-figures' for various signals
handles.mainfigids =      [   1,          2,          3,         4];
handles.psdfigids =       [  10,         20,         30,        40];
handles.dvsffigids =  handles.psdfigids + 5;      % accumulated displacement 
%  ....add to this list as more types of plots are supported

% Below are some figids pertinent to only specific signal types
handles.frespfigids =     [ 60]; % Frequency response plot is pertinent to beadpos only.
                      % R = 60, X = 61, Y = 62, Z = 63  
% Some other figure numbers allocated to specific types of plot
handles.threeDfig = 9;
handles.boxresfig = 100;
%  ....add to this list as more types of plots are supported

% Some other constants
handles.srate = 10000;
handles.psdwin = 'blackman';
handles.emptyflag_str = 'Database is empty';

% initialize the global structure
for c = 1:length(handles.gfields)
    g.(handles.gfields{c}) = {};
end

guidata(hObject, handles);
% UIWAIT makes lt_analysis_gui wait for user response (see UIRESUME)
% uiwait(handles.GUI);


% --- Outputs from this function are returned to the command line.
function varargout = lt_analysis_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%% $$$$$$$$$$$$$$$$$$$       CALLBACKS     $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% --- Executes on button press in button_add.
function button_add_Callback(hObject, eventdata, handles)
global g % using global (as oppose to 'UserData') prevents creating multiple copies
switch get(handles.menu_exper,'value')
    case 1 %Passive Diffusion   
        fieldstr = 'b';
    case 2 %Pulling + Diffusion
        fieldstr = 'lb';
    case 3 %Discrete Freqeuncy Sweep
        fieldstr = 'lb';        
    case 4 %Noise (QPD+laser)
        fieldstr = 'lq';
    case 5 %Noise (Stage only)
        fieldstr = 's';
    case 6 % All fields
        fieldstr = 'a';
    otherwise
        prompt_user('Error: Unrecognized experiment type');
end
% A cheap hacky fix to the bug where GUI sometimes forgets the last path
if (get(hObject,'UserData') == 0),  set(hObject,'UserData',handles.default_path); end    

[f, p] = uigetfiles('*.mat','Browse and select one or more files',get(hObject,'UserData'));

set(hObject,'UserData',p); %memorize the last browsing path
prompt_user('Wait...Loading selected files',handles);
flags.keepuct = 0; flags.keepoffset = 0; flags.askforinput = 0;flags.inmicrons = 1;
flags.matoutput = 1; %request output fields in the [time vals] matrix form.
nloaded = 0;
for(c = 1:length(f))
    pack
    if exist('g') & ~isempty(g.data) & any(strcmp(g.fname,f{c}) == 1)
        prompt_user(['The file ',f{c},' is already in the database.']);                
    else
        prompt_user(['...currently loading ','[',num2str(c),'of',num2str(length(f)),'] :',f{c}],handles);
        
        %put newly added dataset on the top of the list
        %shift all existing datasets down by one
        if (exist('g') & ~isempty(g.data))
            for cf = 1:length(handles.gfields) 
                g.(handles.gfields{cf}) = [ {0}, g.(handles.gfields{cf})];
            end
        end
        %Make the cell arrays in the form of 1xN, and keep that form as the
        %standard. Nx1 standardization would work as well, but it seems my matlab
        %is creating arrays in the form of 1xN by default.
        try
            % load only those fields which are pertinent to the selected experiment type
            g.data{1,1} = load_laser_tracking(fullfile(p,f{c}),fieldstr,flags);
            % fullfile usage is handy and protects code against platform variations
            g.magdata{1,1} = {}; %start out with empty magnet data
            g.fname{1,1} = f{c}; %file name
            g.path{1,1} = p; %file path
            % Now add the default tag
            NoTagInd = get(handles.button_tag,'UserData');
            if(isempty(NoTagInd) | NoTagInd < 1), NoTagInd = 1; end
            g.tag{1,1} = ['NoTag',num2str(NoTagInd)]; %tag
            set(handles.button_tag,'UserData',NoTagInd+1);
            g.metadata{1,1} = 'NoMetaData'; %user specified metadata                
            for k = 1:length(handles.signames.intr)
                if isfield(g.data{1},handles.signames.intr{k})
                    % calculate # of columns in the current signal
                    M = size(g.data{1}.(handles.signames.intr{k}),2);                    
                    % enter zero as the place-holder in the drift fields to start with.
                    % do not allocate space for drift for the first column which is time
                    g.drift{1,1}.(handles.signames.intr{k}) = zeros(2,M-1);
                        % First Row = Slope, Second Row = Offset
                end
            end            
            prompt_user([f{c}, ' added to the database.'],handles);
            nloaded = nloaded + 1; %total files loaded
        catch
            prompt_user(lasterr);
            prompt_user([f{c}, ' could not be added to the database.'],handles);
            % shift back every field up by one
            if(exist('g') & ~isempty(g.data))
                for cf = 1:length(handles.gfields)                    
                    g.(handles.gfields{cf}) = g.(handles.gfields{cf})(2:end); 
                end                 
            end
            break;
        end
    end
end
% set(hObject,'UserData', g); %use global instead
updatemenu(handles);
prompt_user(['Finished Loading. Loaded ',num2str(nloaded),' files']);

% --- Executes on button press in button_remove
function button_remove_Callback(hObject, eventdata, handles)
global g
[selec,ok] = listdlg('ListString',get(handles.menu_files,'String'),...
                    'OKstring','Remove',...
                    'Name','Select file(s) to be removed');
for c=1:length(selec)
    for cf = 1:length(handles.gfields) %delete all fields for that file id
        g.(handles.gfields{cf}){1,selec(c)} = {};
    end
end
% keyboard
% Now remove the empty cells from each field
for cf = 1:length(handles.gfields) 
    ifilled = ~cellfun('isempty',g.(handles.gfields{cf}));
    g.(handles.gfields{cf}) = g.(handles.gfields{cf})(ifilled); 
end
% updatetaglist(handles);
updatemenu(handles);
prompt_user([num2str(length(selec)),' files were removed from the database.'],handles);

% --- Executes on selection change in menu_files.
function menu_files_Callback(hObject, eventdata, handles)
global g
% Hints: contents = get(hObject,'String') returns menu_files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_files
updatesignalmenu(handles);% this will also refresh the main figure

% --- Executes on button press in button_tag.
function button_tag_Callback(hObject, eventdata, handles)
global g
% Note: Multiple tags of same string are not acceptable.
fileid = get(handles.menu_files,'Value');
contents = get(handles.menu_files,'string');
prompt = {'Short tag (e.g. to be used as a legend entry in a plot) for this file',...
        'Metadata to be associated with this file'};
dlg_title = ['Edit metadata:',contents{fileid}];
num_lines= [1;2];
while 1    
    userinput = inputdlg(prompt,dlg_title,num_lines,...
        {g.tag{1,fileid}, g.metadata{1,fileid}});  
    sameid = find(strcmp(g.tag,userinput{1}) == 1);
    if sameid == fileid | isempty(sameid) % if there is no another tag of same string
        break;        
    else
        errordlg('A tag with the same string already exists. Please change the tag.','Error');
    end
end
g.tag{1,fileid} = userinput{1};
g.metadata{1,fileid} = userinput{2};
updatefilemenu(handles); % do not replot the main figure, just change menu entries.

% --- Executes on button press in button_cut.
function button_cut_Callback(hObject, eventdata, handles)
global g
dbstop if error
if ~exist('g') | isempty(g.data)
    errordlg('Database is empty, first add files to it','Error');
    return;
end
% check if the main figure is plotted and in focus
if (0 == figflag(getmainfigname(handles)))
   updatemainfig(handles,'new'); 
end
% hmf = get(handles.radio_drawbox,'UserData')
% hma = findobj(hmf,'Type','Axes','Tag','');
% set the buttonDownFcn to DoNothing.
manageboxradiogroup(handles,3,1);

% [t(1),y] = ginput(1);
% drawlines(hma,t(1));
% [t(2),y] = ginput(1);
% drawlines(hma,t(2));
[t,y] = ginput(2);

t = sort(t);
% Cut all the fields existing in the current file
id = get(handles.menu_files,'Value');
for c = 1:length(handles.signames.intr)
    cursig = handles.signames.intr{c};
    if (isfield(g.data{1,id}, cursig))
        sigold = g.data{1,id}.(cursig);        
%         find indices outside the selected box
        linds = sort(find(sigold(:,1) < t(1))); %indices before box
        uinds = sort(find(sigold(:,1) > t(2))); %indices after box
        %adjust the data after box such that there is no step visible after
        %cutting the box
        steps = sigold(uinds(1),:) - sigold(linds(end)+1,:);
        sigold(uinds,:) = sigold(uinds,:) - repmat(steps,size(uinds,1),1);
        g.data{1,id}.(cursig) = [];
        g.data{1,id}.(cursig) = sigold(union(linds, uinds),:);
        clear sigold;
    end
end
updatemainfig(handles,'cut');
dbclear if error
%-------------------------------------------------------------------------
% --- Executes on button press in button_selectdrift.
% This function lets user select a box that is to be considered as
% 'drift calculation section'. Then the routine calcualtes drift
% over the selected section for the currently selected signal and
% updates the drift parameters in the global master database.
function button_selectdrift_Callback(hObject, eventdata, handles)
global g
if ~exist('g') | isempty(g.data)
    errordlg('Database is empty, first add files to it','Error');
    return;
end
% check if the main figure is plotted and in focus
if (0 == figflag(getmainfigname(handles)))
   updatemainfig(handles,'new'); 
end
% set the buttonDownFcn to DoNothing.
manageboxradiogroup(handles,3,1);
% hmf = get(handles.radio_drawbox,'UserData')
% hma = findobj(hmf,'Type','Axes','Tag','');
[t,y] = ginput(2);

t = sort(t);
% calculate drift for currently selected signal
sigid = get(handles.menu_signal,'UserData');
signame = handles.signames.intr{sigid};
fileid = get(handles.menu_files,'Value');
sig = g.data{fileid}.(signame);
M = size(sig,2);
[selec(:,1),selec(:,2:M)] = clipper(sig(:,1),sig(:,2:M),t(1),t(2));
for c = 2:M
    fit = polyfit(selec(:,1),selec(:,c),1);
    % First Row = Slope, 2nd Row = offset;
    g.drift{fileid}.(signame)(:,c-1) = fit;
end

%-------------------------------------------------------------------------
% --- Executes on button press in check_subdrift.
function check_subdrift_Callback(hObject, eventdata, handles)
updatemainfig(handles);

%-------------------------------------------------------------------------
% --- Executes on button press in check_psd.
function check_psd_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
    set(handles.check_cumdisp,'Value',0);
end
%-------------------------------------------------------------------------
% --- Executes on button press in check_cumdisp.
function check_cumdisp_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.check_psd,'Value',1);
end
%-------------------------------------------------------------------------
% --- Executes on button press in radio_drawbox.
function radio_drawbox_Callback(hObject, eventdata, handles)
manageboxradiogroup(handles,1,get(hObject,'value'));
%-------------------------------------------------------------------------
% --- Executes on button press in radio_dragbox.
function radio_dragbox_Callback(hObject, eventdata, handles)
manageboxradiogroup(handles,2,get(hObject,'value'));
%-------------------------------------------------------------------------
% --- Executes on button press in radio_nothing.
function radio_nothing_Callback(hObject, eventdata, handles)
manageboxradiogroup(handles,3,get(hObject,'value'));

%-----------------------------------------------------------------------
function manageboxradiogroup(handles,radind,radstat)
hmf = get(handles.radio_drawbox,'UserData');
if isempty(hmf) | hmf == 0
    sigid = get(handles.menu_signal,'UserData');
    hmf = handles.mainfigids(sigid);
    set(handles.radio_drawbox,'UserData',hmf);
end
hma = findobj(hmf,'Type','Axes','Tag','');
% some constants
hrad(1) = handles.radio_drawbox;
hrad(2) = handles.radio_dragbox;
hrad(3) = handles.radio_nothing;

for c = 1:3 % reset all radios first
    set(hrad(c),'Value',0);
end
if radstat == 0
    set(hrad(3), 'Value', 1);
    set(hma,'ButtonDownFcn',{@DoNothingFcn,handles});
else
    switch radind
        case 1
            if (0 == figflag(getmainfigname(handles)))
                updatemainfig(handles,'new');
            end    
            set(hrad(1), 'Value', 1);
            set(hma,'ButtonDownFcn',{@DrawNewBoxFcn,handles});
        case 2
            if (0 == figflag(getmainfigname(handles)))
                    updatemainfig(handles,'new');
            end
            if isempty(findobj(hma,'Tag','Box'))
                errordlg('First draw a box to enable this mode.','Error');                
                set(hrad(1), 'Value', 1);
                set(hma,'ButtonDownFcn',{@DrawNewBoxFcn,handles});
                return
            else                
                set(hrad(2), 'Value', 1);
                set(hma,'ButtonDownFcn',{@DragBoxFcn,handles});
            end
        case 3
            set(hrad(3), 'Value', 1);
            set(hma,'ButtonDownFcn',{@DoNothingFcn,handles});
        otherwise
            prompt_user('Unrecognized radio index');
    end
end
%-------------------------------------------------------------------------
function DrawNewBoxFcn(hcaller,eventdata,handles)
% ----Executes when mouse is pressed inside the main axes and the box radio 
% is set to 'Draw New Box'
hmf = get(handles.radio_drawbox,'UserData');
% find the handle of the axes of the main figure
hma = findobj(hmf,'Type','axes','Tag','');%legend is the other axes with tag 'legend'

% delete the old box 
delete(findobj(hma,'Tag','Box'));

point1 = get(hma,'CurrentPoint');    % button down detected
b.figbox = rbbox;                      % return figure units
point2 = get(hma,'CurrentPoint');    % button up detected

point1 = point1(1);              % extract x 
point2 = point2(1);
x1 = min(point1,point2);             % calculate locations
width = abs(point1-point2);         % and dimensions
ylims = get(hma,'Ylim');
b.xlims = [x1, x1+width];
b.dbox = [x1, ylims(1), width, ylims(2)-ylims(1)];

updatebox(handles,hma,0,b);
%-------------------------------------------------------------------------
% ----Executes when mouse is pressed inside the main axes and the box mode
% is set to 'Drag Box'
function DragBoxFcn(hcaller,eventdata,handles)
hmf = get(handles.radio_drawbox,'UserData');
% find the handle of the axes of the main figure
hma = findobj(hmf,'Type','axes','Tag','');%legend is the other axes with tag 'legend'
hbox = findobj(hma,'Tag','Box');
b = get(hbox,'UserData'); %b must not be empty, if everything is working.
    
point1 = get(hma,'CurrentPoint');    % button down detected
b.figbox = dragrect(b.figbox);              % return figure units
point2 = get(hma,'CurrentPoint');    % button up detected
point1 = point1(1);              % extract x 
point2 = point2(1);       
displace = point2-point1;
updatebox(handles,hma,displace,b);

%-------------------------------------------------------------------------
% ----Executes when mouse is pressed inside the main axes and the box mode
% is set to 'Do Nothing'
function DoNothingFcn(hcaller,eventdata,handles)
return
%------------------------
%---This routine updates the existing box or draws a new box.
function updatebox(handles,hma,displace,b);
hbox = findobj(hma,'Tag','Box');
% look for the box-parameters in the UserData of the box itself, ONLY IF
% box-parameters are not supplied exlicitely
if (nargin < 4 | isempty(b)) 
    if isempty(hbox)
        b = [];
    else
        b = get(hbox,'UserData');
    end
end
if isempty(b) 
    prompt_user('Error in updatebox. Box params can not be found');
    return;
end
if (nargin < 3 | isempty(displace))
    displace = 0;
end
delete(hbox); %delete old box
ylims = get(hma,'Ylim');
b.dbox(1) = b.dbox(1) + displace;
b.dbox([2,4]) = [ylims(1) ,ylims(2) - ylims(1)];
b.xlims = [b.dbox(1), b.dbox(1) + b.dbox(3)];
hold on;
hbox = rectangle('Position',b.dbox);
set(hbox,'EdgeColor','r','Tag','Box','Linewidth',2,'LineStyle','-.');
hold off;
set(hbox,'UserData',b);
updateboxresults(handles,hbox);

if isequal(lower(get(handles.check_3d,'Enable')),'on') & (get(handles.check_3d,'Value') == 1)
    plot3dfigure(handles);
end

% --- Executes on selection change in menu_dispres.
function menu_dispres_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
if isequal(val,get(hObject,'UserData'))
    return; % do nothing, if this was an accidental click selecting same things
end
set(hObject,'UserData',val);%remember the last selection
updatemainfig(handles,'dispres');


% --- Executes on selection change in menu_signal.
function menu_signal_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
strs = get(hObject,'String');
TF = strcmp(handles.signames.disp,strs{val});
sigid = find(TF == 1);
if isequal(sigid,get(hObject,'UserData'))
    return; % do nothing, if this was an accidental click selecting same things
end
set(hObject,'UserData',sigid);%remember the last selection
checkdimsvalidity(handles);
updatemainfig(handles,'quant');

% --- Executes on selection change in list_dims.
function list_dims_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
if isequal(val,get(hObject,'UserData'))
    return; % do nothing, if this was an accidental click selecting same things
end
set(hObject,'UserData',val);%remember the last selection
updatemainfig(handles,'dims');

% --- Executes on button press in button_addfsinfo.
function button_addfsinfo_Callback(hObject, eventdata, handles)

% --- Executes on button press in check_fdbox.
function check_fdbox_Callback(hObject, eventdata, handles)
if get(hObject,'value')
    set(handles.button_many,'Enable','off');
%     set(handles.button_plot,'UserData',[]);
else
    set(handles.button_many,'Enable','On');
end
% --- Executes on button press in button_many.
function button_many_Callback(hObject, eventdata, handles)
% can not consider box if selecting multiple files
set(handles.check_fdbox,'value',0); 
[selec,ok] = listdlg('ListString',get(handles.menu_files,'String'),...
                    'InitialValue',get(handles.menu_files,'value'),...
                    'OKstring','Select',...
                    'Name','Select file(s) to be analyzed');
if ok
    set(handles.button_plot,'UserData',selec);
end
%-----------------------------------------------------------------------
% --- Executes on button press in button_plot.
function button_plot_Callback(hObject, eventdata, handles)
global g
dbstop if error
sigid = get(handles.menu_signal,'UserData');
signame = handles.signames.intr{sigid};
if strcmp(get(handles.list_dims,'Enable'),'On')
    % R X Y Z enabled?
    cols = get(handles.list_dims,'value');
    strs = get(handles.list_dims,'String');
else %non-positional sigal, so process for all columns
    cols = 1:size(g.data.(signame),2);
    for k = 1:cols, strs{k} = num2str(k); end
end
colrs = 'brkgym';
xlims = [-Inf, Inf];
% determine the ids of the files  to be plotted
if get(handles.check_fdbox,'value')
    ids = get(handles.menu_files,'Value');% only 1 file
    hmf = handles.mainfigids(sigid);
    hma = findobj(hmf,'Type','Axes','Tag','');
    hbox = findobj(hma,'Tag','Box');
    if ~isempty(hbox)
        get(hbox,'UserData');
        xlims = ans.xlims;
    end
else
    ids = get(handles.button_plot,'UserData');
    if isempty(ids)
        ids = get(handles.menu_files,'value');
    end
end
%%=========== COMPUTE AND PLOT PSD + CUMULATIVE DISTANCE ===============
if get(handles.check_psd,'Value')
    % set up figures for all columns of the signal
    for c = 1:length(cols)
        % setup psd figure
        figure(handles.psdfigids(sigid) + cols(c) - 1); clf;
        title([handles.signames.disp{sigid}, '-PSD: ',strs{cols(c)}]);
        if any(sigid == handles.posid) % if this signal is a position measurement
            ylabel('Micron^2/Hz');
        else 
            ylabel('Volts^2/Hz');
        end
        hold on;
        % setup 'area under psd' figure if we should
        if get(handles.check_cumdisp,'value')
            figure(handles.dvsffigids(sigid) + cols(c) - 1); clf;
            if any(sigid == handles.posid) % if this signal is a position measurement
                title([handles.signames.disp{sigid}, '-Cumulative Displacement: ',strs{cols(c)}]);
                ylabel('Micron^2/Hz');
            else 
                title([handles.signames.disp{sigid}, '- sqrt[Area under PSD]: ',strs{cols(c)}]);
                ylabel('Volts^2/Hz');
            end                
            ylabel('Micron');
            hold on;
        end            
    end
    % process + plot each file one by one
    for fi = 1:length(ids) %repeat for all files selected
        % grab the signal to be processed;
        sig = g.data{ids(fi)}.(signame);
        % First check if we are told to consider inside the Box only
        if get(handles.check_fdbox,'value')
            if (fi > 1)
                disp('Error: Was told to consider only ''inside box'' data, but multiple files were selected');
                disp('Will ignore the box and process all files');
                set(handles.check_fdbox,'value',0);
            else
                oldsig = sig; sig = [];
                [sig(:,1), sig(:,2:end)] = clipper(oldsig(:,1), oldsig(:,2:end),xlims(1),xlims(2));
                clear oldsig;
            end
        end        
        % now check if the timestamps are evenly spaced and adjust sampling rate accordingly        
        srate = handles.srate; %reset sample rate if changed by previous file
        if (range(diff(sig(:,1))) > 1e-6)            
            fnames = get(handles.menu_files,'String');            
            prompt_user(['UnEven TimeStamps: ',fnames{ids(f)}]);
            srate = srate*0.1;
            prompt_user(['This file will be resampled at ',num2str(srate),' Hz']);            
            oldsig = sig;
            sig = [];
            sig(:,1) = [oldsig(1,1):1/srate:oldsig(end,1)]';
            for k = 2:size(sig,2);
                sig(:,k) = interp1(oldsig(:,1),oldsig(:,k),sig(:,1));
            end
            clear oldsig
        end        
        % Are we told to plot psd of R? then we need to calculate it. Note, this is the only
        % reason why we assign 'cols' differently when the signal is a position than when it is not.
        if any(cols == 1) & any(sigid == handles.posid)% need to calculate R?
            sig(:,3:5) = sig(:,2:4);
            sig(:,2) = sqrt(sig(:,3).^2 + sig(:,4).^2 + sig(:,5).^2);
        end
        % now remove the offset from original signal before computing psd
        sig(:,2:end) = sig(:,2:end) - repmat(mean(sig(:,2:end),1),size(sig,1),1);
        
        % set the psd-resolution such that we have about 10 cycles of the lowest frequency.
        psdres = 10/range(sig(:,1));        
        % Now, ready to compute psd and, if we are told to, area under psd
        for c = 1:length(cols)
            [p f] = mypsd(sig(:,cols(c)),srate,psdres,handles.psdwin);
            figure(handles.psdfigids(sigid) + cols(c) -1);
            loglog(f,p,['.-',colrs(mod(f-1,length(colrs))+1)]);                        
            if get(handles.check_cumdisp,'value')
                dc = sqrt(cumsum(p)*mean(diff(f)));% sqrt of area under psd
                figure(handles.dvsffigids(sigid) + cols(c)-1);
                semilogx(f,dc,['.-',colrs(mod(f-1,length(colrs))+1)]);
            end
            if (fi == length(ids))% if this is last file
                alltags = g.tag{:};
                
                figure(handles.psdfigids(sigid) + cols(c) -1);
                legend(gca,alltags{ids});
                set(gca,'Xscale','Log','Yscale','Log');
                hold off;
                
                figure(handles.dvsffigids(sigid) + cols(c) -1);
                legend(gca,alltags{ids});
                set(gca,'Xscale','Log','Yscale','Linear');
                hold off;
            end   
        end       
    end    
end %%=========== COMPLETED PLOTTING PSD + CUMULATIVE DISTANCE ===============


%%***********       FREQUENCY RESPONSE COMPUTATION       ******************
% forth coming
%
%
%%===========   COMPLETED FREQUENCY RESPONSE COMPUTATION    ===============

% clear the memory of file-ids that were selected last time.
set(handles.button_plot,'UserData',[]);
dbclear if error

% --- Executes on button press in check_fresponse.
function check_fresponse_Callback(hObject, eventdata, handles)

% --- Executes on selection in check_3d.
function check_3d_Callback(hObject, eventdata, handles)
if (get(hObject,'Value'))
    plot3dfigure(handles);
else
    if (ishandle(handles.threeDfig))
        close(handles.threeDfig);
    end
end
% --- Executes on button press in button_test.
function button_test_Callback(hObject, eventdata, handles)
global g
keyboard
% --- Executes on button press in button_export.
function button_export_Callback(hObject, eventdata, handles)

% --- Executes on button press in button_save.
function button_save_Callback(hObject, eventdata, handles)


%%%$$$$$$$$$$$$$$$$  NON-CALLBACK ROUTINES     $$$$$$$$$$$$$$$$$$$$$$$$
%-----------------------------------------------------------------------
function updateboxresults(handles,hbox)
global g
dbstop if error
b = get(hbox,'UserData'); %has the xy location of box
% hmain  = get(handles.radio_drawbox,'UserData');% current 'main' figure id
fileid = get(handles.menu_files,'Value');
sigid = get(handles.menu_signal,'UserData');% internal ID of currently selected signal.
signame = handles.signames.intr{sigid};
sigmat = g.data{1,fileid}.(signame); 

% Now grab the points that fall inside the box
[tsel, selec] = clipper(sigmat(:,1),sigmat(:,2:end),b.xlims(1),b.xlims(2));

% Subtract out the background drift, if we are told to do so
if get(handles.check_subdrift,'Value')
    selec = subtract_background_drift(tsel,selec,handles,signame);
end

% Now perform computations and make the result strings
str.trend = []; str.detrms = []; str.p2p = []; str.detp2p = []; tab = '    ';
sf = '%+05.3f';
if any(sigid == handles.posid) % if this signal is a position measurement
    % calculate and prepend a column of R
    selec(:,2:4) = selec;
    selec(:,1) = sqrt(selec(:,2).^2 + selec(:,3).^2 + selec(:,4).^2);
    dims = get(handles.list_dims,'Value'); %selected dimensions
    strdims = get(handles.list_dims,'String');% all strings    
    for c = 1:length(dims)
        [p s] = polyfit(tsel,selec(:,dims(c)),1);                
        detrend = selec(:,dims(c)) - polyval(p,tsel);
        str.trend = [str.trend,' (',strdims{dims(c)},') ', num2str(p(1),sf),tab];
        str.detrms = [str.detrms,' (', strdims{dims(c)}, ') ',num2str(rms(detrend),sf),tab];
        str.detp2p = [str.detp2p,' (', strdims{dims(c)}, ') ',num2str(range(detrend),sf),tab];
        str.p2p = [str.p2p,' (',strdims{dims(c)}, ') ',num2str(range(selec(:,dims(c))),sf),tab];
    end
else % Not a position measurement, so no extra labels for dimensions
    for c = 1:size(selec,2)
        [p s] = polyfit(tsel,selec(:,c),1);                
        detrend = selec(:,c) - polyval(p,tsel);
        str.trend = [str.trend, num2str(p(1),sf),tab];
        str.detrms = [str.detrms, num2str(rms(detrend),sf),tab];
        str.detp2p = [str.detp2p, num2str(range(detrend),sf),tab];    
        str.p2p = [str.p2p,num2str(range(selec(:,c)),sf),tab];
    end
end
% Now print all this information on the separate figure
if (~ishandle(handles.boxresfig))
    initresultfig(handles.boxresfig);
end

figure(handles.boxresfig);
htext = get(handles.boxresfig,'UserData');
set(htext.trend,'String',['Avg Trend [dY/dX]: ',str.trend]);
set(htext.p2p,'String',  ['Peak-to-Peak     : ',str.p2p]);
set(htext.detrms,'String',  ['Detrended RMS  : ',str.detrms]);
set(htext.detp2p,'String',  ['Detrended Range: ',str.detp2p]);
dbclear if error
%-----------------------------------------------------------------------
function initresultfig(h)
sp = get(0,'ScreenSize');
figure(h);
fp = get(h,'Position');
set(h,'DoubleBuffer', 'off', ...
    'Position', [fp(1:2) sp(3)*0.3 sp(4)*0.2], ...
    'Resize', 'On', ...
    'MenuBar', 'none', ...
    'NumberTitle', 'off', ...
    'Name', 'BoxResults');

htext.trend = text(0.1,0.9,' ','FontSize',12);
htext.p2p = text(0.1,0.7,' ','FontSize', 12); 
htext.detrms = text(0.1,0.5,' ', 'FontSize', 12);         
htext.detp2p = text(0.1,0.3,' ', 'FontSize',12);
htext.units = text(0.1,0.1,'Units should be derived from units of X and Y axis','Fontsize',10);
axis off;
set(h, 'UserData', htext);
% disp('result figure initiated');    
%-----------------------------------------------------------------------
function checkdimsvalidity(handles)
val = get(handles.menu_signal,'Value');
if val == 1 | val == 2
    set(handles.list_dims,'Enable','On');
    set(handles.check_3d,'Enable','On');
else
    set(handles.list_dims,'Enable','Off');
    set(handles.check_3d,'Enable','Off');
end
%-----------------------------------------------------------------------
function prompt_user(str,handles)
% set(handles.text_message,'String',str);
disp(str);

%--------------makes the name string for edit figure -------------------
function str = getmainfigname(handles);
sigid = get(handles.menu_signal,'Value');
sigstr = get(handles.menu_signal,'String');
figid = get(handles.radio_drawbox,'UserData');
str = [num2str(figid),':',sigstr{sigid}];
%-----------------------------------------------------------------------
% --- Executes on button press in check_overlaymag.
function check_overlaymag_Callback(hObject, eventdata, handles)
overlaymag(handles);

%-----------------------------------------------------------------------
% make the matrices of signal values to be displayed and related annotations
function [sigout, annots] = filldispsig(sigin,res,signame,handles)
% first make the time abscissa with correct resolution
if res == 0;
    tout = sigin(:,1);
else
    tout = [sigin(1,1):res:sigin(end,1)]';
end

for k = 2:size(sigin,2)
    if res == 0
        temp(:,k-1) = sigin(:,k);
    else
        temp(:,k-1) = interp1(sigin(:,1),sigin(:,k),tout,'nearest');
    end    
end
% Subtract out the background drift, if we are told to do so
if get(handles.check_subdrift,'Value')
    temp = subtract_background_drift(tout,temp,handles,signame);
end
sigout(:,1) = tout; % first column is always the time
switch signame
    case {handles.signames.intr{1},handles.signames.intr{2}} %bead and stage pos                   
        
        % now pick the only dimesions that are requested
        dims = get(handles.list_dims,'value');
        for c = 1:length(dims)
            switch dims(c)
                case 1 %R
                    sigout(:,c+1) = sqrt(temp(:,1).^2 + temp(:,2).^2 + temp(:,3).^2);
                    annots.legstr{c} = 'R';
                    annots.colorOrder(c,:) = [0,0,0]; % R is always black
                case 2 %X
                    sigout(:,c+1) = temp(:,1);
                    annots.legstr{c} = 'X';
                    annots.colorOrder(c,:) = [0,0,1]; % X is always blule
                case 3 %Y
                    sigout(:,c+1) = temp(:,2);                    
                    annots.legstr{c} = 'Y';
                    annots.colorOrder(c,:) = [0,1,0]; % Y is always green          
                case 4 %Z
                    sigout(:,c+1) = temp(:,3);
                    annots.legstr{c} = 'Z';
                    annots.colorOrder(c,:) = [1,0,0]; % Z is always red             
                otherwise
                    prompt_user('Unrecognized dimension');
            end
        end
        annots.y = 'Microns';
        annots.x = 'Seconds';
        if isequal(signame,handles.signames.intr{1}) %if this is bead position
            annots.t = 'Bead Postion (relative to specimen)';
        else
            annots.t = 'Stage Postion (sensed)';
        end
    case handles.signames.intr{3} % qpd signals
        sigout(:,2:5) = temp;
        annots.legstr = {'Q1','Q2','Q3','Q4'};
        annots.colorOrder = [0 0 1; 0 1 0; 1 0 0; 0 0 0];
        annots.y = 'Volts';
        annots.x = 'Seconds';
        annots.t = 'QPD Signals';        
    case handles.signames.intr{4} %channel 8 
        sigout(:,2) = temp;
        annots.legstr = {'Ch 8'};
        annots.colorOrder = [0 0 1];
        annots.y = 'Volts';
        annots.x = 'Seconds';
        annots.t = 'ADC channel 8 (laser intensity OR magnets)';
    otherwise
        prompt_user('Error: Unrecognized signalName');
end
%-----------------------------------------------------------------------
% This function removes the pre-calculated background drift from selected
% section of the dataset. This is different than 'trend' or 'detrending' 
% which is displayed in the result-figure. 'Trend' referes to the slope of 
% the selected dataset itself, while 'drift' refers to the slope of the
% dataset previously designated as 'drift-section'.
function dout = subtract_background_drift(t,vals,handles,signame);
global g
fileid = get(handles.menu_files,'Value');
drift = g.drift{fileid}.(signame);
for c = 1:size(vals,2)% repeat for all columns
    dout(:,c) = vals(:,c) - polyval(drift(:,c),t) + drift(2,c);
end    
%-----------------------------------------------------------------------
function updatemainfig(handles,modestr)
global g
dbstop if error
if ~exist('g') | isempty(g.data)
    % if dataset empty, close all main figures
    for c = 1:length(handles.mainfigids)
        if ishandle(handles.mainfigids(c))
            close(handles.mainfigids(c));
        end
    end
    return; 
end
get(handles.menu_signal,'String');
dispname = ans{get(handles.menu_signal,'val')};
sigid = get(handles.menu_signal,'UserData');
% sigid = find(strcmp(handles.signames.disp, dispname) == 1);
signame = handles.signames.intr{1,sigid};
figid = handles.mainfigids(sigid); %handle of the main figure
set(handles.radio_drawbox,'UserData',figid);% share with others

if ishandle(figid) % if the figure is open,   
    % delete old data lines
    dlinesh = findobj(figid,'Type','Line','Tag','data');    
    delete(dlinesh);   
end

fileid = get(handles.menu_files,'value');
sigvals = g.data{1,fileid}.(signame);
switch get(handles.menu_dispres,'value')
    case 1 % full or raw resolution
        [dispmat annots] = filldispsig(sigvals,0,signame,handles);
    case 2 % 1 ms resolution       
        [dispmat annots] = filldispsig(sigvals,1e-3,signame,handles);        
    case 3 % 10 ms resolution
        [dispmat annots] = filldispsig(sigvals,1e-2,signame,handles);
    otherwise
        prompt_user('Error: Unrecognized time resolution');
end
%now ready to plot the data
 figure(figid); hold on;
% I prefer not to use gca and gcf, so that user accidentally clicking
% somewhere doesn't mess me up.
hma = findobj(figid,'Type','Axes','Tag','');
if isempty(hma) % if this is the very first time figure is plotted then axes won't exist
    % a cheap hacky work-around: make a fake axes and hold-off
    plot([0:10;0:10]);
    hma = findobj(figid,'Type','Axes','Tag','');
    hold off
end
b = []; hbox = findobj(hma,'Tag','Box'); replot_box = 0;
if ~isempty(hbox)
    b = get(hbox,'UserData');
    replot_box = 1;
end
set(hma,'colorOrder',annots.colorOrder,'NextPlot','replacechildren');
% set colororder so that each dimension has same color each time it is plotted.
% Not settig 'nextplot' replaces the parent ie axes itself.
plot(dispmat(:,1),dispmat(:,2:end),'Tag','data'); % all lines will be tagged as 'data' lines
title(annots.t);
xlabel(annots.x);
ylabel(annots.y);
set(figid,'name',getmainfigname(handles),'NumberTitle','Off');
legend(hma,annots.legstr,0);

% Now remove the old box and redraw it according to new axis limits
axis(hma,'tight');
if replot_box
    updatebox(handles,hma,0,b);
end
if isequal(lower(get(handles.check_overlaymag,'Enable')),'on')
    overlaymag(handles,figid);
end
dbclear if error
%-----------------------------------------------------------------------
function overlaymag(varargin)
global g
handles = varargin{1};
fileid = get(handles.menu_files,'value');
if nargin < 2    
    sigid = get(handles.menu_signal,'UserData');
    figid = handles.mainfigids(sigid);
else
    figid = varargin{2};
end
oldmag = findobj(figid,'Type','Line','Tag','Mag');
delete(oldmag);
% replot the magnets only if the box is checked
if get(handles.check_overlaymag,'value')
    mags = g.data{fileid}.(handles.signames.intr{4});
    % Now adjust the range so that mags are visible in the current axis
    hma = findobj(figid,'Type','Axes','Tag','');
    ylims = get(hma,'Ylim');
    mags(:,2) = mags(:,2) + ylims(1);    
    
    figure(figid); hold on;
    plot(mags(:,1),mags(:,2),'m','Tag','Mag');%magenta color
    hold off;
end

%-----------------------------------------------------------------------
function plot3dfigure(varargin)
global g
handles = varargin{1};
get(handles.menu_signal,'String');
dispname = ans{get(handles.menu_signal,'val')};
if nargin < 2    
    sigid = get(handles.menu_signal,'UserData');
    signame = handles.signames.intr{1,sigid};
    
    fileid = get(handles.menu_files,'value');
    sigvals = g.data{1,fileid}.(signame);
else
    sigvals = varargin{2};
end
sigvals(:,2:4) = sigvals(:,2:4) - repmat(sigvals(1,2:4),size(sigvals,1),1);
t = [sigvals(1,1):0.01:sigvals(end,1)]';
for c = 1:3
    p(:,c) =  interp1(sigvals(:,1),sigvals(:,c+1),t,'nearest');   
end
hmf = get(handles.radio_drawbox,'UserData');
if isempty(hmf) | hmf == 0
    sigid = get(handles.menu_signal,'UserData');
    hmf = handles.mainfigids(sigid);
    set(handles.radio_drawbox,'UserData',hmf);
end
inbox = []; prebox = []; postbox = [];
hbox = findobj(hmf,'Tag','Box');
if ~isempty(hbox)
    b = get(hbox,'UserData');
    prebox = find(t <= b.xlims(1));
    inbox = find(t < b.xlims(2) & t > b.xlims(1));
    postbox = find(t >= b.xlims(2));
else % if there is no box
    prebox = 1:size(p,1);
end
figure(handles.threeDfig); 
plot3(p(prebox,1),p(prebox,2),p(prebox,3),'k'); hold on;
plot3(p(inbox,1),p(inbox,2),p(inbox,3),'m'); 
plot3(p(postbox,1),p(postbox,2),p(postbox,3),'k'); hold off;
xlabel('X');    ylabel('Y');    zlabel('Z');
set(gca,'Xcolor','b','Ycolor','g','Zcolor','r');
set(handles.threeDfig,'Name',['3d ',dispname],'NumberTitle','Off');
%-----------------------------------------------------------------------
% This routine updates two menus: menu_files and menu_signal
% This routine is called only by 'add' and 'remove' buttons
function updatemenu(handles)
updatefilemenu(handles);
updatesignalmenu(handles);
%-----------------------------------------------------------------------
% This routine updates file menu
% This routine does not replot the main figure.
function updatefilemenu(handles)
global g
if ~exist('g') | isempty(g.data) %database is empty
    filestr = {''};        
    set(handles.menu_files,'String',filestr);
    set(handles.menu_files,'value',1);    
    return;
end
% Now fill in the tag-attached fileNames in the menu_files
% Leave the 'selected' pointer for the menu unchanged; unless
% it points to the index outside the new size of the menu, in 
% which case reset the pointer to point to one - point to first file.
for c=1:length(g.fname)
    filestr{1,c} = ['[',g.tag{1,c},']  ',g.fname{1,c}];
end
set(handles.menu_files,'String',filestr);
if get(handles.menu_files,'Value') > length(get(handles.menu_files,'String'))
    set(handles.menu_files,'Value',1);
end
%-----------------------------------------------------------------------
% This routine updates signal menu:
% 1. Checks and fills in the permitted signalNames in the signal menu
% 2. Shares the internal index (sigid) for the currently selected signal
% 3. Enables/disables 'overlay magnets' and ['3d' % 'dimension(s)'] objects
% 4. Updates the main figure
function updatesignalmenu(handles)
global g
if ~exist('g') | isempty(g.data) %database is empty     
    set(handles.menu_signal,'String',{''});
    set(handles.menu_signal,'value',1);    
    return;
end
% Now fill in the permitted signal types in the menu_signal.
% Set the selected 'signal-type' to the last value, unless
% that type is not present in the newly loaded file; in
% which case select first available signal type.
last_sigid = get(handles.menu_signal,'UserData');%could be empty
sigid = -1; %impossible value;
k = 0;
fileid = get(handles.menu_files,'Value');
for c=1:size(handles.signames.intr,2) %check for each possible signal name
    % if a field with the 'internal name' for this signal type is present in the 
    % currently selected file,
    % then put the associated 'display name' in the string-set for menu_signal.
    if isfield(g.data{1,fileid},handles.signames.intr{1,c})
        k = k+1;
        sigstr{1,k} = handles.signames.disp{1,c};
        if c == last_sigid %the last selected signal is also present in this file
            sigid = c; %then, the sigid remains unchanged
        end
    end
end
if k == 0% none of the recognized signals are present (shouldn't happen)
    prompt_user('Error: Selected file has none of the recognized signal types');
    keyboard
    return;
end
set(handles.menu_signal,'String',sigstr);
% Now determine if sigid needs to be changed
% Also, set the value of the menu_signal accordingly
if sigid > 0    % sigid is valid and doesn't need to be changed.
    TF = strcmp(sigstr,handles.signames.disp{sigid});
    set(handles.menu_signal,'Value',find(TF==1));   
else
    set(handles.menu_signal,'Value',1);
    TF = strcmp(handles.signames.disp,sigstr{1});
    sigid = find(TF==1);    
end
set(handles.menu_signal,'UserData',sigid);%share sigid with others

% if the current file has ch 8 loaded, then enable overlay of mags
if isfield(g.data{fileid}, handles.signames.intr{4})
    set(handles.check_overlaymag,'Enable','On');
else
    set(handles.check_overlaymag,'Enable','Off');
    set(handles.check_overlaymag,'Value',0);
end

checkdimsvalidity(handles);% check if RXYZ and/or 3D is applicable
updatemainfig(handles,'new');

%%%********************************************************************
%%%**********     ALL BELOW IS NEEDED BUT NOT-USED     ****************
%%%********************************************************************




























% --- Executes during object creation, after setting all properties.
function menu_files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function list_tags_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_tags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function list_dims_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_dims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function menu_exper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_exper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function menu_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function menu_dispres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_dispres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in menu_exper.
function menu_exper_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns menu_exper contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_exper

%%%####################################################################
%%%#############    GUIDE WILL ADD NEW CALLBACKS BELOW      ###########
%%%####################################################################




