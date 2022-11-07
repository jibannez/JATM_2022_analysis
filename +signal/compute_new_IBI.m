function compute_new_IBI(rootpath, fs, N)
%compute_new_IBI Update IBI computation using bvp signals
% Copyright 2022 Jorge Ibáñez Gijón
    if nargin < 1, rootpath = '/home/jorge/kabe/UAM/inv/proy/ATC/data/Experiment1'; end
    if nargin < 2, fs = 64; end
    if nargin < 3, N = 5; end
    
    import util.joinpath
    import util.dir2
    
    activepath = joinpath({rootpath, 'activo' });
    out = dir2(activepath);
    if isempty(out)
        disp('Empty or non-existen directory')
        return
    end
    for ppno=1:length(out)
        % set paths
        ppath = joinpath({activepath, out(ppno).name})
        tspath = joinpath({ppath, 'Pulsera'});
        bvppath = joinpath({tspath,['BVP','.csv']});
        ibi2path = joinpath({tspath,['IBI2','.csv']});

       % Load table and related variables            
       load_and_save_ibi(bvppath, ibi2path, fs, N);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ibist] = load_and_save_ibi(bvppath, ibi2path, fs, N)
    if nargin < 3, fs = 64; end
    if nargin < 4, N = 10; end
    
    bpvtbl = readtable(bvppath,'ReadVariableNames',false);    
    bvpfs = bpvtbl.Var1(2);
    inittime = bpvtbl.Var1(1);
    endtime = (height(bpvtbl)-2)/bvpfs;
    bvp = struct;
    bvp.values = bpvtbl.Var1(3:end);
    bvp.time = (0:1/bvpfs:endtime-1/bvpfs)';
    
    ibist = signal.get_ibi(bvp, fs, N);
    %ibitmp = readtable(ibipath,'ReadVariableNames',false,'HeaderLines',1);
    %m = table2matrix(ibitmp);
    m = [ibist.IBIt(2:end), ibist.IBI(2:end)];
    header={num2str(inittime), 'IBI'};
    util.csvwrite_with_headers(ibi2path,m,header);
end

    

