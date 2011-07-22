function outs = pan_load_metadata(filepath, plate_type)

if nargin < 2 || isempty(plate_type)
    plate_type = '96well';
end

if nargin < 1 || isempty('filepath')
    filepath = '.';
end

cd(filepath);

filelist = dir(filepath);

% dictionary for loading appropriate files
outs.files.wells     = dir('*ExperimentConfig*.txt');
outs.files.layout    = dir('*WELL_LAYOUT*.csv');
outs.files.MCUparams = dir('*MCUparams*.txt');

% other file lists
outs.files.video    = dir('*video*.vrpn.mat');
outs.files.tracking = dir('*_TRACKED.vrpn.mat');
outs.files.evt      = dir('*.vrpn.evt.mat');

outs = check_file_inputs(outs);

% if isempty(outs.files)
%     % insufficient metadata
%     return;
% end

% read in the intrument's parameters
if ~isfield(outs, 'files')
    logentry('No metadata found.');
    return;
end

% read in the "wells.txt" file that contains the instrument configuration
if ~isempty(outs.files.wells)
    outs.instr = pan_read_wells_txtfile( outs.files.wells.name );
end

% Read in the well layout file, if we have one
if ~isempty(outs.files.layout)
    outs.plate = pan_well_layout_to_struct( outs.files.layout.name , plate_type );
end

% read in the mcu parameters
if ~isempty(outs.files.MCUparams)
    outs.mcuparams = pan_read_MCUparamsfile( outs.files.MCUparams.name );
end


if ~isempty(outs.files.tracking)
    tmp = outs.files.tracking;
elseif ~isempty(outs.files.evt)
    tmp = outs.files.evt;
end

    
for k = 1:length(tmp)
    [well_(k) pass_(k)] = pan_wellpass(tmp(k).name);
end
    
    outs.well_list = unique(well_)';
    outs.pass_list = unique(pass_)';    
    
return;





%--  SUBFUNCTIONS BELOW  --%

function outs = check_file_inputs(ins)

    if isempty(ins.files.wells) 
        logentry('No ExperimentConfig file.');
    end

    if isempty(ins.files.layout)
        logentry('No PlateLayout file.');
    end

    if isempty(ins.files.MCUparams)
        logentry('No MCUparams file.');
    end

    if isempty(ins.files.tracking)
        logentry('No tracking data.');
    end   
    
    if isempty(ins.files.video)
        logentry('No video files.  Data can not be retracked (from here).');
    end
    
    if isempty(ins.files.evt)
        logentry('No evt files.  Will need to filter tracking data first.');
        ins.flags.filter = 1;
    end
    
%     if isempty(ins.files.wells)     || ...
%        isempty(ins.files.layout)    || ...
%        isempty(ins.files.MCUparams) || ...
%        isempty(ins.files.tracking)
%         outs = [];
%     else
%         outs = ins;
%     end;
    
    outs = ins;
    
    return;


% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'pan_load_metadata: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;