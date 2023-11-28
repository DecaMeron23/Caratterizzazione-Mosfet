%% Plot TCM
% valido per basse Vds

clc;

% richiesta tipo di dati
disp(vds);
valoreVds = input("Valore Di Vds tra quelli sopra indicati (in mV): ");

v_ds = find(vds == valoreVds);

% Verifica se valore Vds è valido

if isempty(v_ds)
    error("Valore di Vds non Valido");
end

figure
hold on

plot(vg, TCM_data(: , v_ds) , "Color","blue");
% plot(vg, TCM_data_smooth(: , v_ds) , "Color","red");
plot(vg(TCM_Indice(v_ds)), TCM_Max(v_ds), "o", "Color","black" , "LineWidth" , 1);

hold off

ylabel('$\frac{\mathrm{d} g_m}{\mathrm{d} V_{gs}}$' , 'Interpreter' ,'latex');
xlabel("$V_{gs}$" , "Interpreter","latex");
legend("Real" , "Smooth"  , "Punto Massimo", "Location","northwest");
plot_title =  device_type + " - Vds = " + string(vds(v_ds)) + "mV";
title(plot_title);
% xlim([-0.1 , 0.6])