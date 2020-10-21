clc;
clear all;
close all;
warning OFF ; %#ok
%% generate initial data

Ts = 1;
Tf = 500 ;
t = 0:Ts:Tf ;
change = 1 ;   % 1:change   0:no change
dist   = 1 ;    % 1:add dist  0:don't add 
uc = gensig('square' , Tf/10 , Tf , Ts) ; % refenrence signal
edist = randn(size(t)).*(t>350).*(t<360);
% plant model
system = tf(1 , [1 2]) ;
systemd = c2d(system , Ts) ;
[Bd , Ad] =tfdata(systemd) ;
Bd = cell2mat(Bd) ; B = Bd(2:end) ;
Ad = cell2mat(Ad) ; A = Ad ;

% reference model plant
sysref = tf(2,[1 2 2]) ;
sysrefd = c2d(sysref , Ts) ;
[Bm , Am] = tfdata(sysrefd) ;
Bm = cell2mat(Bm) ;
Am = cell2mat(Am) ; 
AA = Am - Bm ; % A(z^-1)-z^-d*B(z^-1);
Bm = Bm(2:end) ;
%% main loop  ===>> adaptive pid based on RLS estimator
N = numel(t);
Nv = 3 ;
d = numel(Am) - numel(Bm) ;
d0 = numel(A) - numel(B) ;
deltaBm = conv(Bm , [1 -1]) ;

y    = zeros(Nv , 1) ;
u    = zeros(Nv , 1) ;
e    = zeros(Nv , 1) ;
yabm = zeros(Nv , 1) ;
ubm  = zeros(Nv , 1) ;

teta  = randn(Nv , Nv) ;
P = 1e4*eye(Nv) ;

for i = Nv+1:N
    
    if  i == floor(2*N/5) && change
        % new plant model
        system = tf(5 , [1 5]) ;
        systemd = c2d(system , Ts) ;
        [Bd , Ad] =tfdata(systemd) ;
        Bd = cell2mat(Bd) ; B = Bd(2:end) ;
        Ad = cell2mat(Ad) ; A = Ad ;
    end
    
    if mod(i , 50) == 0
        P = 1e4*eye(Nv) ;
    end
    
    y(i) = -A(2:end)*y(i-1:-1:i-(numel(A)-1))+B*u(i-d0:-1:i-(numel(A)-1)) + dist*edist(i);
    yabm(i) = AA*y(i:-1:i-(numel(AA)-1)) ;
    ubm(i) = deltaBm*u(i-d:-1:i-(numel(deltaBm)-1)-d) ;
    e(i) = uc(i) - y(i) ;
    Y = yabm(i:-1:i-2) ;
    U = [];
    Z = ubm(i) ;
    [teta(:,i) , P] = RLS(Y , U , Z , teta(:,i-1) , P , Nv) ;
    S0 = teta(1 , i) ;
    S1 = teta(2 , i) ;
    S2 = teta(3 , i) ;
    u(i) = u(i-1)+S0*e(i) + S1*e(i-1)+S2*e(i-2) ;
end
%% plot results 
ym = lsim(sysref , uc , t) ;
figure();
plot(t , ym , t , y , 'LineWidth' , 2) ;
xlabel('Time  (second)');
ylabel('y-ym');
title('Adaptive PID based on RLS estimator');
grid on
legend('ref','Actual output') ;


figure();
plot(t , u , 'LineWidth' , 2) ;
xlabel('Time  (second)');
ylabel('u');
title('Adaptive PID based on RLS estimator - effort control');
grid on
legend('u') ;

Kp = -(teta(2,:)+2*teta(3,:)) ;
Ki = teta(1,:)+teta(2,:) + teta(3,1) ;
Kd = teta(3,:) ;

figure();
plot(t , [Kp;Ki ; Kd] , 'LineWidth' , 2) ;
xlabel('Time  (second)');
ylabel('parameters');
title('Adaptive PID based on RLS estimator - PID parameters converence');
grid on
legend('Kp' , 'Ki' , 'Kd') ;



