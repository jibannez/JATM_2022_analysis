function data = get_pp_cometacomponents_per_trial(ppdata, fcn)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcn = @nanmax; end
    
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    vnames = {'COMETAFlow', 'COMETAEvolution', 'COMETANonStandard', 'COMETAConflict', 'COMETAReduction'};
    cno = length(cnames);
    vno = length(vnames);    
    data = nan(cno,vno);    
    for cn=1:cno
        % Fetch name of this condition
        cname = cnames{cn};
        for vn = 1:vno
            %Fetch this variable name
        	vname = vnames{vn};
            data(cn,vn) = fcn(ppdata.cometa.(cname).(vname));
        end
    end    
end

