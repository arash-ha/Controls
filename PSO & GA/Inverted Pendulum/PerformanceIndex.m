function [z, out] = PerformanceIndex(K,params)

    G = [0.3 1.2 15 2];
    
    K = G.*K;

    X0 = params.x0;
    T = params.T;
    dt = params.dt;
    t = (0:dt:T)';
    nt = numel(t);
    
    U = @(t,X) K*X;
    
    f = @(t,X) SystemModel(t,X,U,params);
    
    [~, X] = ode45(f,t,X0);
    
    x = X(:,1);
    theta = X(:,3);
    
    y = [x theta];
    
    nu = params.nu;
    u = zeros(nt,nu);
    for k=1:nt
        u(k,:) = U(t(k),X(k,:)');
    end
    
    q1 = params.WQ(1);
    q2 = params.WQ(2);
    r = params.WR;
    z = q1*sum(x.^2) + q2*sum(theta.^2) + r*sum(u.^2);
    z = z*dt/2;
    
    out.t = t;
    out.X = X;
    out.u = u;
    out.y = y;
    out.U = U;
    out.K = K;
    
end