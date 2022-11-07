function  plot_pp_correlations(isa, cometa, hr, groups, ppcorr, ppname, figname, plotpath)
% Copyright 2022 Jorge Ibáñez Gijón.    
    import util.joinpath
    
    %colors = [[.5, 0, 0];[.7, 0, 0];[1, 0, 0];[.7,.7,.7];[.4,.4,.4];[0,0,0];];

    colors = 'bkrbkr';
    markers = '...ooo';
    szs = [20,20,20,6,6,6];
    fig = figure('Renderer', 'painters', 'Position', [10 10 900 400]);
    ax1 = subplot(1,3,1);
    gscatter(isa, cometa, groups, colors,markers,szs,false,'ISA', 'COMETA');
    %legend({'A','B','C','D','E','F'})
    ax2 = subplot(1,3,2);
    gscatter(isa, hr,  groups, colors,markers,szs,false,'ISA', 'HR (bpm)');
    %legend({'A','B','C','D','E','F'})
    ax3 = subplot(1,3,3);
    gscatter(cometa, hr,  groups, colors,markers,szs,true,'COMETA','HR (bpm)');
    legend({'A','B','C','D','E','F'})
    suptitle([ppname ' ' num2str(ppcorr)])
    pppath = joinpath(plotpath, figname);
    saveas(fig, pppath);
    close(fig)
end

