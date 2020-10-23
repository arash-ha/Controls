function params = GetParams()

    params.R = 2;
    params.L = 0.5;
    params.J = 0.02;
    params.Kf = 0.2;
    params.Kb = 0.1;
    params.Km = 0.1;

    params.T = 4;
    params.dt = 0.2;
    params.WQ = 1000;
    params.WR = 1;
    params.x0 = [0 0]';
    params.nx = numel(params.x0);
    params.nu = 1;
    
    params.r = 1;
    
end