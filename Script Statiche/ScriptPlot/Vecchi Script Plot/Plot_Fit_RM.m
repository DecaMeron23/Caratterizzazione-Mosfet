%% Stampa dei fit del metodo RM
% questo script funziona solo dopo aver eseguito fino alla sezione
% Calculate threshold dello script Id_Vgs_Script.m
    
clc

% richiesta tipo di dati
disp(Vds);
valoreVds = input("Valore Di Vds tra quelli sopra indicati (in mV): ");

V_ds = find(Vds == valoreVds);

% Verifica se valoreVds è valido
if isempty(V_ds)
    error("Valore di Vds non Valido");
end

% definizione costanti
SLOPE = 1; 
INTERCEPT = 2;

figure
hold on

%Plot dei dati grezzi
plot(Vg,RM_data(:,V_ds)) 

%creazione e plot del fit lineare
y =  RM_fitLineare(V_ds , INTERCEPT) + RM_fitLineare( V_ds , SLOPE) .* Vg; % creazione fit Lineare
plot(Vg, y);

% plot Vth e assi per migliorare la visualizzazione
plot(vth_RM(V_ds) , 0 , "o"); % Vth
yline(0 , "-."); % y = 0
xline(puntiFit(1) ,"-.");
xline(puntiFit(2) ,"-.");

hold off

% aggiunta nomi assi
ylabel('$\frac{I_d}{\sqrt{g_m}}$','interpreter','latex')
xlabel('$V_{gs}$','interpreter','latex')

% aggiunta della legenda
legend("Real", "Fit"  , "$V_{th}$", "Location", "northwest" , "interpreter" , "latex");

% aggiunta del titolo
plot_title = device_type + " - Vds = " + string(Vds(V_ds)) + "mV";
title(plot_title);

% impostazione limiti plot -> migliora la visualizzazione
if device_type == "P"
    ylim([-0.02, max(RM_data(: , V_ds)) + 0.02]);
    xlim([(min(Vg) -0.1) , vth_RM(V_ds) + 0.2]);
else
    if device_type == "N"
        ylim([-0.02, max(RM_data(: , V_ds)) + 0.02]);
        xlim([vth_RM(V_ds) - 0.2 , max(Vg) + 0.1]);
    end
end

clear y plot_title i V_ds;