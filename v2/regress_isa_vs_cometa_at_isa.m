function [b,bint,r,rint,stats,conf] = regress_isa_vs_cometa_at_isa(xp, fcn, env)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcn = @nanmax; end
    if nargin < 3, env = 10; end
    
    import util.reshape_ndarray
    
    conf = prepare_conf(fcn, env);
    [M, conf] = getdata4correlations(xp, conf);
    [ppno, cno, isano, vno] = size(M);
    M2 = reshape_ndarray(M,[ppno*cno*isano, vno]);   
    isaidx = ismember(conf.vnames,'ISA');
    ISA = M2(:,isaidx);
    COMETA_COMPONENTS = M2;
    COMETA_COMPONENTS(:,1) = 1;
    COMETA_COMPONENTS(:,2:end) = M2(:,~isaidx);
    conf.vnames'    
    [b,bint,r,rint,stats] = regress(ISA, COMETA_COMPONENTS);
end


function conf = prepare_conf(fcn, env)
    conf = check_conf('atisa'); % creates default configuration, ready to edit
    conf.fcn_cometa = fcn;
    conf.env_cometa = env;
    conf.vnames_perf = {};
    conf.vnames_phys = {};
    conf.vnames_cometa = {'COMETAFlow', 'COMETAEvolution', 'COMETANonStandard', 'COMETAConflict', 'COMETAReduction'}; % removes cometa
    conf = check_conf(conf); % update vnames field
end
