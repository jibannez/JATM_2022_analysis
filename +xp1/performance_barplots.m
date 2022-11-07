function  performance_barplots(xp, bgroups)
% Copyright 2022 Jorge Ibáñez Gijón.
    import util.get_closest_pair
    import util.flatmat
    [p, vnames] = get_performance_matrix_per_trial(xp, @nanmean, false);
    [ppno,cno,vno] = size(p);
    [r, c] = get_closest_pair(vno);
    fig = figure();
    X = categorical({'High', 'Low'});
    X = reordercats(X,{'High', 'Low'});
    for i=1:vno
        ax = subplot(r,c,i);
        Y = [mean(flatmat(p(bgroups,:,i))), mean(flatmat(p(~bgroups,:,i)))];
        Err = [std(flatmat(p(bgroups,:,i))), std(flatmat(p(~bgroups,:,i)))];
        bar(ax,[1,2],Y,'BarWidth', 0.5)
        hold on
        er = errorbar([1,2],Y,[0,0],Err);
        er.Color = [0 0 0];                            
        er.LineStyle = 'none'; 
        set(ax,'xticklabel',{'High', 'Low'})
        title(ax, vnames{i})
    end

end
