function paramsout = optimcvxEDAtau0(y,delta, minp, maxp)
% optimcvxEDAtau0 Optimize EDA tau0 parameter for cvxEDA computation
% Copyright 2022 Jorge Ibáñez Gijón
    if nargin < 4, maxp = 4; end
    if nargin < 3, minp = 2; end
    
    y2 = signal.filterdata(y,1,8);
    tau1 = 0.7;
    delta_knot = 10;
    alpha = 0.0008;
    gamma = 0.01;
    solver = 'quadprog';
    
    function l2norm = cvxEDA4tau0(paramsin)
        % y must be already normalized
        [~, ~, ~, ~, ~, e, ~] = signal.cvxEDA(y2, delta, paramsin,tau1,delta_knot,alpha,gamma,solver);
        l2norm = norm(e,2);
    end

    options = optimset('Display','iter', 'TolFun',0.01, 'TolX',0.01);
    paramsout = fminbnd(@cvxEDA4tau0, minp, maxp, options);
    %paramsout = fminsearch(@cvxEDA4tau0, [2,10], options);
    
end
