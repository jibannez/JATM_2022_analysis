function M = get_cometa_pasive_data_per_trial(xp, fcn)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcn = @nanmean; end
    
    conf = check_conf('pertrial');
    vno = length(conf.vnames_cometa);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    cno = length(cnames);
    M = nan(cno, vno);    
    for cn=1:cno
        cname = cnames{cn};
        for vn = 1:vno
            vname = conf.vnames_cometa{vn};
            M(cn,vn) = fcn(xp.pasive.(cname).(vname));
        end
    end
end
