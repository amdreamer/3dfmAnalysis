function msdout = msdstat(msdin)

% renaming input structure
tau    = msdin.tau;
msd    = msdin.msd;
counts = msdin.ns;

if isfield(msdin, 'n');
    sample_count = msdin.n;
else
    sample_count = sum(~isnan(msd),2);
    idx = find(sample_count > 0);
    sample_count = sample_count(idx);
    msdin.n = sample_count;
end

clip = find(sum(~isnan(counts),2) <= 1);
tau(clip,:) = [];
msd(clip,:) = [];
counts(clip,:) = [];
sample_count(clip,:) = [];

% setting up axis transforms for the figure plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set it up here.
logtau = log10(tau);
logmsd = log10(msd);

numbeads = size(logmsd,2);

% weighted mean for logmsd
weights = counts ./ repmat(nansum(counts,2), 1, size(counts,2));

mean_logtau = nanmean(logtau,2);
mean_logmsd = nansum(weights .* logmsd, 2);

% computing error for logmsd
Vishmat = nansum(weights .* (repmat(mean_logmsd, 1, numbeads) - logmsd).^2, 2);
msderr =  sqrt(Vishmat ./ sample_count);

% generating output structure
msdout = msdin;
msdout.mean_logtau = mean_logtau;
msdout.mean_logmsd = mean_logmsd;
msdout.msderr = msderr;

