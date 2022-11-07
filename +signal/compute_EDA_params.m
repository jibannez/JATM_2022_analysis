function compute_EDA_params(rootpath, fs)
%compute_EDA_params 
% Copyright 2022 Jorge Ibáñez Gijón
    if nargin < 1, rootpath = '/home/jorge/kabe/UAM/inv/proy/ATC/data/Experiment1'; end
    if nargin < 2, fs = 4; end
    
    import util.joinpath
    import util.dir2
    
    activepath = joinpath({rootpath, 'activo' });
    out = dir2(activepath);
    if isempty(out)
        disp('Empty or non-existen directory')
        return
    end
    parfor ppno=1:length(out)
        % set paths
        ppath = joinpath({activepath, out(ppno).name})
        tspath = joinpath({ppath, 'Pulsera'});
        edapath = joinpath({tspath,['EDA','.csv']});
        edaparamspath = joinpath({tspath,['EDAparams','.csv']});
        
        edatbl = readtable(edapath,'ReadVariableNames',false);    
        edadata = edatbl.Var1(3:end);                    
        compute_and_save_params(edaparamspath, edadata,fs);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compute_and_save_params(edapath, edadata, fs)
    if nargin < 3, fs = 4; end

    m = signal.optimcvxEDAtau0(edadata,1/fs);
    if length(m) > 1
        header = {'tau0','knots'};
        m = m';
    else
        header = {'tau0'};
    end
    write_to_file(edapath,m)
    %dlmwrite(edapath, m,'-append','delimiter',',');    
    %util.csvwrite_with_headers(edapath,m,header);
end

function write_to_file(filename, data)
%write the values of data to a file
fid = fopen(filename,'w');
for i=1:length(data)
    fprintf(fid,'%f\n',data(i));
end
fclose(fid);
end
