function params = GetParams()

    params.m = 0.2;
    params.M = 0.5;
    params.b = 0.1;
    params.l = 0.3;
    params.I = 0.006;
    params.g = 9.8;

    params.T = 10;
    params.dt = 0.02;
    params.WQ = [10 20];
    params.WR = 1;
    params.x0 = [0 0 0.1 0]';
    params.nx = numel(params.x0);
    params.nu = 1;
    
end