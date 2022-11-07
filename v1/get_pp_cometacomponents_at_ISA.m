function M = get_pp_cometacomponents_at_ISA(ppdata, vnames, fcns, env)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, vnames = {'ISA', 'COMETA', 'COMETAFlow', 'COMETAEvolution', 'COMETANonStandard', 'COMETAConflict', 'COMETAReduction'}; end
    if nargin < 3, fcns = @nanmax; end
    if nargin < 4, env = 10; end
    

    cnames = fieldnames(ppdata.ISA);
    isa_times = 2:2:16;    
    cno = length(cnames);
    vno = length(vnames);
    isano = length(isa_times);
    M = nan(cno,isano,vno);
    for cn=1:cno
        cname = cnames{cn};
        isa_data = ppdata.ISA.(cname);        
        for isan=1:isano
            %Fetch ISA values
            t=isa_times(isan);
            isa_val_name = ['ISA_' cname '_' num2str(t)];
            if iscell(fcns)
                M(cn,isan,1) = fcns{1}(isa_data.(isa_val_name));
            else
                M(cn,isan,1) = fcns(isa_data.(isa_val_name));
            end
            
            % Some time series of COMETA are smaller than 960 points
            % This is a small experimental error, just avoid it.
            tidx_c = t * 60;
            if tidx_c > length(ppdata.cometa.(cname).COMETA)
                tidx_c = length(ppdata.cometa.(cname).COMETA);
            end
            
            %Fetch all cometa components
            for vn=2:vno
                vname = vnames{vn};
                data = ppdata.cometa.(cname).(vname);
                
                if iscell(fcns)
                    M(cn,isan,vn) = fcns{vn}(data(tidx_c-env:tidx_c));
                else
                    M(cn,isan,vn) = fcns(data(tidx_c-env:tidx_c));
                end
            end
        end
    end       
end

