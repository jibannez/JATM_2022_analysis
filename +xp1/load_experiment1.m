function xpdata = load_experiment1(rootpath, runEDAOptim, addEDA)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 3, addEDA = true; end
    if nargin < 2, runEDAOptim = false; end
    if nargin < 1, rootpath = '/home/jorge/kabe/UAM/inv/proy/ATC/data/Experiment1'; end
    
    import util.joinpath

    % Pre-compute EDA parameters
    if runEDAOptim
        signal.compute_EDA_params();
    end
    
    xpdata = struct;

    % Set paths relative to the data folder
    pps_with_bad_data = {}; %{'P018','P024'};
    activepath = joinpath({rootpath, 'activo' });
    pasivepath = joinpath({rootpath, 'pasivo'});
    orderpath = joinpath({rootpath, 'info','ORDENSUJETOS.csv'});
    nasaisapath = joinpath({rootpath, 'info','Experimento1_NASA_ISA.csv'});
    
    % Load order of the pseudorandomized blocks
    xpdata.order = readtable(orderpath);

    % Load NASA / ISA test results
    xpdata.nasaisa = readtable(nasaisapath);
    
    % Fetch cometa values when the scenarios are run passively
    xpdata.pasive = load_cometa_pasive(pasivepath);

    % Fetch data from actual (active) trials, including time series and cometa
    out = dir2(activepath);
    if isempty(out)
        disp('Empty or non-existen directory')
        return
    end
    xpdata.active = struct;
    for ppno=1:length(out)
        ppname = out(ppno).name;
        if ismember(ppname, pps_with_bad_data)
            continue
        end
        disp(['Loading participant ' ppname])
        ppath = joinpath({activepath, ppname});
        pporder = table2cell(xpdata.order(ppno,:));
        ppnasaisa = xpdata.nasaisa(ppno,:);
        xpdata.active.(ppname) = load_participant(ppath, pporder, ppnasaisa);
        xpdata.active.(ppname).name = ppname;
    end
    
    if addEDA
        xpdata = signal.add_EDA_components(xpdata);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = load_cometa_pasive(pasivepath)
    data = struct;
    %data.name = 'pasivo';

    % Fetch the list of csv files to load
    out = dir2(joinpath({pasivepath,'*.xml.log_COMETA.csv'}));
    if isempty(out)
        disp('Empty or non-existent directory')
        return
    end

    % Iterate over files
    for fno=1:length(out)
        fname = out(fno).name;
        fields = strsplit(fname,'.');
        %cname = fields{1};
        cname_full = fields{1};
        cname = cname_full(1);
        
        fpath = joinpath({pasivepath,fname});
        tbl = readtable(fpath);

        data.(cname) = struct();
        data.(cname).time = tbl.time;
        data.(cname).COMETA = tbl.COMETA;
        data.(cname).COMETAFlow = tbl.COMETA_Flow;
        data.(cname).COMETAEvolution = tbl.COMETA_Evolution;
        data.(cname).COMETANonStandard = tbl.COMETA_Non_Standard;
        data.(cname).COMETAConflict = tbl.COMETA_Conflict;
        data.(cname).COMETAReduction = tbl.COMETA_Reduction;
        data.(cname).ActiveAircrafts = tbl.Active_aircrafts;
        data.(cname).ActiveAircraftsInsector = tbl.Active_aircrafts_insector;
        data.(cname).ActiveConflicts = tbl.Active_conflicts;
        data.(cname).Distance2Centroid = tbl.Distance2Centroid;
        data.(cname).altitudeInterventions = tbl.altitude_interventions;
        data.(cname).speedInterventions = tbl.speed_interventions;
        data.(cname).acceptRT = tbl.accept_RT;
        data.(cname).exitAltitudeSuccess = tbl.exit_altitude_success;
        data.(cname).exitSpeedSuccess = tbl.exit_speed_success;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ppdata = load_participant(ppath, order, nasaisa)
    ppdata = struct;
    tspath = joinpath({ppath, 'Pulsera'});
    cometapath = joinpath({ppath, 'Simulador'});
    ppdata.timeseries = load_participant_timeseries(tspath);
    ppdata.cometa = load_participant_cometa(cometapath);
    ppdata.order = order;
    
    % Fetch NASA/ISA values
    ppdata.gender = nasaisa{1,'SEXO'};
    ppdata.age = nasaisa{1,'EDAD'};
    ppdata.dominanthand = nasaisa{1, 'LATERALIDAD'};
    ppdata.NASA = struct;
    ppdata.ISA = struct;
    ppdata.NASA.CONTROL = nasaisa(1,{'NASA_EM_CONTROL', 'NASA_EF_CONTROL', 'NASA_ES_CONTROL', 'NASA_R_CONTROL', 'NASA_ET_CONTROL','NASA_NF_CONTROL'});
    %ppdata.NASA.CONTROL = nasaisa(1,{'NASA_EM_C', 'NASA_EF_C', 'NASA_ES_C', 'NASA_R_C', 'NASA_ET_C','NASA_NF_C'});
    conds = {'A', 'B', 'C', 'D', 'E', 'F'};
    for c=1:length(conds)
        cname = conds{c};
        nasa_cell = {['NASA_EM_' cname], ['NASA_EF_' cname], ['NASA_ES_' cname], ['NASA_R_' cname], ['NASA_ET_' cname], ['NASA_NF_' cname]};
        ppdata.NASA.(cname) = nasaisa(1, nasa_cell);
        isa_cell = cell(1,9);
        for i=2:2:16
            isa_cell{i/2} = ['ISA_' cname '_' num2str(i)];
        end
        isa_cell{end} = ['ISA_' cname ];
        ppdata.ISA.(cname) = nasaisa(1,isa_cell);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = load_participant_cometa(ppath)
    data = struct;
    out = dir2(joinpath({ppath,'*.xml.log_COMETA.csv'}));
    if isempty(out)
        disp('Empty or non-existen directory')
        return
    end
    for fno=1:length(out)
        fname = out(fno).name;
        fields = strsplit(fname,'.');
        %cname = fields{1};
        cname_full = fields{1};
        cname = cname_full(1);
        fpath = joinpath({ppath,fname});
        tbl = readtable(fpath);

        data.(cname) = struct();
        data.(cname).time = tbl.time;
        data.(cname).COMETA = tbl.COMETA;
        data.(cname).COMETAFlow = tbl.COMETA_Flow;
        data.(cname).COMETAEvolution = tbl.COMETA_Evolution;
        data.(cname).COMETANonStandard = tbl.COMETA_Non_Standard;
        data.(cname).COMETAConflict = tbl.COMETA_Conflict;
        data.(cname).COMETAReduction = tbl.COMETA_Reduction;
        data.(cname).ActiveAircrafts = tbl.Active_aircrafts;
        data.(cname).ActiveConflicts = tbl.Active_conflicts;
        data.(cname).ActiveAircraftsInsector = tbl.Active_aircrafts_insector;
        data.(cname).Distance2Centroid = tbl.Distance2Centroid;
        data.(cname).TotalClicks = tbl.TotalClicks;
        data.(cname).altitudeInterventions = tbl.altitude_interventions;
        data.(cname).speedInterventions = tbl.speed_interventions;
        data.(cname).acceptRT = tbl.accept_RT;
        data.(cname).exitAltitudeSuccess = tbl.exit_altitude_success;
        data.(cname).exitSpeedSuccess = tbl.exit_speed_success;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = load_participant_timeseries(trpath)
    % These are the variables that will be loaded, and the tags
    %vnames = {'HR', 'EDA', 'ACC', 'ACCx','ACCy','ACCz','IBI','BVP'};
    vnames = {'HR', 'EDA', 'ACC', 'IBI2','BVP'};
    
    % Output struct
    data = struct;
        
    % Load tags that register events
    tagpath = joinpath({trpath,'tags.csv'});
    if ~exist(tagpath, 'file')
        return
    end
    data.tags = load_csv_timeseries(tagpath);
    data.inittime = data.tags.values(1);
    %disp(data.inittime)
    %disp(data.tags)
    % Load selected time series
    for vno=1:length(vnames)
        vname = vnames{vno};
        vpath = joinpath({trpath,[vname,'.csv']});
        data.(vname) = load_csv_timeseries(vpath, data.inittime);        
        % Split time series in trials
        % This indexes require that the last trial is closed with two
        % events
        trial_ts = {};
        trial_times = {};
        for i=3:3:(length(data.tags.time))
            if contains(vname,'IBI')
                blower = data.(vname).time > data.tags.time(i);
                bupper = data.(vname).time < data.tags.time(i) + 60*16;
                btridx = blower & bupper;
                trial_ts{end+1} = data.(vname).values(btridx);
                trial_times{end+1} = data.(vname).time(btridx);
            else
                t0 = find(data.(vname).time == data.tags.time(i));
                t1 = find(data.(vname).time == (data.tags.time(i) + 60*16));
                trial_ts{end+1} = data.(vname).values(t0:t1);
                trial_times{end+1} = data.(vname).time(t0:t1);
            end
        end
        data.(vname).trials = trial_ts;
        data.(vname).trial_times = trial_times;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = load_csv_timeseries(filename, inittime)
    % Load the timeseries produced by the wristband during a trial.
    % A trial consists of 5 scenarios that are separated using tags. In
    % addition the tags mark the performance of NASA test along the task.
    if nargin < 2, inittime = NaN; end
    
    [~,name,~] = fileparts(filename);
    data = struct;
    switch name
        case 'tags'
            tbl = readtable(filename,'ReadVariableNames',false);
            %disp(tbl)
            data.values = round(tbl.Var1);
            data.time = data.values - data.values(1);
            % Add tags for trials that miss some due to experimenter error
            % See the function for details
            data = fix_tags(data, filename);
        case 'BVP'
            if isnan(inittime)
                error(['Variable ' name ' requires passing the tags init time'])
            end
            % Load table and related variables
            tbl = readtable(filename,'ReadVariableNames',false);
            tblcol = tbl.Var1;
            colinitime = tblcol(1);
            fs = tblcol(2);
            tblcol = tblcol(3:end);
            
            % Compute time series offset in seconds and indexes
            toffset = inittime - colinitime;
            soffset = round(toffset * fs);
            
            % For testing, set a fixed offse
            data.orig_offset = toffset;
            soffset = 2;
            
            % Store trial data and pre-trial baselines
            %disp(inittime)
            data.values = tblcol(soffset:end);
            data.baseline = tblcol(1:soffset);
            
            % Compute the time vector for this time series
            endtime = length(data.values)/fs;
            data.time = 0:1/fs:endtime-1/fs;
        case {'HR', 'EDA'}
            if isnan(inittime)
                error(['Variable ' name ' requires passing the tags init time'])
            end
            % Load table and related variables
            tbl = readtable(filename,'ReadVariableNames',false);
            %disp(tbl)
            tblcol = tbl.Var1;
            colinitime = tblcol(1);
            fs = tblcol(2);
            tblcol = tblcol(3:end);
            
            % Compute time series offset in seconds and indexes
            toffset = inittime - colinitime;
            soffset = round(toffset * fs);
            
            if soffset < 1
                'Wrong off set for file '
                filename 
                name
                inittime
                colinitime
                soffset
                soffset = 2;
            end
            
            % For testing, set a fixed offse
            data.orig_offset = toffset;
            soffset = 2;
            
            % Store trial data and pre-trial baselines
            %disp(inittime)
            data.values = tblcol(soffset:end);
            data.baseline = tblcol(1:soffset);
            
            % Compute the time vector for this time series
            endtime = length(data.values)/fs;
            data.time = 0:1/fs:endtime-1/fs;
            
            if contains(name,'EDA')
                filenameparams = [filename(1:end-4) 'params.csv'];
                data.tau0 = load(filenameparams);
            end
            
        case {'IBI','IBI2'}
            if isnan(inittime)
                error(['Variable ' name ' requires passing the tags init time'])
            end
            % Load table and related variables
            tbl = readtable(filename,'ReadVariableNames',false);
            colinitime = tbl.Var1(1);
            tbl = readtable(filename,'ReadVariableNames',false,'HeaderLines',1);
            
            % Compute time series offset in seconds and indexes
            data.orig_offset = inittime - colinitime;
            toffset = 2;            
            boffset = tbl.Var1>toffset;
            time = tbl.Var1(boffset);
            values = tbl.Var2(boffset);
            
            %data.time = time(1):1:round(time(end));
            %data.values = interp1(time, values, data.time);
            data.time = time;
            data.values = values;
            data.baseline = tbl.Var2(~boffset);

        case {'ACC','ACCx','ACCy','ACCz'}
            if isnan(inittime)
                error(['Variable ' name ' requires passing the tags init time'])
            end
            
            switch name
                case 'ACC'
                    % Load table and related variables
                    tbl = readtable(filename,'ReadVariableNames',false);
                    arr = table2array(tbl(3:end,:));
                    d = sqrt(arr(:,1).^2+arr(:,2).^2+arr(:,3).^2);
                case 'ACCx'
                    % Load table and related variables
                    tbl = readtable([filename(1:end-5),'.csv'],'ReadVariableNames',false);
                    arr = table2array(tbl(3:end,:));
                    d = arr(:,1);
                case 'ACCy'
                    % Load table and related variables
                    tbl = readtable([filename(1:end-5),'.csv'],'ReadVariableNames',false);
                    arr = table2array(tbl(3:end,:));
                    d = arr(:,2);
                case 'ACCz'
                    % Load table and related variables
                    tbl = readtable([filename(1:end-5),'.csv'],'ReadVariableNames',false);
                    arr = table2array(tbl(3:end,:));
                    d = arr(:,3);
            end
            
            %disp(tbl)
            colinitime = table2array(tbl(1,1));
            fs = table2array(tbl(2,1));
            
            % Compute time series offset in seconds and indexes
            toffset = inittime - colinitime;
            soffset = round(toffset * fs);
            
            % For testing, set a fixed offset
            data.orig_offset = toffset;
            soffset = 2;
            
            % Store trial data and pre-trial baselines
            data.values = d(soffset:end);
            data.baseline = d(1:soffset);
            
            % Compute the time vector for this time series
            endtime = length(data.values)/fs;
            data.time = 0:1/fs:endtime-1/fs;
        
        case {}
            if isnan(inittime)
                error(['Variable ' name ' requires passing the tags init time'])
            end
            % Load table and related variables
            tbl = readtable(filename,'ReadVariableNames',false);
            %disp(tbl)
            colinitime = table2array(tbl(1,1));
            fs = table2array(tbl(2,1));
            arr = table2array(tbl(3:end,:));
            g = sqrt(arr(:,1).^2+arr(:,2).^2+arr(:,3).^2);

            % Compute time series offset in seconds and indexes
            toffset = inittime - colinitime;
            soffset = round(toffset * fs);
            
            % For testing, set a fixed offset
            data.orig_offset = toffset;
            soffset = 2;
            
            % Store trial data and pre-trial baselines
            data.values = g(soffset:end);
            data.baseline = g(1:soffset);
            
            % Compute the time vector for this time series
            endtime = length(data.values)/fs;
            data.time = 0:1/fs:endtime-1/fs;
        otherwise
            error(['Unable to process file ' filename])
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = fix_tags(data, filename)
    % Set participant-specific fixes to recover missing tags that can be
    % approximately estimated. The list of recoverable issues is:
    %
    % P014 - falta tag 3 -> inicio de registros
    %      - falta tag 14 -> fin intermedio segmentos 4-5
    % P016 - falta tag 5 -> intermedio segmentos 1-2
    %
    % NaviaPPs - no se añadió el tag de fin de linea base
    NaviaPPs = {'P012','P018','P019','P020','P021','P022','P023','P024'};
    
    % Get the participant name from the file path
    strsearch = 'activo/';
    lenstr = length(strsearch);
    idx = strfind(filename, strsearch) + lenstr;
    pname = filename(idx:idx+3);
    
    if ~isempty(strfind(filename,'P020'))
        valid_idx = [1,2,3,4,7,8,9,10,14,15,16,17];
        data.values = data.values(valid_idx);
        data.time = data.time(valid_idx);
    elseif ~isempty(strfind(filename,'P024'))
        data.values = data.values(2:end);
        data.time = data.time(2:end);
    end
    
    if ~isempty(strfind(filename,'P014'))
        i = 2;
        data.values = [data.values(1:i); data.values(i)+1; data.values(i+1:end)];
        data.time = [data.time(1:i); data.time(i)+1; data.time(i+1:end)];
        i = 13;
        data.values = [data.values(1:i); data.values(i)+1; data.values(i+1:end)];
        data.time = [data.time(1:i); data.time(i)+1; data.time(i+1:end)];
        
    elseif ~isempty(strfind(filename,'P016'))
        i = 5;
        data.values = [data.values(1:i); data.values(i)+1; data.values(i+1:end)];
        data.time = [data.time(1:i); data.time(i)+1; data.time(i+1:end)];

    elseif ~isempty(find(ismember(NaviaPPs, pname), 1))
        % Get the index that corresponds to 16 minutes after the end.
        %Number of indexes in 1 and 16 minutes
        
        % This adds end of trial tag, but this is wrong, it wasn't recorded
        % V1=30000;
        % N1=V1/32;

        % Add end of baseline tag to have the same tags on all participants
        %V1=1875;
        %N1=V1/32;
        V1=60;
        N1=60;

        data.values = [data.values(1);   data.values(1)+V1; ...
                       data.values(2:3);   data.values(3)+V1; ...
                       data.values(4:5);   data.values(5)+V1; ...
                       data.values(6:7);   data.values(7)+V1; ...
                       data.values(8:9);  data.values(9)+V1; ...
                       data.values(10:11); data.values(11)+V1;  data.values(12)...
                      ];
        
        data.time = [data.time(1);   data.time(1)+N1; ...
                     data.time(2:3);   data.time(3)+N1; ...
                     data.time(4:5);   data.time(5)+N1; ...
                     data.time(6:7);   data.time(7)+N1; ...
                     data.time(8:9);  data.time(9)+N1; ...
                     data.time(10:11); data.time(11)+N1; data.time(12);...
                    ];
        
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function catPath = joinpath(dir1,dir2)

    if nargin == 1
        if iscell(dir1)
            dirlist = dir1;
            dir1 = dirlist{1};
            dir2 = dirlist{end};
            for dirN=2:length(dirlist)-1
                dir1 = joinpath(dir1,dirlist{dirN});
            end
        else
            error('Need two strings or a cell array of strings')
        end
    end

    if ispc
        sep='\';
    else
        sep='/';
    end
    catPath = strcat(dir1,sep,dir2);
end

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = dir2(dirname)
%Removes annoying outputs '..' and '.' of dir in Unixes
    function bRes = notParent(name)
        if strcmp(name,'.') || strcmp(name,'..')
            bRes = false;
        else
            bRes = true;
        end
    end
    out = dir(dirname);
    out = out(cellfun(@notParent,{out(:).name}));
end

