clc;
close all;
clear;
%%
Ts = 0.01;
Tf = 200;
t = 0:Ts:Tf;
uc = gensig('square' , 20 , Tf , Ts);
u = zeros(size(t));
y = zeros(size(t));
ym = zeros(size(t));
e = zeros(size(t));

am = 4;
bm = 4;
a = 0.5;
b = 1;
Nv = 2;
teta = rand(Nv  , 1);
P = 1e3 * eye(Nv);
unc = 1 ; %  unc = 1::add unc.   0:: no unc.
for  i = 1:numel(t)-1
    if i == floor(numel(t)/2) && unc
        a = 1;
        b = 0.5;
    end
    y(i+1) = y(i) + Ts * (-a*y(i) + b * u(i));
    ym(i+1) = ym(i) + Ts * (-am*ym(i) + bm * uc(i));
    e(i+1) = y(i+1) - ym(i+1);
    Y = (y(i+1) - y(i))/Ts;
    PHI = [-y(i) ; u(i)];
    [teta, P] = RLS(PHI, Y, teta, P, Nv);
    a_est = teta(1);
    b_est = teta(2);
    teta1 = bm/b_est;
    teta2 = (am - a_est)/b_est;
    u(i+1) = teta1 * uc(i+1) - teta2*y(i+1);
    if mod(i, 100) == 0
       P = 1e3 * eye(Nv);   
    end
end
%% plot Results
figure(1);
subplot(211);
plot(t, ym, t,  y, t, e, 'LineWidth', 2);
grid on
legend('Ref', 'Out', 'Error');

subplot(212);
plot(t, u, 'LineWidth', 2);
grid on
legend('Input Signal');

