function Xdot = SystemModel(t,X,U,params)

    m = params.m;
    M = params.M;
    b = params.b;
    l = params.l;
    I = params.I;
    g = params.g;

    x = X(1); %#ok
    v = X(2);
    theta = X(3);
    w = X(4);
    F = U(t,X);
    
    vdot = ((F-b*v-m*l*w^2*sin(theta))*(I+m*l^2)+g*(m*l)^2*sin(theta)*cos(theta))...
           / ((M+m)*(I+m*l^2)-(m*l*cos(theta))^2);
    
    wdot = (m*g*l*sin(theta)+m*l*vdot*cos(theta))/(I+m*l^2);
       
    Xdot=[v; vdot; w; wdot];

end