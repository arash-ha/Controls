function [z, out] = PerformanceIndex(K,params)

    x0 = params.x0;
    T = params.T;
    dt = params.dt;
    t = (0:dt:T)';
    nt = numel(t);
    
    r = params.r;
    U = @(t,x) r - K*x;
    
    f=@(t,x) SystemModel(t,x,U,params);
    
    [~, x] = ode45(f,t,x0);
    
    y = x(:,1);
    
    nu = params.nu;
    u = zeros(nt,nu);
    for k = 1:nt
        u(k,:) = U(t(k),x(k,:)');
    end
    
    WQ = params.WQ;
    WR = params.WR;
    z = 0;
    for k = 1:nt
        z = z + (r-y(k,:))*WQ*(r-y(k,:))' + u(k,:)*WR*u(k,:)';
    end
    z = z*dt/2;
    
    out.t = t;
    out.x = x;
    out.u = u;
    out.y = y;
    out.U = U;
    
end