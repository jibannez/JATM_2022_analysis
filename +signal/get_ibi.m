function ibist = get_ibi(bvp, fs, N)
% get_ibi Compute heart IBI using BVP (blood volume pressure) signals
% Copyright 2022 Jorge Ibáñez Gijón
    if nargin < 2, fs = 64; end
    if nargin < 3, N = 10; end
    
    % get z-values
    [x, bvpmean, bvpsigma] = zscore(bvp.values);
    t = bvp.time;
    
    % create sound compressor to equalize amplitudes
    dRC = compressor(-15);
    dRC.SampleRate = fs;
    [x2, gain] = dRC(x);
    
    % filter high and low freqencies to simplify before peak detection
    x3 = signal.filterpass(x2,[0.7,2],fs);
    
    % detect peaks and get IBIs and IBI times
    ibist = struct;
    [maxtab, mintab] = signal.peakdet(x3,max(x3)/N);
    ibist.IBI = diff(t(maxtab(:,1)));
    ibist.IBIt = t(maxtab(2:end,1));
    ibist.rejected = false(size(ibist.IBI));
    ibist = clean_ibi(ibist);
    %ibitbl = struct2table(ibist);
end

function ibist = clean_ibi(ibist, bpmmin, bpmmax)
    if nargin < 2, bpmmin=20; end
    if nargin < 3, bpmmax=220; end
    
    % Detect IBI below threshold
    brem = (ibist.IBI < 60/bpmmax) | (ibist.IBI > 60/bpmmin);
    ibist.rejected(brem) = 1;
    
    % Detect weird IBIs
    % define RR range as mean +/- 30%, with a minimum of 300
    mean_rr = mean(ibist.IBI(~brem));
    thirty_perc = 0.3 * mean_rr;
    if thirty_perc <= 300
        upper_threshold = mean_rr + 300;
        lower_threshold = mean_rr - 300;
    else
        upper_threshold = mean_rr + thirty_perc;
        lower_threshold = mean_rr - thirty_perc;
    end

    % identify peaks to exclude based on RR interval
    brem = (ibist.IBI <= lower_threshold) | (ibist.IBI >= upper_threshold);
    ibist.rejected(brem) = true;
    
    
    % Detect long interval with removed IBIs to disable the whole interval
    %sum(ibist.rejected)
    ibist.rejected = check_rejected(ibist.rejected, 10, 4);
    %sum(ibist.rejected)
    %ibist.rejected
   
    % detect percent outlyers
    brem = percentFilter(ibist.IBI,.20);
    ibist.rejected(brem) = true;
    
    % Remove detected IBIs
    ibist.IBI(ibist.rejected) = [];
    ibist.IBIt(ibist.rejected) = [];  

    % Check for outlyers and replace them by median
    ibist.IBI = outliers_iqr_method(ibist.IBI);
    %ibist.IBI = outliers_modified_z(ibist.IBI);
    %ibist.IBI = quotient_filter(ibist.IBI, [], 2);
end


function outRejected = check_rejected(inRejected, chunksz, thr)
    if nargin < 2, chunksz = 10; end
    if nargin < 3, thr = 4; end
        
    outRejected = inRejected(:)';
    for i=1:length(inRejected)-chunksz
        if sum(inRejected(i:i+chunksz)) > thr
            outRejected(i:i+chunksz) = true;
        end
    end
end


function [outliers] = percentFilter(s, perLimit)
    if perLimit > 1
        perLimit = perLimit/100; %assume incorrect input and correct it.
    end

    outliers = false(length(s),1); %preallocate
    pChange = abs(diff(s))./s(1:end-1); %percent change from previous
    %find index of values where pChange > perLimit
    outliers(2:end) = (pChange > perLimit);

    % Reference:
    % Clifford, G. (2002). "Characterizing Artefact in the Normal
    % Human 24-Hour RR Time Series to Aid Identification and Artificial
    % Replication of Circadian Variations in Human Beat to Beat Heart
    % Rate using a Simple Threshold."
    %
    % Aubert, A. E., D. Ramaekers, et al. (1999). "The analysis of heart
    % rate variability in unrestrained rats. Validation of method and
    % results." Comput Methods Programs Biomed 60(3): 197-213.
      
end
    

function [outibi, replaced_indices] = outliers_iqr_method(inibi)
    med = median(inibi);
    q1 = prctile(inibi, 25);
    q3 = prctile(inibi, 75);
    iqr = q3 - q1;
    lower = q1 - (1.5 * iqr);
    upper = q3 + (1.5 * iqr);
    outibi = zeros(size(inibi));
    replaced_indices = [];
    n = 0;
    for i = 1:length(inibi)
        if inibi(i) < lower || inibi(i) > upper
            outibi(i) = med;
            replaced_indices(end+1) = i;
        else
            outibi(i) = inibi(i);
        end
    end
end


function [outibi, replaced_indices] =  outliers_modified_z(inibi)
    threshold = 3.5;
    med = median(inibi);
    mean_abs_dev = MAD(inibi);
    modified_z_result = 0.6745 * (hrvalues - med) / mean_abs_dev;
    outibi = zeros(size(inibi));
    replaced_indices = [];
    for i = 1:length(inibi)
        if abs(modified_z_result(i)) <= threshold
            outibi(i) = inibi(i);
        else
            outibi(i) = med;
            replaced_indices(end+1) = i;
        end
    end
end

function  madout = MAD(data)
    med = median(data);
    madout = median(abs(data - med));
end


function RRarr = quotient_filter(RRarr, RRmask, iterations)
    if nargin < 2, RRmask = false(size(RRarr)); end
    if nargin < 3, iterations = 2; end
    
    for iteration=1:iterations
        for i = 1:length(RRarr)-1
            if RRmask(i) + RRmask(i + 1) ~= 0
                continue %skip if one of both intervals is already rejected
            elseif 0.8 <= RRarr(i) / RRarr(i + 1) <= 1.2
                continue %if R-R pair seems ok, do noting
            else
                RRmask(i) = true;
            end
        end
    end
end
