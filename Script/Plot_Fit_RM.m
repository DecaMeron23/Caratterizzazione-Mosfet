%% Stampa dei fit del metodo RM

% definizione costanti
SLOPE = 1; 
INTERCEPT = 2;

V_ds = 5; % indica per quale V_ds stampare il real vs fit

figure
hold on
plot(Vg,RM_data(:,V_ds)) %Plot dei dati grezzi

y =  RM_fitLineare(V_ds , INTERCEPT) + RM_fitLineare( V_ds , SLOPE) .* Vg; % creazione fit Lineare
plot(Vg, y); %plot del fit lineara

plot(vth_RM(V_ds) , 0 , "o"); % Vth
yline(0 , "-."); % y = 0
xline(0.6 ,"-."); % x = 0.6
xline(0.9 ,"-."); % x = 0.9

hold off

ylabel('$\frac{I_d}{\sqrt{g_m}}$','interpreter','latex')
xlabel('$V_{gs}$','interpreter','latex')
legend("Real", "Fit"  , "$V_{th}$", "Location","northwest" , "interpreter" , "latex");
plot_title = "Vds = " + string(Vds(V_ds)) + "v";
title(plot_title);
ylim([-0.02, max(y)]);
xlim([0 , 1]);

clear y plot_title i V_ds;