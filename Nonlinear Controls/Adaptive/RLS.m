function [teta, P] = RLS(PHI, Y, teta, P, Nv) 
K = P * PHI*(1 + PHI' * P * PHI)^-1; 
teta = teta + K * (Y - PHI' * teta); 
P = (eye(Nv) - K * PHI') * P; 
end