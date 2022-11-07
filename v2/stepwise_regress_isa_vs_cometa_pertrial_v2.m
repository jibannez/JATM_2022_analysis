function stepwise_regress_isa_vs_cometa_pertrial_v2(xp, fcn, env)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcn = @nanmean; end
    if nargin < 3, env = 10; end
    
    import util.reshape_ndarray

    conf = prepare_conf(fcn, env);
    [M, ~] = getdata4correlations(xp,conf);
    [ppno, cno, vno] = size(M);
    M2 = reshape_ndarray(M,[ppno*cno, vno]);
    isaidx = ismember(conf.vnames,'ISA');
    ISA = M2(:,isaidx);
    COMETA_COMPONENTS = M2(:,~isaidx);
    conf.vnames(~isaidx)'
    stepwise(COMETA_COMPONENTS, ISA)
end


function conf = prepare_conf(fcn, env)
    conf = check_conf('pertrial'); % creates default configuration, ready to edit
    conf.fcn_cometa = fcn;
    conf.env_cometa = env;
    conf.vnames_perf = {};
    conf.vnames_phys = {};
    conf.vnames_nasa = {};
    conf.vnames_cometa = {'COMETAFlow', 'COMETAEvolution', 'COMETANonStandard', 'COMETAConflict', 'COMETAReduction'}; % removes cometa
    conf = check_conf(conf); % update vnames field
end
