%% Plot TCM

% for i = 5:7;

V_ds = 5;

figure
hold on

plot(id_Vgs(: , 1) , TCM_data(: , V_ds) , "Color","blue");
plot(id_Vgs(: , 1) , TCM_data_smooth(: , V_ds) , "Color","red");
plot(id_Vgs( TCM_Indice(V_ds), 1) , TCM_Max(V_ds), "o", "Color","black" , "LineWidth" , 1);

hold off

ylabel('$\frac{\mathrm{d} g_m}{\mathrm{d} V_{gs}}$' , 'Interpreter' ,'latex');
xlabel("$V_{gs}$" , "Interpreter","latex");
legend("Real" , "Smooth"  , "Punto Massimo", "Location","northwest");
plot_title = "Vds = " + string(Vds(V_ds)) + "mv";
title(plot_title);
xlim([-0.1 , 0.6])
%end