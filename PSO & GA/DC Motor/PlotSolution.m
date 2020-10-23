function PlotSolution(sol)

    t = sol.Out.t;
    y = sol.Out.y;
    u = sol.Out.u;

    subplot(2,1,1);
    plot(t,y,'LineWidth',2);
    xlabel('t');
    ylabel('y(t)');
    title('Output');
    grid on;
    
    subplot(2,1,2);
    plot(t,u,'r','LineWidth',2);
    xlabel('t');
    ylabel('u(t)');
    title('Control Effort');
    grid on;
    
end