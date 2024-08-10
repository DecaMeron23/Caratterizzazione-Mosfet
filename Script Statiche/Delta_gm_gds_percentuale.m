classdef Delta_gm_gds_percentuale
    %Classe che prevede i metodi pre effettuare i calcoli della delta
    %gm/gds percentuale

    methods (Static)
        
    function  delta_gds_percentuale()

        [cartelle]= estrazioneCartelle.getCartelle();
    
    
        grado = [0 5 50 100 200 600 1000 3000 "annealing"];
        valori_vgs = [0.15 , 0.30 , 0.45 , 0.6 , 0.75 , 0.9];
        nomi_dispositivi = ["100-30" , "100-60" , "100-180" , "200-30" , "200-60", "200-180" , "600-30" , "600-60" , "600-180"];
    
        for k = 1:length(nomi_dispositivi)
            dispositivo = nomi_dispositivi(k);
            disp("Dispositivo = "+ dispositivo);
            delta = zeros(6 , 7);
            for i = 1: length(cartelle)
                if grado(i) == "annealing"
                    print = grado(i);
                else
                    print = grado(i) +  "Mrad";
                end
    
                disp("      Grado = " + print);
    
                cd(string(cartelle(i)));
                cartella_dispositivo = estrazioneCartelle.getFileCartella(dispositivo);
        
                try
                    cd(string(cartella_dispositivo(1)));
                    
                    file = "gds.txt";
            
                    gds = readmatrix(file);
                    %togliamo la vgs
                    gds = gds(: , 2:end);
            
                    %Per ogni valore di vgs
                    for j = 1 : length(valori_vgs)
                        %selezioniamo la vgs, troviamo l'indice di vgs
                        disp("              Vgs = " + valori_vgs(j) + "V");
                        indice_vgs = (valori_vgs - valori_vgs(j)) == 0;
                        gds_i = gds(: , indice_vgs);
                        % prendiamo la massima gm
                        gds_max = max(gds_i);
                
                        % se stiamo guardando i dati pre irraggiamento lo prendiamo come riferimento
                        if(i == 1)
                            gds_pre(j) = gds_max;
                            delta( j , 1) = 0;
                        else
                            delta(j , i) = (gds_max - gds_pre(j))*100/gds_pre(j);
                        end
            
                    end
                catch e
                    
                    %Se non esiste il dispositivo
                    warning("Dispositivo: '" + dispositivo + "' non trovato")
                    delta(: ,i) = zeros(length(valori_vgs) , 1);
                end
                cd ..\..
            end
            
            % creaimo la tabella
            %entriamo nella cartella DeltaGm
            if(~exist("DeltaGds", "dir"))
                mkdir("DeltaGds\");
            end
            cd DeltaGds;
            %componiamo la matrice da salvare
            
            matrice =  horzcat(valori_vgs' , delta);
            valori = cellstr(["Vgs" , (grado(1:end-1) + "Mrad") , grado(end)]); 
            matrice = array2table(matrice);
            matrice.Properties.VariableNames = valori;
            writetable(matrice , "Delta_ds_" + dispositivo+ ".xls");
    
            cd ..
        end
    end

    function  delta_gm_percentuale()
    
        cartelle = estrazioneCartelle.getCartelle();
    
        grado = [0 5 50 100 200 600 1000 3000 "annealing"];
        valori_vds = [0.15 , 0.30 , 0.45 , 0.6 , 0.75 , 0.9];
        nomi_dispositivi = ["100-30" , "100-60" , "100-180" , "200-30" , "200-60", "200-180" , "600-30" , "600-60" , "600-180"];
    
        for k = 1:length(nomi_dispositivi)
            dispositivo = nomi_dispositivi(k);
            disp("Dispositivo = "+ dispositivo);
            delta = zeros(6 , 7);
            for i = 1: length(cartelle)
                if grado(i) == "annealing"
                    print = grado(i);
                else
                    print = grado(i) +  "Mrad";
                end
                disp("      Grado = " + print);
                cd(string(cartelle(i)));
                cartella_dispositivo = estrazioneCartelle.getFileCartella(dispositivo);
        
                try
                    cd(string(cartella_dispositivo(1)));
                    
    
                    file = "gm.txt";
            
                    gm = readmatrix(file);
                    %togliamo la vgs
                    gm = gm(: , 2:end);
            
                    %Per ogni valore di vds
                    for j = 1 : length(valori_vds)
                        %selezioniamo la vds, troviamo l'indice di vds
                        disp("              Vds = " + valori_vds(j) + "V");
                        indice_vds = (valori_vds - valori_vds(j)) == 0;
                        gm_i = gm(: , indice_vds);
                        gm_max = max(gm_i);
                
                        % se stiamo guardando i dati pre irraggiamento lo prendiamo come riferimento
                        if(i == 1)
                            gm_pre(j , 1) = gm_max;
                            delta( j , 1) = 0;
                        else
                            delta(j , i) = (gm_max - gm_pre(j,1))*100/gm_pre(j,1);
                        end
            
                    end
                
                catch e
                    
                    %Se non esiste il dispositivo
                    warning("Dispositivo: '" + dispositivo + "' non trovato")
                    delta(: ,i) = zeros(length(valori_vds) , 1);
                end
                cd ..\..
            end
            
            % creaimo la tabella
            %entriamo nella cartella DeltaGm
            if(~exist("DeltaGm", "dir"))
                mkdir("DeltaGm\");
            end
            cd DeltaGm;
            %componiamo la matrice da salvare
            
            matrice =  horzcat(valori_vds' , delta);
            valori = cellstr(["Vds" , (grado(1:end-1) + "Mrad") , grado(end)]);        
            matrice = array2table(matrice);
            matrice.Properties.VariableNames = valori;
            writetable(matrice , "Delta_gm_" + dispositivo+ ".xls");
            cd ..
        end
    end

    function plot_delta_gds_W_tutti()
        
        close all

        ARRAY_W = [100 200 600];
        ARRAY_VGS_mV = 150:150:900;

        for W = ARRAY_W
            for Vgs_mV = ARRAY_VGS_mV
                Delta_gm_gds_percentuale.plot_delta_gds_W_Vgs(W , Vgs_mV)
            end
            close all
        end

    end


    %Funione che esegue il plot per la singola Vgs per tutti i dispositivi
    %con la stess W
    function plot_delta_gds_W_Vgs(W , Vgs_mV)
        setUpPlot();

        %Definisco le costatni
        ARRAY_VGS_mV = 150:150:900;
        ARRAY_L = [30 60 180];
        
        PREFISSO_NOME_FILE = "Delta_ds_"  + W + "-";
        
        CARTELLA_PLOT = "plot\Vgs" + Vgs_mV + "mV";
        
        COLORI = lines(3);
        X = [0 5 50 100 200 600 1000 3000 3500];
        X_TICK = [0 500 1000 1500 2000 2500 3000 3500];
        X_TICK_LABEL = {0 500 1000 1500 2000 2500 3000 "annealing"};
        X_LIMITE = [0 3500];

        Y_LABEL = "$\Delta g_{ds} \% [A/V]$";
        X_LABEL = "$\textit{TID} [Mrad]$";

        DISPLAY_LEGEND = "$L = %d nm$";

        ANNOTATION = "$W = "+W +"\mu m$" + sprintf("\n$|V_{GS}| = %.2f V$" , Vgs_mV/1000);

        %recuperiamo il tipo del dispositivo
        temp = split(pwd , "\");
        temp = char(temp(end-1));
        
        type = temp(1);

        inidce_riga = find(ARRAY_VGS_mV == Vgs_mV) ;
        if isempty(inidce_riga)
            error("Vgs non trovata:" + Vgs_mV);
        end
        
        figure

        for i = 1:length(ARRAY_L)
            L = ARRAY_L(i);

            if type == "P"
                if W == 100 && L == 180
                    continue
                end
            elseif type == "N"
                if W == 600 && L == 30
                    continue
                end
            end

            nome_file = PREFISSO_NOME_FILE + L +".xls";

            temp = readmatrix(nome_file);
            delta_gds = temp( inidce_riga , 2:end);
            
            plot(X , delta_gds , "DisplayName", sprintf(DISPLAY_LEGEND , L) , "Color", COLORI(i , :) , "LineStyle", "-" , "Marker" , "square");
            hold on
        end


        xlim(X_LIMITE);
        ytickformat('percentage');
        
        set(gca , "XTick" , X_TICK);
        set(gca , "XTickLabel" , X_TICK_LABEL);

        yline(0 , "LineStyle", "--" , 'HandleVisibility', 'off')

        annotation("textbox" , [0.2 0.1 0.25 0.25] , "String", ANNOTATION , "Interpreter","latex" , "EdgeColor", "none" , FontSize=12);

        ylabel(Y_LABEL , FontSize=12);
        xlabel(X_LABEL, FontSize=12);

        legend("Interpreter", "latex" , "FontSize", 12);

        grid on
        
        if ~exist(CARTELLA_PLOT , "dir")
            mkdir(CARTELLA_PLOT)
        end

        cd(CARTELLA_PLOT);

        nome_plot = sprintf("Delta_gds_type_%s_W_%d_Vgs_%d_mV.png" , type , W , Vgs_mV);

        saveas(gcf , nome_plot);
            
        cd ..\..

    end


    end
end