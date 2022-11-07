function [correlations, isa_c, cometa_c, hr_c] = correlate_by_cond_at_ISA(xpdata, fcns, env, envhr, doplot)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcns = {@nanmean, @nanmean, @nanvar}; end    
    if nargin < 3, env = 7; end
    if nargin < 4, envhr = 14; end
    if nargin < 5, doplot=false; end

    import util.flatmat
    import util.joinpath
    
    ppnames = fieldnames(xpdata.active);
    ppno = length(ppnames);
    xp_conditions = 6;
    isa_points = 8;
    
    %Fetch per-participant data
    sz = xp_conditions * isa_points;
    isa_pp = nan(ppno, sz);
    cometa_pp = nan(ppno, sz);
    hr_pp = nan(ppno, sz);         
    for pp=1:ppno
        ppname = ppnames{pp};
        ppdata = xpdata.active.(ppname);
        [isa_arr, cometa_arr, hr_arr, ~] = get_pp_data_at_ISA(ppdata, fcns, env, envhr);
        isa_pp(pp,:) = isa_arr;
        cometa_pp(pp,:) = cometa_arr;
        hr_pp(pp,:) = hr_arr;
    end
    
    %Reorganize data, now rows identify conditions and columns participants
    %and time stamps for a certain condition
    sz2 = ppno * isa_points;
    isa_c = nan(xp_conditions, sz2);
    cometa_c = nan(xp_conditions, sz2);
    correlations = nan(xp_conditions,3);
    hr_c = nan(xp_conditions, sz2);  
    for cno = 1:xp_conditions
        startp = 1 + (cno-1) * isa_points;
        endp = cno * isa_points;
        idx = startp:endp;
        isa_tmp = flatmat(isa_pp(:,idx));
        cometa = flatmat(cometa_pp(:,idx));
        hr = flatmat(hr_pp(:,idx));
        isa_c(cno,:) = isa_tmp;
        cometa_c(cno,:) = cometa;   
        hr_c(cno,:) = hr;
        % Run correlations based for each condition
        %disp(['Correlation between ISA and COMETA for ' ppname])
        size([isa_tmp; cometa; hr]')
        tmp = corrcoef([isa_tmp; cometa; hr]');
        correlations(cno,:) = [tmp(1,2);tmp(1,3);tmp(2,3)];
        % isa vs cometa   | isa vs HR  | cometa vs HR
    end
        
    if doplot
        %colors = [[.5, 0, 0];[.7, 0, 0];[1, 0, 0];[.7,.7,.7];[.4,.4,.4];[0,0,0];];        
        ext = '.png';        
        %colors = 'bkrbkr';
        %markers = '...ooo';
        %szs = [20,20,20,6,6,6];
        
        figname = ['BYCOND_ISA_COMETA' ext];
        fig = figure('Renderer', 'painters', 'Position', [10 10 1600 400]);
        for cno =1:xp_conditions
            ax = subplot(1,xp_conditions,cno);
            scatter(ax, isa_c(cno,:), cometa_c(cno,:));
        end
        pppath = joinpath(doplot, figname);
        saveas(fig, pppath);
        close(fig)
            
        
        figname = ['BYCOND_ISA_HR' ext];
        fig = figure('Renderer', 'painters', 'Position', [10 10 1600 400]);
        for cno =1:xp_conditions
            ax = subplot(1,xp_conditions,cno);
            scatter(ax, isa_c(cno,:), hr_c(cno,:));
        end
        pppath = joinpath(doplot, figname);
        saveas(fig, pppath);
        close(fig)
        
        
        figname = ['BYCOND_COMETA_HR' ext];
        fig = figure('Renderer', 'painters', 'Position', [10 10 1600 400]);
        for cno =1:xp_conditions
            ax = subplot(1,xp_conditions,cno);
            scatter(ax, hr_c(cno,:), cometa_c(cno,:));
        end
        pppath = joinpath(doplot, figname);
        saveas(fig, pppath);
        close(fig)
    end
end

