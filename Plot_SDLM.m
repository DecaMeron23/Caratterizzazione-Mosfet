%% Plot SDLM
% plot solo per valori di Vgs > 0

V_ds = 7;

Vgs_maggiore_0 = id_Vgs(: , 1) > 0;

figure
hold on;
plot(id_Vgs((Vgs_maggiore_0) , 1) , SDLM_derivata_2(Vgs_maggiore_0 , V_ds) , "Color", "blue" , "LineStyle","-.");
plot(id_Vgs(Vgs_maggiore_0 , 1) , SDLM_derivata_2_smooth(Vgs_maggiore_0 , V_ds) , "Color","red");
plot(id_Vgs( SDLM_Indice(V_ds), 1) , SDLM_Min(V_ds), "o" , "Color","black");
hold off;

xlim([0.1 , 0.6])
xlabel("$V_{gs}$" , Interpreter="latex");
ylabel("$\frac{\mathrm{d}^2 \log {I_d}}{(\mathrm{d} V_{gs})^2}$" , Interpreter="latex")
legend("Real" , "Smooth" , "Minimo" , "Location","southeast");
plot_title = "Vds = " + string(Vds(V_ds)) + "mv";
title(plot_title);

clear Vgs_maggiore_0 V_ds plot_title
