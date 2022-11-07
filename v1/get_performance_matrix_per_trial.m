function [performance, vnames] = get_performance_matrix_per_trial(xp, fcn, forcorrelations)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcn = @nanmax; end    
    if nargin < 3, forcorrelations = false; end    
    
    if forcorrelations
        vnames = {'ActiveAircrafts','ActiveConflicts','ActiveAircraftsInsector',...
        'Distance2Centroid', 'TotalClicks', 'altitudeInterventions',...
        'speedInterventions', 'acceptRT'};
    else
        vnames = {'ActiveAircrafts','ActiveConflicts','ActiveAircraftsInsector',...
        'Distance2Centroid', 'TotalClicks', 'altitudeInterventions',...
        'speedInterventions', 'acceptRT', 'exitAltitudeSuccess','exitSpeedSuccess'};  
    end
    vno = length(vnames);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    cno = length(cnames);
    ppnames = fieldnames(xp.active);
    ppno = length(ppnames);
    performance = nan(ppno,cno,vno);      
    for ppi = 1:ppno
        for cci = 1:cno
            cname = cnames{cci};
            ppname = ppnames{ppi};
            trdata = xp.active.(ppname).cometa.(cname);
            for vi=1:length(vnames)
                if iscell(fcn)
                    performance(ppi,cci,vi) = fcn{vi}(trdata.(vnames{vi}));                
                else
                    performance(ppi,cci,vi) = fcn(trdata.(vnames{vi}));                
                end
            end
        end
    end
    % Some acceptRT are NaN, turn them into zero for now
    performance(isnan(performance)) = 0;
    
end

