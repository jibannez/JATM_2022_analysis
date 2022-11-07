function [coeff,score,latent,tsquared,explained,mu] = run_pca(xp)
% Copyright 2022 Jorge Ibáñez Gijón.
    import util.joinpath
    import util.reshape_ndarray
    import util.cartesian_product
    import util.labelpoints
    
    conf = prepare_conf();
    [M, conf] = getdata4correlations(xp, conf);
    [ppno, cno, vno] = size(M);
    vnames = conf.vnames;
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    ppnames = cell(ppno,1);
    for pp = 1:ppno
        ppnames{pp} = ['P_' num2str(pp)];
    end
    
    rsz = .25;
    
    % Run PCA with participants as cases and conditions*variables as
    % observations
    M2 = reshape_ndarray(M,[ppno, cno*vno]);
    D = cartesian_product(cnames,vnames);
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
    M2 = permute(M,[2,1,3]);
    M3 = reshape_ndarray(M2,[cno, ppno*vno]);
    D = cartesian_product(ppnames,vnames);
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
    M2 = squeeze(nanmean(M,1));
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

function conf = prepare_conf(fcn, env)
    conf = check_conf('pertrial'); % creates default configuration, ready to edit
    %conf.fcn_cometa = fcn;
    %conf.env_cometa = env;
    %conf.vnames_perf = {};
    conf.vnames_phys = {};
    %conf.vnames_nasa = {};
    %conf.vnames_cometa = {'COMETAFlow', 'COMETAEvolution', 'COMETANonStandard', 'COMETAConflict', 'COMETAReduction'}; % removes cometa
    %conf.vnames_cometa = {'COMETA'}; % removes cometa
    conf = check_conf(conf); % update vnames field
end
