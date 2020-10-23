function [teta , P] = RLS(Y , U , Z , teta , P , Nv)
Y = Y(:)';
U = U(:)' ;
PHI = [Y , U]';
K = P*PHI/(1+PHI'*P*PHI) ;
P = (eye(Nv)-K*PHI')*P ;
teta = teta + K*(Z - PHI'*teta) ;
end