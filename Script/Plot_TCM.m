%% Plot TCM
% valido per basse Vds

clc;

% richiesta tipo di dati
disp(Vds);
valoreVds = input("Valore Di Vds tra quelli sopra indicati (in mV): ");

V_ds = find(Vds == valoreVds);

% Verifica se valoreVds è valido

if isempty(V_ds)
    error("Valore di Vds non Valido");
end

figure
hold on

plot(Vg, TCM_data(: , V_ds) , "Color","blue" , LineStyle="-.");
plot(Vg, TCM_data_smooth(: , V_ds) , "Color","red");
plot(Vg(TCM_Indice(V_ds)), TCM_Max(V_ds), "o", "Color","black" , "LineWidth" , 1);

hold off

ylabel('$\frac{\mathrm{d} g_m}{\mathrm{d} V_{gs}}$' , 'Interpreter' ,'latex');
xlabel("$V_{gs}$" , "Interpreter","latex");
legend("Real" , "Smooth"  , "Punto Massimo", "Location","northwest");
plot_title =  device_type + " - Vds = " + string(Vds(V_ds)) + "mV";
title(plot_title);
% xlim([-0.1 , 0.6])