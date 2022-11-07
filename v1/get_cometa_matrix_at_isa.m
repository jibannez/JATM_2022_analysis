function [M, vnames] = get_cometa_matrix_at_isa(xp, fcn, env)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcn = @nanmax; end
    if nargin < 3, env = 10; end
    
    ppnames = fieldnames(xp.active);
    ppno = length(ppnames);
    vnames = {'ISA', 'COMETAFlow', 'COMETAEvolution', 'COMETANonStandard', 'COMETAConflict', 'COMETAReduction'};
    vno = length(vnames);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    cno = length(cnames);
    isa_times = 2:2:16;    
    isano = length(isa_times);
    M = nan(ppno, cno, isano, vno);
    for ppi = 1:ppno
        ppname = ppnames{ppi};
        M(ppi,:,:,:) = get_pp_cometacomponents_at_ISA(xp.active.(ppname), fcn, env);
    end
end
