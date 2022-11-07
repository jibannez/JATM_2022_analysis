function  [M, vnames] = plot_cometa_relative_v3(xp, fcn)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcn = @nanmean; end
    import util.get_closest_pair
    import util.flatmat
    
    conf = prepare_conf(fcn);
    [M, ~] = getdata4correlations(xp,conf);
    Mpasive = get_cometa_pasive_data_per_trial(xp, fcn);
    [M, vnames] = add_relative_cometa(M, Mpasive, conf);

    [ppno, cno, vno] = size(M);
    nsqrt = sqrt(ppno);

    % Plot configurations
    %[r, c] = get_closest_pair(vno);    
    r = 3;
    c = 6;
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
        title(ax, vnames{i})
        
        % Reset x limits
        xlim([Xlocs(1)-2*dx, Xlocs(end)+2*dx])
    end
end

function [Mout, vnames] = add_relative_cometa(M0, Mpasive, conf)
% Assumes that the last two variables are ISA and NASA,
% And the relatives variables will be placed first

[ppno, cno, vno] = size(M0);
Mpasive = repmat(Mpasive,1,1,ppno);
Mpasive = permute(Mpasive,[3,1,2]);

M1 = M0 ./ Mpasive;
M2 = M0;
M2(:,1:3,:) = M2(:,1:3,:) / 6;
M2(:,4:6,:) = M2(:,4:6,:) / 12;
Mout = cat(3, M0, M1, M2);
vnames = cell(1,3*vno);
vnames(1:vno) = conf.vnames;

for vi=1:vno
    vnames{vno+vi} = [conf.vnames{vi} 'rel'];
    vnames{2*vno+vi} = [conf.vnames{vi} 'norm'];
end
end

function conf = prepare_conf(fcn)
    conf = check_conf('pertrial'); % creates default configuration, ready to edit
    conf.fcn_perf = fcn;
    conf.fcn_phys = fcn;
    conf.fcn_cometa = fcn;
    conf.fcn_isa = fcn;
    conf.fcn_nasa = fcn;
    conf.vnames_perf = {};
    conf.vnames_phys = {};
    conf.vnames_nasa = {};
    conf.vnames_isa = {};
    %conf.vnames_cometa = {'COMETAFlow', 'COMETAEvolution', 'COMETANonStandard', 'COMETAConflict', 'COMETAReduction'}; % removes cometa
    conf = check_conf(conf); % update vnames field
end
