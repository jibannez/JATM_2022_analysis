function stepwise_regress_isa_vs_cometa_aircraftno_pertrial_v2(xp)    
% Copyright 2022 Jorge Ibáñez Gijón.
    import util.reshape_ndarray

    conf = prepare_conf();
    [M, ~] = getdata4correlations(xp,conf);
    [ppno, cno, vno] = size(M);
    M2 = reshape_ndarray(M,[ppno*cno, vno]);
    isaidx = ismember(conf.vnames,'ISA');
    ISA = M2(:,isaidx);
    COMETA_COMPONENTS = M2(:,~isaidx);
    conf.vnames(~isaidx)'
    stepwise(COMETA_COMPONENTS, ISA)
end


function conf = prepare_conf()
    conf = check_conf('pertrial'); % creates default configuration, ready to edit
    conf.vnames_perf = {'ActiveAircraftsInsector'};
    conf.vnames_phys = {};
    conf.vnames_cometa = {'COMETA'}; % removes cometa
    conf = check_conf(conf); % update vnames field
end
