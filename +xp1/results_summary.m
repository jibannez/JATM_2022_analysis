function results_summary(xp)
% Copyright 2022 Jorge Ibáñez Gijón.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bar plots... not sure if we will use the plots from other software
printmsg('Plotting experiment variables')
plot_cometa_relative_v3(xp, @nanmean);
%plot_cometa_relative_v2(xp, @nanmean);
printmsg('Plot of relative and aircraft-normalized cometa variables')
cometa_barplots_v2(xp, @nanmean);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Massive Regressions (All vs All)
printmsg('At ISA massive correlations')
%massive_correlate_at_isa_v2(xp);
%pause

printmsg('Per trial massive correlations')
massive_correlate_by_pp_per_trial_v2(xp);
%pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stepwise regressions (search for minimal amount of variables from a pool) 
printmsg('At ISA stepwise regression')
%stepwise_regress_isa_vs_cometa_at_isa_v2(xp, @nanmean);
%pause

printmsg('Per trial stepwise regression')
%stepwise_regress_isa_vs_cometa_pertrial_v2(xp, @nanmean);
%pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Linear models
printmsg('At ISA linear model of ISA')
[lm,conf] = run_linearmodels(xp, 'atisa', @nanmean);
lm
pause

printmsg('Per trial linear model of ISA')
[lm,conf] = run_linearmodels(xp, 'pertrial', @nanmean);
lm
pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PCA
printmsg('At ISA PCA')
run_pca_at_ISA(xp);
pause

printmsg('Per trial PCA')
run_pca(xp);
pause
end

function printmsg(msg)
disp('========================================')
disp(msg)
disp('============................============')
end
