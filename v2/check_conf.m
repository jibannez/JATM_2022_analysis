function conf = check_conf(conf)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 1, conf = struct; end
    
    % Assume that a char input conf indicates the type of configuration
    if isa(conf, 'char')
        dtype = conf;
        conf = struct;
        conf.dtype = dtype;
    % Replace input if non-struct was provided
    elseif ~isa(conf,'struct')
        conf = struct;
    end
    
    % Set default values for correlations configuration
    if ~isfield(conf, 'dtype') 
        conf.dtype = 'atisa';
    end
    
    if ~isfield(conf, 'fcn_isa') 
        conf.fcn_isa = @nanmean;
    end
    
    if ~isfield(conf, 'fcn_nasa') 
        conf.fcn_nasa = @nanmean;
    end
    
    if ~isfield(conf, 'fcn_cometa') 
        conf.fcn_cometa = @nanmean;
    end
    
    if ~isfield(conf, 'fcn_perf') 
        conf.fcn_perf = @nanmean;
    end
    
    if ~isfield(conf, 'fcn_phys') 
        conf.fcn_phys = @nanmean;
    end
    
    if ~isfield(conf, 'env_cometa') 
        conf.env_cometa = 10;
    end
    
    if ~isfield(conf, 'env_perf') 
        conf.env_perf = 10;
    end
    
    if ~isfield(conf, 'env_phys') 
        conf.env_phys = 10;
    end
    
    if ~isfield(conf, 'vnames_isa') 
        conf.vnames_isa = {'ISA'};
    end
    
    if ~isfield(conf, 'vnames_nasa') 
        conf.vnames_nasa = {'NASA'};
    end
    
    if ~isfield(conf, 'vnames_cometa') 
        conf.vnames_cometa = {'COMETA', 'COMETAFlow', 'COMETAEvolution', 'COMETANonStandard', 'COMETAConflict', 'COMETAReduction'};
    end
    
    if ~isfield(conf, 'vnames_perf_pertrial')        
        conf.vnames_perf_pertrial = {...
            'ActiveConflicts','ActiveAircraftsInsector',...
            'Distance2Centroid', 'TotalClicks',...
            'altitudeInterventions','speedInterventions', 'acceptRT',...
            'exitAltitudeSuccess','exitSpeedSuccess'};
    end
    
    if ~isfield(conf, 'vnames_perf_atisa')
        conf.vnames_perf_atisa = {...
            'ActiveConflicts','ActiveAircraftsInsector',...
            'Distance2Centroid', 'TotalClicks', ...
            'altitudeInterventions','speedInterventions',...
            'exitAltitudeSuccess','exitSpeedSuccess'};
    end
    
    if ~isfield(conf, 'vnames_phys')
        conf.vnames_phys = {...
            'HR','IBI',...
            'EDAtonicrel','EDAphasicrel'};%,...
            %'EDAtonic','EDAphasic','EDAtonicrel','EDAphasicrel'};%,...
            %'HRVSDSD','HRVSDNN', 'HRVRMSSD', 'HRVpNN50', 'HRVTRI', 'HRVTINN', 'HRVrr'};
    end
    
    % SET CONFIGURATION-TYPE SPECIFIC VALUES
    if strcmp(conf.dtype, 'atisa')
        if ~isfield(conf, 'vnames_perf')      
            conf.vnames_perf = conf.vnames_perf_atisa;
        end
        conf.vnames_nasa = {};
        
    elseif strcmp(conf.dtype, 'pertrial')
        if ~isfield(conf, 'vnames_perf')
            conf.vnames_perf = conf.vnames_perf_pertrial;
        end
        
    else        
        if ~isfield(conf, 'vnames_perf')
            conf.vnames_perf = {};
        end
    end
    
    % CONCATENATE SELECTED VARIABLES
    conf.vnames = [conf.vnames_cometa conf.vnames_perf conf.vnames_phys conf.vnames_isa conf.vnames_nasa];
    
    % Set default option for filtering outlyers
    if ~isfield(conf, 'filteroutliers')
        conf.filteroutliers = false;
    end
    
end
