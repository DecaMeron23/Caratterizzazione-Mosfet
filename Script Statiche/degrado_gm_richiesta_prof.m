%% Crea il plot della gm all'aumentare del TID a |Vgs|-Vth = 0.4V, sia per gli NMOS sia per i PMOS a tutti i valori di VDS
%% Per far funzionare il codice mettersi nella cartella "Misure Statiche"

warning('off', 'all');
set(0, 'DefaultFigureVisible', 'off')
lista_chip = ["P1","N4"];

% per ogni valore di Vds
for vds = 0.15:0.15:0.9

    % sia per i PMOS sia per i NMOS
    for i = 1:length(lista_chip)
        gm = [];
    
        cd(char(lista_chip(i)));

        % creo la lista dei nomi delle cartelle in cui entrare
        if strcmp(lista_chip(i), "P1")
            chip = "Chip1PMOS";
            dispositivi = ["P1-100-30", "P1-100-60", "P1-200-30", "P1-200-60", "P1-200-180", "P1-600-30", "P1-600-60", "P1-600-180"];
        else 
            chip = "Chip4NMOS";
            dispositivi = ["N4-100-30", "N4-100-60", "N4-100-180", "N4-200-30", "N4-200-60", "N4-200-180","N4-600-60", "N4-600-180"];
        end
        
        lista_irraggiamento = strcat(chip, ["", "_5Mrad", "_50Mrad", "_100Mrad", "_200Mrad", "_600Mrad", "_1Grad", "_3Grad", "_annealing"]);
        
        % per ogni livello di TID
        for j = 1:length(lista_irraggiamento)
            gm_irraggiamento = [];
            cd(lista_irraggiamento(j))

            % predo la tabella con tutte le Vth, tolgo la riga del
            % dispositio rotto e tengo la colonna delle Vth calcolate con
            % il metodo desiderato (SDLM per i PMOS e TCM per i NMOS)
            tabella_vth = readtable("Vth/tabelle/Vth.xls");
            if strcmp(lista_chip(i), "P1")
                tabella_vth(strcmp(tabella_vth.Dispositivi, "100/180"), :) = [];
                vth = tabella_vth.SDLM;
            else 
                tabella_vth(strcmp(tabella_vth.Dispositivi, "600/30"),:) = [];
                vth = tabella_vth.TCM;
            end

            % per ogni dispositivo prendo in consideazione la gm al giusto
            % valore di Vgs
            for k = 1: length(dispositivi)
                gm_irraggiamento = [gm_irraggiamento; gm_dispositivo(dispositivi(k), vth(k)*1e-3, vds)];
            end

            % metto insieme i vattori contenenti i valori di gm di tutti i
            % dispositivi per gni livello di TID
            gm = [gm, gm_irraggiamento];
            cd ..
        end
        salva(gm_percentuale(gm), lista_chip(i), vds);
        cd ..;
    end
end

%% trova il valore di gm in base al valore di Vds e Vgs desiderati
function gm_disp = gm_dispositivo(dispositivo, vth, vds)
    
    cd(dispositivo);

    vgs = -0.3 : 0.005 : 0.9;
    % |Vgs|-Vth = 0.4V --> |Vgs|-Vth - 0.4V = 0
    % creo la matrice che contiene ||Vgs|-Vth - 0.4V| e ne trovo il valore
    % minimo (più vicino a 0)
    delta = abs (vgs - vth - 0.4);
    [~,indice_min] = min(delta);

    % considero la gm al valore di Vgs e Vds desiderati
    tabella_gm = readmatrix("gm.txt");
    gm_disp = tabella_gm(indice_min, 1+vds/0.15);

    cd ..;

end

%% calcola il delta gm % rispetto al valore a TID nullo
function gm_percentuale = gm_percentuale(gm)
    n = size(gm, 1);
    m = size(gm,2);
    gm_percentuale = zeros(size(gm));
    for i = 1 : n
        for j = 2 : m
            gm_percentuale(i,j) = (gm(i,j)/gm(i,1) - 1)*100;
        end
    end
end

%% crea la figura e salva sia i dati sia la figura
function salva(gm_percentuale, chip, vds)
    setUpPlot();
    if strcmp(chip, "P1")
        dispositivi = ["100/0.030", "100/0.060", "200/0.030", "200/0.060", "200/0.180","600/0.030", "600/0.060", "600/0.180"];
        titolo = "$ \Delta g_m \%$ dei PMOS per $|V_{SG}-V_{th}| = 0.4V$ e $V_{SD} =" + vds + "V$";
        nome_file="PMOS_delta_gm_Vgs-Vth=400mV_Vds=" + vds*1e3 + "mV";
    else
        dispositivi = ["100/0.030", "100/0.060", "100/0.180", "200/0.030", "200/0.060", "200/0.180", "600/0.060", "600/0.180"];
        titolo = "$ \Delta g_m \%$ dei NMOS per $|V_{GS}-V_{th}| = 0.4V$ e $V_{DS} =" + vds + "V$";
        nome_file="NMOS_delta_gm_Vgs-Vth=400mV_Vds=" + vds*1e3 + "mV";
    end
    step_irraggiamento = [0.5 5 50 100 200 600 1000 3000 4000];
    figure;
    hold on;
    title(titolo);
    plot(step_irraggiamento, gm_percentuale, Marker="diamond");
    legend(dispositivi,"Location","southwest");
    xticks([0.5 1 10 1e2 1e3 4000]);
    xticklabels({"pre" 1 10 1e2 1e3 "annealing"});
    xlim([0.5 4000])
    ytickformat('percentage')
    set(gca , "XScale" , "log")
    xlabel("$TID[Mrad]$")
    ylabel("$\Delta g_m \%$")
    hold off;

    % salvo i dati e il grafico
    cd Delta_gm_Vgs-Vth=400mV;
    
    nomi_colonne = ["Dispositivo" "Pre-irraggiamento" "5 Mrad" "50 Mrad" "100 Mrad" "200 Mrad" "600 Mrad" "1 Grad" "3 Grad" "Annealing"];
    gm_table = array2table([dispositivi', gm_percentuale] , "VariableNames" , nomi_colonne);

    writetable(gm_table , nome_file+".xls");
    
    cd plot;
    set(gcf, 'Position', [100, 100, 800, 600]);  % Imposta la dimensione della finestra
    saveas(gcf, "Plot_"+nome_file, 'png');
    cd ..\..;

end