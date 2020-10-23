function xdot = SystemModel(t,x,U,params)

    R = params.R;
    L = params.L;
    J = params.J;
    Kf = params.Kf;
    Km = params.Km;
    Kb = params.Kb;

    w = x(1);
    i = x(2);
    vin = U(t, x);
    
    wdot = (-Kf*w + Km*i)/J;
    idot = (-Kb*w - R*i + vin)/L;
    
    xdot = [wdot; idot];

end