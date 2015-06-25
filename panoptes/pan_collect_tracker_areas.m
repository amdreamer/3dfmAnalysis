function bead_stacks = pan_collect_tracker_areas(filepath, systemid, imagereport)

if nargin < 3 || isempty(imagereport)
    imagereport = 'no';
end

if nargin < 2 || isempty(systemid)
     error('Need systemid-- either ''panoptes'' or ''monoptes''');
end

if nargin < 1 || isempty(filepath)
    error('No file defined.'); 
end

video_tracking_constants;

% other parameter settings
plate_type = '96well';
freqtype = 'f';
r = 20;


% load the metadata from the appropriate files generated by PanopticNerve
metadata = pan_load_metadata(filepath, systemid, '96well');

filelist = metadata.files.tracking;
FLburstfiles = metadata.files.FLburst;

Nfiles = length(filelist);

duration = metadata.instr.seconds;

filetype = 'csv'; % at the time this was written, only csv files contained area and sens values
% areas = []; sens = [];

for k = 1:Nfiles
    
    % clear out old versions of these variables if they exist
    clear tmparea tmpsens;
    
    switch filetype 
        case 'vrpn'
            myfile = filelist(k).name;
        case 'csv'
            myfile = filelist(k).name;
            myfile = strrep(myfile, 'vrpn.mat', 'csv');
        otherwise
            error('Unknown filetype. Use ''vrpn'' or ''csv'' instead.');
    end

    [well, pass] = pan_wellpass(filelist(k).name);
    
    FLburst_dir = [metadata.instr.experiment '_FLburst_pass' num2str(pass) '_well' num2str(well)];
    poop{k} = FLburst_dir;
    
    d = load_video_tracking(myfile, ...
                        metadata.instr.fps_imagingmode, ...
                        'pixels', 1, ...
                        'absolute', 'no', 'table');
                    
    if ~isempty(d)
        
        % extract the first frame from the video data
        idx = ( d(:, FRAME) == 1 );
        frame1 = d(idx,:);

        % generate a list of tracker IDs
        tracker_list = unique(d(:,ID));
        
        % extract the AREA and SENSITIVITY (fitness) of each tracker
        for m = 1:length(tracker_list)
            idx = ( frame1(:,ID) == tracker_list(m) );
            tmpdata = d(idx,:);
            tmparea(m,1) = tmpdata(1,AREA);
            tmpsens(m,1) = tmpdata(1,SENS);
        end                
        
        FLfile = [FLburst_dir '\frame0001.pgm'];
        im = imread(FLfile);
        tracker_halfsize = 15; % pull this from metadata when tracking cfg is included
        sort_by = 'sens';

% function tracker_stack = get_tracker_images(vid_table, im, tracker_halfsize, reportyn)
        mystack = get_tracker_images(frame1, im, tracker_halfsize, 'n');
    
        bead_stacks(k).pass        = pass;
        bead_stacks(k).well        = well;
%         bead_stacks(k).tlist       = tlist;
        bead_stacks(k).halfsize    = tracker_halfsize;
        bead_stacks(k).vid_table   = mystack.vid_table;
        bead_stacks(k).stack       = mystack.stack;
%         bead_stacks(k).area        = tmparea;
%         bead_stacks(k).sensitivity = tmpsens;
            
        if strfind(imagereport, 'y');    
            h = plot_tracker_images(frame1, im, tracker_halfsize, sort_by);
            
            figure(h);
            set(h, 'Name', ['Pass ' num2str(pass) ', Well ' num2str(well)]);            
        end
        
%         areas = [areas; tmparea];
%         sens  = [sens; tmpsens];
    end    
    

end

% figure; 
% hist(areas, 50);
% xlabel('Region Area [px^2]');
% ylabel('count');
% title('Tracker Region Areas for Panoptes Run');

return;