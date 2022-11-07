function [coeff,score,latent,tsquared,explained,mu] = run_pca_at_ISA(M,vnames)    
% Copyright 2022 Jorge Ibáñez Gijón.
    import util.joinpath
    import util.reshape_ndarray
    import util.cartesian_product
    import util.labelpoints
    
    [ppno, cno, isano, vno] = size(M);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    ppnames = cell(ppno,1);
    for pp = 1:ppno
        ppnames{pp} = ['P_' num2str(pp)];
    end
    isanames = cell(isano,1);
    for isan = 1:isano
        isanames{isan} = ['ISA_' num2str(isan*2)];
    end
    
    rsz = .3;
    
    % Run PCA with participants as cases and conditions*variables as
    % observations
    M2 = reshape_ndarray(M,[ppno, isano*cno*vno]);
    D = cartesian_product(cartesian_product(cnames,vnames),isanames);
    [Q, mu, sigma] = zscore(M2, 1, 1);
    [coeff, score, latent, tsquared, explained, mu] = pca(Q);
    figure()
    ax1 = subplot(1,3,1);
    scatter(ax1, coeff(:,1),coeff(:,2))    
    rectangle('Position',[-rsz -rsz rsz*2 rsz*2],...
        'FaceColor', [0, 0, 0, 0.2], ...
        'EdgeColor', [0, 0, 0, 0.2]);
    util.hline(0,'k-')
    util.vline(0,'k-')
    title('Weights')
    ax2 = subplot(1,3,2);
    scatter(ax2,score(:,1),score(:,2))
    labelpoints(score(:,1),score(:,2),ppnames,'N',0.1)
    util.hline(0,'k-')
    util.vline(0,'k-')
    title('Scores')
    ax3 = subplot(1,3,3);
    plot(ax3,cumsum(explained))
    title('Cumulative Explained Variance')    
    suptitle('PCA of Participants')
    grid(ax1, 'on')
    grid(ax2, 'on')
    grid(ax3, 'on')
    bdim1 = abs(coeff(:,1))>0.2;
    bdim2 = abs(coeff(:,2))>0.2;
    D(bdim1)'
    D(bdim2)'
    % Add anotations for the variables that fit the criteria

    % Run PCA with conditions as cases and participant*variables as
    % observations
    M2 = permute(M,[2,1,3,4]);
    M3 = reshape_ndarray(M2,[cno, ppno*vno*isano]);
    D = cartesian_product(cartesian_product(ppnames,vnames),isanames);
    [Q, mu, sigma] = zscore(M3, 1, 1);
    [coeff,score,latent,tsquared,explained,mu] = pca(Q);
    figure()
    ax1 = subplot(1,3,1);
    scatter(ax1, coeff(:,1),coeff(:,2))
    rectangle('Position',[-rsz -rsz rsz*2 rsz*2],...
        'FaceColor', [0, 0, 0, 0.2], ...
        'EdgeColor', [0, 0, 0, 0.2]);
    util.hline(0,'k-')
    util.vline(0,'k-')
    title('Weights')
    ax2 = subplot(1,3,2);
    scatter(ax2,score(:,1),score(:,2))
    labelpoints(score(:,1),score(:,2),cnames,'N',0.1)
    util.hline(0,'k-')
    util.vline(0,'k-')
    title('Scores')
    ax3 = subplot(1,3,3);
    plot(ax3,cumsum(explained))
    title('Cumulative Explained Variance')
    
    suptitle('PCA of Conditions')
    grid(ax1, 'on')
    grid(ax2, 'on')
    grid(ax3, 'on')
    bdim1 = abs(coeff(:,1))>0.05;
    bdim2 = abs(coeff(:,2))>0.1;
    D(bdim1)'
    D(bdim2)'
    % Add anotations for the variables that fit the criteria
    
    
    % Run PCA with conditions as cases and variables as
    % observations, averaging over all participant information
    M2 = squeeze(nanmean(nanmean(M,1),3));
    size(M2)
    [Q, mu, sigma] = zscore(M2, 1, 1);
    [coeff,score,latent,tsquared,explained,mu] = pca(Q);
    figure()
    ax1 = subplot(1,3,1);
    scatter(ax1, coeff(:,1),coeff(:,2))
    labelpoints(coeff(:,1),coeff(:,2),vnames,'N',0.1)
    rectangle('Position',[-rsz -rsz rsz*2 rsz*2],...
        'FaceColor', [0, 0, 0, 0.2], ...
        'EdgeColor', [0, 0, 0, 0.2]);
    util.hline(0,'k-')
    util.vline(0,'k-')
    title('Weights')
    ax2 = subplot(1,3,2);
    scatter(ax2,score(:,1),score(:,2))
    labelpoints(score(:,1),score(:,2),cnames,'N',0.1)
    util.hline(0,'k-')
    util.vline(0,'k-')
    title('Scores')
    ax3 = subplot(1,3,3);
    plot(ax3,cumsum(explained))
    title('Cumulative Explained Variance')
    
    suptitle('PCA of Conditions Averaged over participants')
    grid(ax1, 'on')
    grid(ax2, 'on')
    grid(ax3, 'on')
    bdim1 = abs(coeff(:,1))>0.05;
    bdim2 = abs(coeff(:,2))>0.1;
    D(bdim1)'
    D(bdim2)'
    % Add anotations for the variables that fit the criteria
end

