function d = laser_msd(files, window, dim)
% 3DFM function  
% Rheology 
% last modified 01/21/06 (jcribb)
%  
% This function computes the mean-square displacements (via 
% the Stokes-Einstein relation) for an aggregate number of beads.
%  
%  [d] = laser_msd;
%  [d] = laser_msd(files, calib_um, window, dim);  
%   
%  where "files" is the filename containing video tracking data (wildcards ok) 
%        "window" is a vector containing window sizes of tau when computing MSD. 
%		 "dim" is the dimension of the input data (1D, 2D, or 3D).
%  
% Notes: - No arguments will run a 3D msd on all .mat files in the current
%          directory and use default window sizes.
%        - Use empty matrices to substitute default values.
%        - default files = '*.mat'
%        - default window = [1 2 5 10 20 50 100 200 500 1000]
%        - default dim = 3
%

if (nargin < 3) | isempty(dim)      dim = 3;   end
if (nargin < 2) | isempty(window)   window = [1 2 5 10 20 50 100 200 500 1000 1001];  end
% if (nargin < 1) | isempty(file)    file = '*.mat'; end

% load in the constants that identify the output's column headers for the current
% version of the vrpn-to-matlab program.
% % % video_tracking_constants;

% load laser data
flags.inmicrons = 0;
flags.keepuct = 0;
flags.keepoffset = 0;

TIME = 1;
X = 2;
Y = 3;
Z = 4;

% for every bead (i.e. every file)
files = dir(files);
filemax = length(files);

for idx = 1 : filemax
    filename = files(idx).name;
	v = load_laser_tracking(filename, 'b', flags);
    
    b = [v.beadpos.time v.beadpos.x v.beadpos.y v.beadpos.z];    
%     framemax = max(b(:,FRAME));
    
    % for every window size (or tau)
    for w = 1:length(window)
        
        %  for all frames
        A1 = b(1:end-window(w),X);
        A2 = b(1:end-window(w),Y);
        A3 = b(1:end-window(w),Z);

        B1 = b(window(w)+1:end,X);
        B2 = b(window(w)+1:end,Y);
        B3 = b(window(w)+1:end,Z);
        
        switch dim
            case 1
                r2 = ( B1 - A1 ).^2;
            case 2
                r2 = ( B1 - A1 ).^2 + ...
                     ( B2 - A2 ).^2 ;
            case 3
                r2 = ( B1 - A1 ).^2 + ...
                     ( B2 - A2 ).^2 + ...
                     ( B3 - A3 ).^2 ;
            otherwise
                error('dimension must be 1D, 2D, or 3D.');
        end        
 
        msd(w, idx) = mean(r2);
        tau(w, idx) = window(w) * mean(diff(b(:,TIME)));
    end   
end

% setting up axis transforms for the figure plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set it up here.

logtau = log10(tau);
logmsd = log10(msd);

mean_logtau = nanmean(logtau);
mean_logmsd = nanmean(logmsd);

sample_count = sum(~isnan(logmsd),2);

% ste_logtau = nanstd(logtau) ./ sqrt(sample_count);
% ste_logmsd = nanstd(logmsd) ./ sqrt(sample_count);

	figure;
    plot(mean_logtau, mean_logmsd);
% 	errorbar(mean_logtau, mean_logmsd, ste_logmsd);
	xlabel('log_{10}(\tau) [s]');
	ylabel('log_{10}(MSD) [m^2]');
	grid on;
	pretty_plot;

% dlmwrite('file.msd.txt', [mean_logtau(:), mean_logmsd(:), ste_logtau(:), ste_logmsd(:)], '\t');
    
    
% outputs
d.tau = tau;
d.msd = msd;
d.n = sample_count; % because beadID's are indexed by 0.

