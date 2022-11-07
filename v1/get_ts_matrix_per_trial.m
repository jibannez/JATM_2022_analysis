function [M, vnames] = get_ts_matrix_per_trial(xp, fcn, add_cometa_components)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcn = @nanmax; end
    if nargin < 3, add_cometa_components = true; end
    
    ppnames = fieldnames(xp.active);
    ppno = length(ppnames);
    if add_cometa_components
        vnames = {'ISA','COMETA','HR','CFLOW','CEVOLUTION','CNONSTANDAR','CCONFLICT','CREDUCTION'};        
    else
        vnames = {'ISA','COMETA','HR'};
    end
    vno = length(vnames);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    cno = length(cnames);
    M = nan(ppno, cno, vno);    
    for ppi = 1:ppno
        ppname = ppnames{ppi};
        ppdata = xp.active.(ppname);
        [isa_pp, cometa_pp, hr_pp, ~] = get_pp_data_per_trial(ppdata, fcn);        
        M(ppi,:,1) = isa_pp;
        M(ppi,:,2) = cometa_pp;
        M(ppi,:,3) = hr_pp;
        if add_cometa_components
            if iscell(fcn)
                M(ppi,:,4:end) = get_pp_cometacomponents_per_trial(ppdata, fcn{1});
            else
                M(ppi,:,4:end) = get_pp_cometacomponents_per_trial(ppdata, fcn);
            end
        end
    end
end

