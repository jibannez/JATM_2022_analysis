function  M = cometa_barplots_v2(xp, fcn)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcn = @nanmean; end
    import util.get_closest_pair
    import util.flatmat
    
    conf = prepare_conf(fcn);
    [M, ~] = getdata4correlations(xp,conf);
    [ppno, cno, vno] = size(M);
    nsqrt = sqrt(ppno);

    % Plot configurations
    [r, c] = get_closest_pair(vno);    
    dx = 0.1;
    Xlocs = [1,2,3];
    plottype = 'lines';
    adderrors = true;
    addaxislabels = true;
    addlegend = true;
    
    % Do the actual plot
    fig = figure();
    for i=1:vno
        % Create subplot for this experimental variable
        ax = subplot(r,c,i);
        
        % Select subset of data and compute mean and STE
        Y = mean(M(:,:,i));
        Err = std(M(:,:,i))/nsqrt;
        
        %Plot depending on the type selected
        if strcmp(plottype,'lines')
            plot(ax,Xlocs,Y(1:3))
            hold(ax,'on')
            plot(ax,Xlocs+dx,Y(4:6))
        elseif strcmp(plottype,'bars')
            bar(ax,Xlocs,Y(1:3),'BarWidth', 0.33)
            hold(ax,'on')
            bar(ax,Xlocs+dx,Y(4:6),'BarWidth', 0.33)   
        end
        
        % Plot error bars if configured
        if adderrors
            % Add error bars
            er1 = errorbar(ax,Xlocs,Y(1:3),Err(1:3),Err(1:3));
            er1.Color = [0 0 0];                            
            er1.LineStyle = 'none'; 
            hold(ax,'on')
            er2 = errorbar(ax, Xlocs+dx,Y(4:6),Err(4:6),Err(4:6));
            er2.Color = [0 0 0];                            
            er2.LineStyle = 'none'; 
        end
        
        % Plot axis labels if configured
        if addaxislabels
            xticks(ax,Xlocs)
            xticklabels(ax,{'Low', 'Medium','High'})
            if (r-1)*c - i < 0            
                xlabel(ax,'Complexity')
            end
        end
        
        % Plot legend if configured
        if i == 1 && addlegend
            legend({'Low Density','High Density'})
        end
        
        % Plot title
        title(ax, conf.vnames{i})
        
        % Reset x limits
        xlim([Xlocs(1)-2*dx, Xlocs(end)+2*dx])
    end
end


function conf = prepare_conf(fcn)
    conf = check_conf('pertrial'); % creates default configuration, ready to edit
    conf.fcn_perf = fcn;
    conf.fcn_phys = fcn;
    conf.fcn_cometa = fcn;
    conf.fcn_isa = fcn;
    conf.fcn_nasa = fcn;
    %conf.vnames_perf = {};
    %conf.vnames_phys = {};
    %conf.vnames_cometa = {'COMETAFlow', 'COMETAEvolution', 'COMETANonStandard', 'COMETAConflict', 'COMETAReduction'}; % removes cometa
    conf = check_conf(conf); % update vnames field
end
