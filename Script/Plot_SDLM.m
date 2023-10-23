%% Plot SDLM

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
hold on;

% plot dati grezzi
plot(Vg, SDLM_derivata_2(:, V_ds) , "Color", "blue" , "LineStyle","-.");

%plot dati smooth
plot(Vg , SDLM_derivata_2_smooth( : , V_ds) , "Color","red");

% plot Vth
plot(Vg(SDLM_Indice(V_ds)) , SDLM_Min(V_ds), "o" , "Color","black");
hold off;

% aggiunta nomi assi
xlabel("$V_{gs}$" , Interpreter="latex");
ylabel("$\frac{\mathrm{d}^2 \log {I_d}}{(\mathrm{d} V_{gs})^2}$" , Interpreter="latex")

%aggiunta della legenda
legend("Real" , "Smooth" , "Minimo" , "Location","northeast");

% aggiunta del titolo
plot_title = device_type + " - Vds = " + string(Vds(V_ds)) + "mv";
title(plot_title);

% impostazione limiti plot -> migliora la visualizzazione
if device_type == "P"
    ylim([min(SDLM_derivata_2(: , V_ds)) - 10 , max(SDLM_derivata_2_smooth(: , V_ds)) + 10]);
    xlim([0 , vth_SDLM(V_ds) + 0.2]);
else
    if device_type == "N"
        ylim([min(SDLM_derivata_2(: , V_ds)) - 10 , max(SDLM_derivata_2_smooth(: , V_ds)) + 10]);
        xlim([vth_RM(V_ds) - 0.2 , max(Vg) + 0.1]);
    end
end

clear Vgs_maggiore_0 V_ds plot_title;
