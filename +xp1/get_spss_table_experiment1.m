function  spsstbl = get_spss_table_experiment1(tbl, variables, between_factors)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, variables = {}; end
    if nargin < 3, between_factors = {}; end

    % Define default set of variables for analysis if no provided as args
    if isempty(variables)
       variables = {'TotalClicks' 'AircraftNo' 'AircraftNoInsector' 'MaxAircraftNoInsector'...
                    'COMETA' 'COMETArel' 'COMETAFlow' 'COMETAEvolution' 'COMETANonStandard' 'COMETAConflict' 'COMETAReduction' ...
                    'Conflicts' 'Conflictsrel' 'ConflictsMAX' 'ConflictsMAXrel' 'ConflictsRANGE' 'ConflictsRANGErel' ...
                    'CentroidDistance' 'CentroidDistancerel'...
                    'altitudeInterventions' 'speedInterventions' 'acceptRT' 'exitAltitudeSuccess' 'exitSpeedSuccess'...
                    'EDAtonic' 'EDAphasic' 'EDAtonicrel' 'EDAphasicrel'...
                    'HR' 'HRrel'...
                    'HRVSDSD' 'HRVSDNN' 'HRVRMSSD' 'HRVpNN50' 'HRVTRI' 'HRVTINN' ...
                    'HRVSD1' 'HRVSD2' 'HRVPoincareRatio' 'HRVrrHRV'...                
                    'NASAEM' 'NASAEF' 'NASAES' 'NASAR' 'NASAET' 'NASANF'...
                    'ISA2' 'ISA4' 'ISA6' 'ISA8' 'ISA10' 'ISA12' 'ISA14' 'ISA16' 'ISA'};
    end
                        %'HRVDFASHORT' 'HRVDFALONG' 'HRVCD' 'HRVApEn' ...
    % Define subject column
    ppname = 'Participant' ;   
    participants = unique(tbl.(ppname))';

    % Define within subject factors and the combinations of their levels
    within_factors = {'Complexity' 'Density'};
    complexities = {'Low', 'Medium', 'High'};
    densities = {'6', '12'};
    densities_num = [6, 12];
    complexities_num = [1, 2, 3];
    dno = length(densities_num);
    cno = length(complexities_num);
    [A,B] = ndgrid(1:cno,1:dno);
    ind = [A(:),B(:)]';
    combno = size(ind, 2);

    % A - Low6
    % B - Medium6
    % C - High6
    % D - Low12
    % E - Medium12
    % F - High12
    
    % Define the column names
    IVcolnames = [ppname between_factors{:}];
    DVcolnames = {};
    sep = '_';
    for vno=1:length(variables)
        for wlvl=1:combno
            vname = variables{vno};
            cname = complexities{ind(1,wlvl)};
            dname = densities{ind(2,wlvl)};            
            DVcolnames{end+1} = [vname sep cname sep dname];
        end
    end
    dvno = length(DVcolnames);
    
    % Define the output table
    tblheader = [IVcolnames DVcolnames];
    spsstbl = array2table(NaN(0,length(tblheader)),'VariableNames',tblheader);
    
    % Iterate over participants and 
    rno = 0;
    for pp=participants
        % Select the rows of this participant
        pptbl = tbl(tbl.(ppname) == pp,:);
        
        % Start storing values to the row
        row = [pp];
        
        % Add between levels
        for bno=1:length(between_factors)
            bname = between_factors{bno};
            row = [ row unique(pptbl.(bname))];
        end
        
        % Add repeated measures for all selected variables
        for dv=1:dvno
            colname = DVcolnames{dv};
            splitted = strsplit(colname, sep);            
            [vname, cname, dname]=deal(splitted{:});
            cidx = find_stringi_incell(complexities, cname);
            didx = find_stringi_incell(densities, dname);
            cnumeric = complexities_num(cidx);
            dnumeric = densities_num(didx);
            btbl = pptbl.Complexity == cnumeric & pptbl.Density == dnumeric;
            row = [ row table2array(pptbl(btbl, vname))];
        end
        rno = rno + 1;
        spsstbl(rno, :) = array2table(row);
    end
end


function idx = find_stringi_incell(cellstrings, string, only_first)
    % Finds the indexes where string is a member of the input cellstrings.
    % If only_first is true, returns only the first encounter
    
    if nargin < 3, only_first = true; end
    
    assert(iscell(cellstrings))
    assert(ischar(string))
    if only_first
        idx = find(ismember(cellstrings, string),1);
    else
        idx = find(ismember(cellstrings, string));
    end
end

