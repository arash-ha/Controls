clc;
close all;
clear;
%%
L = 0.4125;
Rl = 10;
Rs = 1;
Kf = 32654e-9;
g = 9.81;
m = 0.068;
Ts = 0.01;
Tf = 100;
f = @(x , v) [-(Rl + Rs)/L * x(1) + v/L ; x(3) ; g - Kf/m*(x(1)/x(2))^2];
t = 0:Ts:Tf;
%% Feedback Gains
Yss =  15:10:45;
Yss = Yss/1000;
K = zeros(numel(Yss), 3);
for i = 1:numel(Yss)
    Iss = Yss(i) * sqrt(m*g/Kf);
    Vss = Iss * (Rl + Rs);
    Xss = [Iss; Yss(i); 0];
    A = [-(Rl + Rs)/L   0     0
        0         0           1
        -2*Kf/m*Iss/Yss(i)^2    2*Kf/m*Iss^2/Yss(i)^3     0 ];
    B = [1/L  0    0]';
    Q = eye(3);
    R = 1;
    N = 0;
    K(i , :) = lqr(A, B, Q, R, N);
end
%%
Yref = 10*gensig('sin', 20, Tf, Ts) + 25;
Yref = Yref/1000;
u = zeros(size(t));
y = zeros(size(t));
V = zeros(size(t));
X = zeros(3, size(t,2));
X(:, 1) = [0; 20e-3; 0];
for i = 1: numel(t)-1
    % dot x = f(x , v)
    X(:, i+1) = X(:, i) + Ts * f(X(: ,i), V(i));
    y(i+1) = X(2, i+1);
    if  Yref(i+1) > 10e-3 && Yref(i+1) < 20e-3
        Klqr = K(1, :);
    elseif Yref(i+1) > 20e-3 && Yref(i+1) < 30e-3
        Klqr = K(2, :);
    elseif  Yref(i+1) > 30e-3 && Yref(i+1)< 40e-3
        Klqr = K(3, :);
    elseif Yref(i+1) > 40e-3 && Yref(i+1) < 50e-3
        Klqr = K(4, :);
    end
    Iss = Yref(i+1) * sqrt(m*g/Kf);
    x = X(:, i+1) - [Iss; Yref(i+1); 0];
    v = -Klqr * x;
    Vss = (Rl + Rs) * Iss; 
    V(i+1) = Vss +  v;
end
%% plot Results
figure(1);
subplot(211);
plot(t, Yref*1000,  t,  y*1000,  t, 1000*(y'- Yref),  'LineWidth', 2);
grid on
legend('Ref', 'Out', 'Error');
xlabel('Time (Sec)');
ylabel('Pos   (mm)');
subplot(212);
plot(t, V, 'LineWidth', 2);
grid on
legend('Input Signal');
