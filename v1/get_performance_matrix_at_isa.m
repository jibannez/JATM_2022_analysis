function [performance, vnames] = get_performance_matrix_at_isa(xp, fcn, forcorrelations)
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
    isavalues = 2:2:16;
    isano = length(isavalues);   
    performance = nan(ppno,cno,isano,vno);     
    for ppi = 1:ppno
        for cci = 1:cno
            for isai = 1:isano
                cname = cnames{cci};
                ppname = ppnames{ppi};
                trdata = xp.active.(ppname).cometa.(cname);
                tidx = isavalues(isai) * 60;
                if tidx > length(trdata.COMETA)
                    tidx = length(trdata.COMETA);                    
                end
                isainterval = tidx-5:tidx;
                for vi=1:length(vnames)
                    data = trdata.(vnames{vi})(isainterval);
                    if iscell(fcn)
                        performance(ppi,cci,isai,vi) = fcn{vi}(data);           
                    else
                        performance(ppi,cci,isai,vi) = fcn(data);            
                    end
                end
            end
        end
    end
    % Some acceptRT are NaN, turn them into zero for now
    performance(isnan(performance)) = 0;
    
end

