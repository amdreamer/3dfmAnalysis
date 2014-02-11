function dataout = pan_process_PMExpt(filepath, systemid, exityn)
% PAN_PROCESS_PMEXPT begins the Monoptes/Panoptes analysis routine for PM experiments
%
% Panoptes function 
% 
% This function contains all of the settings and parameters needed to start
% the analysis for passive microrheology experiments using the Monoptes or 
% Panoptes instruments.  
% 
% function dataout = pan_process_PMexpt(filepath, systemid, exityn) 
%
% where "dataout" is the outputted data structure for the entire run
%       "filepath" defines the location for tracking data and metadata files
%       "systemid" defines the systed used, is either 'Monoptes' or 'Panoptes'
%       "exityn" if 'y' matlab closes after finishing the analysis
%
% Notes:
% - This function is designed to work within the PanopticNerve software
% chain but can be used manually from the matlab command line interface.
%

% First, set up default values for input parameters in case they are empty 
% or otherwise do not exist.  

% defaults to the single-channel instrument
if nargin < 2 || isempty(systemid)
    systemid = 'monoptes';
end

% does not exit matlab by default when the analysis run is complete
if nargin < 3 || isempty(exityn)
    exityn = 'n';
end

% moving to the path defined as the 'root for the experimental data'
cd(filepath);

% start a timer (to report computation time later on)
tid = tic;

% load the metadata from the appropriate files generated by PanopticNerve
metadata = pan_load_metadata(filepath, systemid, '96well');

% create the 'num_taus' vector that will decide which time scales (taus) 
% we're going to use    
duration = metadata.instr.seconds;
frame_rate = metadata.instr.fps_imagingmode;

num_taus = 35;  % number of time scales for which to calculate MSD.

% We want to identify a set of strides to step across for a given set of 
% images (frames).  We would like them to be spread evenly across the 
% available frames (times) in the log scale sense.  To do this we generate
% a logspace range, eliminate any repeated values and round them 
% appropriately, getting a list of strides that may not be as long as we
% asked but pretty close.
num_taus = unique(floor(logspace(0,round(log10(duration*frame_rate)), num_taus)));
num_taus = num_taus(:);

% Add our new list of num_taus sizes into our general metadata structure.
metadata.window = num_taus;

% Define the Aggregation parameter/parameters that will be used to combine
% the datasets in a reasonable way for analysis.
MSD_agg_param = 'metadata.plate.well_map';

% % - - Set up the filter structure - - % %
% Most of these filters will require additional parameters extracted from
% other metadata files used in the PanopticNerve workflow, e.g. microns per
% pixel length conversion.
% Note:  One must take care when using these filters as they can unduly 
% bias the results in any given direction.  Removing trackers that do not 
% exist for very long periods of time will bias the output to viscosities 
% that may be lower than the true result.

% The 'xyzunits' parameter defines the units for the trajectory.  Values
% can be 'pixels', 'um', 'm', or 'nm'
filt.xyzunits   = 'pixels';

% Oftentimes, when spot tracker first finds or is getting ready to lose a 
% tracker the error in the positionis large.  The 'tcrop' filter defines 
% the number of points removed from both sides of each trajectory.  If 
% 'tcrop' is equal to '3' then the first three and last three points are 
% removed from each trajectory.  Cleaving off these values can help 
% eliminate large swings in the MSD values at long time scales,
% because of the larger error at early or late tracking.
filt.tcrop      = 3;

% The 'min_frames' filter defines the minimum number of frames/times/points
% a trajectory can have.  Trajectories that have fewer than this number of
% frames are entirely eliminated from the tracking data.
filt.min_frames = 10;

% The 'min_pixels' filter defines the minimum number of pixels any
% trajectory must cross from its initial position.  This helps eliminate
% "stuck" beads from a collection of trajectories
filt.min_pixels = 0;

% The 'max_pixels' filter defines the maximum number of pixels any
% trajectory must cross from its initial position.  This helps eliminate
% freely diffusing beads from a collection of trajectories
filt.max_pixels = Inf;

% The 'min_visc' filter defines the minimum viscosity allowed for a 
% trajectory.  This filter uses the 'bead_radius' parameter from the 
% WELL_LAYOUT metadata file.
% filt.min_visc = 0; % Pa s

% The 'max_visc' filter defines the maximum viscosity allowed for a 
% trajectory.  This filter uses the 'bead_radius' parameter from the 
% WELL_LAYOUT metadata file.
% filt.max_visc = Inf;

% The 'xycrop' filter defines a boundary of pixels around the edge of the 
% image and eliminates trajectories that cross this boundary.  This filter
% helps by eliminating trackers that tend to diffuse in and out of the
% boundary.
filt.xycrop     = 0;

% The 'dead_spots' parameter is synonymous with the 'xycrop' filter except
% that it eliminates trackers that wander into a "dead spot" in the image.
% The first two values define the x & y position in pixels for the upper
% left corner of the dead spot.  The last two values define the length and
% width of the dead spot in pixels.  Multiple dead spots can be defined by
% adding more rows to the dead spot matrix.
% Example: filt.dead_spots = [492 128 30 30 ; ...
%                             184 359 30 30 ; ...
%                             499 319 30 30 ; ...
%                             216 149 30 30 ]; % flea2 camera deadspots on 2011/10/07
filt.dead_spots = [0 0 0 0]; 

% The 'drift_method' parameter sets the drift subtraction technique.  Valid
% values are 'none;', 'center-of-mass', and 'linear.'  Note:  Linear drift
% subtraction should never be used on freely diffusing data.  It, however,
% can be used on beads actuated by an external force like a magnetic field.
filt.drift_method = 'none';

% The 'remove jerks' filter will search through the data and find extreme
% changes in the image due to varioptic jerk and remove them.  The value
% indicates the number of pixels to observe a jerk take and jerks above
% this value are eliminated.  The jerky points are removed and replaced
% with the average value of the two nearest neighboring points (before and
% after).
% filt.jerk_limit = 1.5;

% The 'bayes_models' cell array defines the
% list box with multiple selections, order is unimportant
filt.bayes_models = {'D', 'V', 'DV', 'DA', 'DR'};


% list box with multiple selections, order is important
report_blocks = {'visc_heatmap', 'msd_heatmap', 'rmsdisp_heatmap', 'rmsdisp','meanMSD','MSD'};

% Baseline MSD computations for all datafiles
dataout  = pan_analyze_PMExpt(filepath, filt, systemid);

% Aggregate appropriate datasets and generate output report as an html file
dataout  = pan_publish_PMExpt(metadata, filt, report_blocks);

% move files into the appropriate analysis folder
outf = metadata.instr.experiment;
didx = regexp(MSD_agg_param, '[.]');
% analysis_dir = ['./matlab_analysis/' MSD_agg_param(didx(end)+1:end)];
analysis_dir = ['./matlab_analysis/PM_rheology'];
mkdir(analysis_dir);
copyfile('*.txt', analysis_dir);
[s,mess,messid] = movefile('*.html', analysis_dir);
movefile('*.fig', analysis_dir);
movefile('*.png', analysis_dir);
movefile('*.svg', analysis_dir);
movefile('*.evt.mat', analysis_dir);
if ~isempty(dir('*.drift.mat')); movefile('*.drift.mat', analysis_dir); end;
movefile([outf '.mat'], analysis_dir);

% Elapsed time
elapsed_time = toc(tid);

logentry(['Elapsed time for computation is ' num2str(elapsed_time) ' seconds.']);

if exityn == 'y'
    exit;
end

return;



% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'pan_process_PMExpt: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    
