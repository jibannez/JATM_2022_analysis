function tbl = get_stats_experiment1(xp)
% Copyright 2022 Jorge Ibáñez Gijón.
% All within design, we have the following hierarchy:
% - Participant 
%    - Occupation 
%       - Difficulty (these two are included in Condition)
%            - Rotation
% The rows of the table will therefore contain the following columns:
%
% PP Occu Cond NAircrafts COMETA COMETA_rel  Conflicts Conflicts_rel CentroidDistance CentroidDistance_rel  HR HR_rel EDA EDA_rel 
% 
% For performance variables, relative means with respect to pasive
% condition. In phisiological variables, relative means with respect to
% baseline.


        
vnames = {'Participant' 'Gender' 'Age' 'Dominant'  'Condition' 'Complexity' 'Density' 'Rotation' 'AircraftNo' 'AircraftNoInsector' 'MaxAircraftNoInsector' 'TotalClicks'...
          'COMETA' 'COMETArel' 'COMETAFlow' 'COMETAEvolution' 'COMETANonStandard' 'COMETAConflict' 'COMETAReduction' 'Conflicts' 'Conflictsrel' 'ConflictsMAX' 'ConflictsMAXrel' 'ConflictsRANGE' 'ConflictsRANGErel' ...
          'CentroidDistance' 'CentroidDistancerel' ...
          'altitudeInterventions' 'speedInterventions' 'acceptRT' 'exitAltitudeSuccess' 'exitSpeedSuccess'...
          'EDAtonic' 'EDAphasic' 'EDAtonicrel' 'EDAphasicrel'...
          'HR' 'HRrel'...
          'HRVSDSD' 'HRVSDNN' 'HRVRMSSD' 'HRVpNN50' 'HRVTRI' 'HRVTINN' ...
          'HRVSD1' 'HRVSD2' 'HRVPoincareRatio' 'HRVrrHRV'...
          'NASAEM' 'NASAEF' 'NASAES' 'NASAR' 'NASAET' 'NASANF'...
          'ISA2' 'ISA4' 'ISA6' 'ISA8' 'ISA10' 'ISA12' 'ISA14' 'ISA16' 'ISA'};
                %'HRVDFASHORT' 'HRVDFALONG' 'HRVCD' 'HRVApEn' ...
vno = length(vnames);
%complexities = {'Low', 'Medium', 'High'};
%densities = {6, 12};
conditions = {'A','B','C','D','E','F'};
conditions2 = {[1,6], [2,6], [3,6], [1,12], [2,12], [3,12]};
% A - Low6
% B - Medium6
% C - High6
% D - Low12
% E - Medium12
% F - High12


% Discard participants that lacks timeseries or have bad simulator logs
%pps_with_bad_data = {'P012'};
pps_with_bad_data = {};%{'P018', 'P019','P021','P022','P023','P024'};
        
% Fetch stats for pasive trials, keep them in a struct because they will
% only be used for comparison using relative variables.
pasive = struct;
pcond = fieldnames(xp.pasive);
for cno=1:length(pcond)
    cname = pcond{cno};
    cdata = xp.pasive.(cname);
    pasive.(cname) = struct();
    pasive.(cname).COMETA = nanmean(cdata.COMETA);
    pasive.(cname).Conflicts = nanmean(cdata.ActiveConflicts);
    pasive.(cname).ConflictsMAX = nanmax(cdata.ActiveConflicts);
    pasive.(cname).ConflictsMIN = nanmin(cdata.ActiveConflicts);
    pasive.(cname).ConflictsRANGE = pasive.(cname).ConflictsMAX - pasive.(cname).ConflictsMIN;
    pasive.(cname).Centroidist = nanmean(cdata.Distance2Centroid);
end
    
%Create long table to store results
tbl = array2table(NaN(0,vno),'VariableNames',vnames);

%Create rows one by one, iterating over all possible values
rno = 0;
participants = fieldnames(xp.active);
for ppno=1:length(participants)
    ppname = participants{ppno};

    % Discard participants that lacks timeseries or have bad simulator logs
    if ismember(ppname, pps_with_bad_data)
        continue
    end

    % Local copies of relevant data structures, to unclutter code
    data = xp.active.(ppname);
    tdata = data.timeseries;
    ndata = data.NASA;
    idata = data.ISA;
    pporder = data.order;
    
    % Fetch participant gender
    if strcmp(data.gender, 'M')
        gender = 1; % Male
    else
        gender = 2; % Female
    end
    
    % Fetch participant handedness
    if strcmp(data.dominanthand, 'D')
        hand = 1; % Right
    else
        hand = 2; % Left
    end
    
    % Fetch EDA tonic and phasic baselines
    edatonicbase = mean(data.timeseries.EDA.global.tonic);
    edaphasicbase = mean(data.timeseries.EDA.global.phasic);
    
    trno = length(fieldnames(data.cometa));
    for i=1:trno
        % Fetch condition and rotation from order table
        cno = i*2; % Each condition/rotation pair occupies two columns
        condition = pporder{cno};
        rotation =  pporder{cno+1};
        cnumeric = find_stringi_incell(conditions, condition);
        
        % Split density/complexity factors from the combined condition
        condition2 = conditions2{cnumeric};
        complexity = condition2(1);
        density = condition2(2);

        % Local instance of active and pasive data for this condition,
        % as well as timeseries, to reduce lookup time and improve visuals.
        %cname = [condition num2str(rotation)];
        cname = condition;
        disp(['Loading participant: ' ppname ' condition: ' cname ])
        cdata = data.cometa.(cname);
        pdata = pasive.(cname);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fetch performance variables
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        aircraftno = nanmean(cdata.ActiveAircrafts);
        aircraftnoinsector = nanmean(cdata.ActiveAircraftsInsector);
        maxaircraftnoinsector = nanmax(cdata.ActiveAircraftsInsector);
        %Cometa
        COMETA = nanmean(cdata.COMETA);
        COMETA_rel = COMETA / pdata.COMETA;
        COMETAFlow = nanmean(cdata.COMETAFlow);
        COMETAEvolution = nanmean(cdata.COMETAEvolution);
        COMETANonStandard = nanmean(cdata.COMETANonStandard);
        COMETAConflict = nanmean(cdata.COMETAConflict);
        COMETAReduction = nanmean(cdata.COMETAReduction);
        
        %Conflicts
        Conflicts = nanmean(cdata.ActiveConflicts);
        Conflicts_rel = Conflicts - pdata.Conflicts;
        ConflictsMAX = nanmax(cdata.ActiveConflicts);
        ConflictsMAX_rel = ConflictsMAX - pdata.ConflictsMAX;
        ConflictsMIN = nanmin(cdata.ActiveConflicts);
        ConflictsRANGE = ConflictsMAX - ConflictsMIN;
        ConflictsRANGE_rel = ConflictsRANGE - pdata.ConflictsRANGE;
        %Centroids
        Centroidist = nanmean(cdata.Distance2Centroid);
        Centroidist_rel = Centroidist / pdata.Centroidist;
        %Clicks
        TotalClicks = nanmean(cdata.TotalClicks);
        %Interventions
        altitudeInterventions = nanmean(cdata.altitudeInterventions);
        speedInterventions = nanmean(cdata.speedInterventions);
        % Reaction times of Accept events
        acceptRT = nanmean(cdata.acceptRT);
        %Percentaje of correct exit altitudes and speeds
        exitAltitudeSuccess = nanmean(cdata.exitAltitudeSuccess);
        exitSpeedSuccess = nanmean(cdata.exitSpeedSuccess);        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fetch physiological variables
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        HR = nanmean(filterOutliers(tdata.HR.trials{i}));
        HRrel = HR / nanmean(filterOutliers(tdata.HR.baseline));
        EDAtonic = nanmean(data.timeseries.EDA.trials_tonic{i});
        EDAphasic = nanmean(data.timeseries.EDA.trials_phasic{i});
        EDAtonicrel = EDAtonic / edatonicbase;
        EDAphasicrel = EDAphasic / edaphasicbase;
            
        EDA = nanmean(filterOutliers(tdata.EDA.trials{i}));
        EDArel = EDA / nanmean(filterOutliers(tdata.EDA.baseline));
        
        IBI = HRV.RRfilter(tdata.IBI2.trials{i});
        %IBI = tdata.IBI2.trials{i};        
        HRV_SDSD = HRV.SDSD(IBI);
        HRV_SDNN = HRV.SDNN(IBI);
        HRV_RMSSD = HRV.RMSSD(IBI);
        HRV_pNN50 = HRV.pNN50(IBI);
        HRV_TRI = HRV.TRI(IBI);
        HRV_TINN = HRV.TINN(IBI);        
        %HRV_DFA = HRV.DFA(IBI);
        %HRV_DFA_SHORT = HRV_DFA(1);
        %HRV_DFA_LONG = HRV_DFA(2);
        %HRV_CD = HRV.CD(IBI);
        %HRV_ApEn = HRV.ApEn(IBI);
        [HRV_SD1, HRV_SD2, HRV_PoincareRatio] = HRV.returnmap_val(IBI);
        HRV_rrHRV = HRV.rrHRV(IBI);

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fetch NASA values for this trial
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        NASA_EM = ndata.(condition).(['NASA_EM_' condition]);
        NASA_EF = ndata.(condition).(['NASA_EF_' condition]);
        NASA_ES = ndata.(condition).(['NASA_ES_' condition]);
        NASA_R = ndata.(condition).(['NASA_R_' condition]);
        NASA_ET = ndata.(condition).(['NASA_ET_' condition]);
        NASA_NF = ndata.(condition).(['NASA_NF_' condition]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fetch ISA values for this trial
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ISA_2 = idata.(condition).(['ISA_' condition '_2']);
        ISA_4 = idata.(condition).(['ISA_' condition '_4']);
        ISA_6 = idata.(condition).(['ISA_' condition '_6']);
        ISA_8 = idata.(condition).(['ISA_' condition '_8']);
        ISA_10 = idata.(condition).(['ISA_' condition '_10']);
        ISA_12 = idata.(condition).(['ISA_' condition '_12']);
        ISA_14 = idata.(condition).(['ISA_' condition '_14']);
        ISA_16 = idata.(condition).(['ISA_' condition '_16']);
        ISA = idata.(condition).(['ISA_' condition]);

        % Create the row by concatenating all variables 
        row = [ppno, gender, data.age, hand, cnumeric, complexity, density, rotation,...
               aircraftno, aircraftnoinsector, maxaircraftnoinsector, TotalClicks, ...
               COMETA, COMETA_rel, COMETAFlow, COMETAEvolution, COMETANonStandard, COMETAConflict, COMETAReduction,...
               Conflicts, Conflicts_rel, ConflictsMAX, ConflictsMAX_rel, ConflictsRANGE, ConflictsRANGE_rel,...
               Centroidist, Centroidist_rel, ...
               altitudeInterventions, speedInterventions, acceptRT, exitAltitudeSuccess, exitSpeedSuccess,...
               EDAtonic, EDAphasic, EDAtonicrel, EDAphasicrel,...
               HR, HRrel,...
               HRV_SDSD,HRV_SDNN,HRV_RMSSD,HRV_pNN50,HRV_TRI,HRV_TINN,...               
               HRV_SD1,HRV_SD2,HRV_PoincareRatio,HRV_rrHRV,...
               NASA_EM, NASA_EF, NASA_ES, NASA_R, NASA_ET, NASA_NF,...
               ISA_2, ISA_4, ISA_6, ISA_8, ISA_10, ISA_12, ISA_14, ISA_16, ISA ];
           %HRV_DFA_SHORT,HRV_DFA_LONG,HRV_CD,HRV_ApEn,...
        % Store row data in the table
        rno = rno + 1;
        tbl(rno,:) = array2table(row);
    end
end
%tbl = filterOutliersMatlab(tbl);
end


function idx = find_stringi_incell(cellstrings, string, only_first)
    % Finds the indexes where string is a member of the input cellstrings.
    % If only_first is true, returns only the first encounter
    
    if nargin < 3, only_first = true; end
    
    assert(iscell(cellstrings))
    assert(ischar(string))
    if only_first
        idx = find(ismember(cellstrings, string),1);
    else
        idx = find(ismember(cellstrings, string));
    end
end


function filtered = filterOutliers(data, nstds)
    if nargin < 2, nstds = 3; end
    data = data(isfinite(data));
    filtered = data-mean(data);
    filtered = data(abs(filtered)<nstds*std(data));
end

function data = filterOutliersReplacing(data, nstds)
    if nargin < 2, nstds = 3; end
    data = data(isfinite(data));
    mu = mean(data);
    sigma = std(data);
    bout = abs(data - mu) > sigma*nstds;
    data(bout) = mu;
end

function data = filterOutliersMatlab(data)
    data = filloutliers(data,'center','gesd');
end
