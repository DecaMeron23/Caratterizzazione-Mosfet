%Calcolo Delle Vth con i metodo RM , TCM e SDLM

function [vth] = Id_Vgs_P(dispositivo , SPAN , GRADO , PLOT_ON)
    
   cd (string(dispositivo))
   
    if (~exist("fig" , "dir"))
        mkdir fig;
    end

    % Nomi dei file contenenti il le Id, al variare di Vds, e Vgs
    file = "id-vgs.txt";
    
     if(exist("id_vgs.txt" , "file"))
        file = "id_vgs.txt";
     end

    %se il file non esiste ritorna una tabella vuota
    if(~exist(file ,"file"))
        vth = array2table([0 0 0 0]);
        cd ..;
        return;
    end

    % Carico i file
    id_Vgs_completo = readmatrix(file);
    % file composto da {Vg + (Id , Ig , Is , Iavdd , Igrd) * vd}
    % numero di colonne totali
    NUM_COLONNE_TOT = length(id_Vgs_completo(1, :));
    %seleziono gli indici di colonna contenenti Id
    colonne_vg_id = 2:5:NUM_COLONNE_TOT;
    
    % estraggo le colonne con Id
    id = id_Vgs_completo(: , colonne_vg_id);

    
    % estraggo le Vg (sono uguali per entrambi i file)
    vsg = id_Vgs_completo(: , 1);
    
    
    %specchiamo da sinistra a destra le id cosi abbiamo id a Vd = 900mv, quindi con Vsd = 0mv, come primo valore 
    id = fliplr(id());
    %togliamo Vsd = 0mV
    id = id(: , 2:end);
    % Valori di Vsd in mV
    vsd = 150:150:900;
    %calcoliamo i valori di Vsg
    vsg = 0.9 - vsg;
    
    % Plot di verifica
    if PLOT_ON
        figure
        set(gca , "FontSize" , 12)
        plot(vsg,id);
        title("Vsg - Id - " + dispositivo , FontSize=10);
        xlabel("$V_{sg}$" , Interpreter="latex" , FontSize=15);
        ylabel("$I_{d}$" , Interpreter="latex" , FontSize=15);

    end

    %% Fit lineare di Id-Vsg tra i punti 0.5 e 0.6
    
    % ricerca del punto con vsg = 0.5V
    pos_min = 1;
    while(vsg(pos_min) < 0.5)
        pos_min = pos_min+1;
    end

    % ricerca del punto con vsg = 0.6V
    pos_max = pos_min;
    while(vsg(pos_max) < 0.6)
        pos_max = pos_max +1;
    end
  
    %calcolo dei coefficenti
    for i=1:length(vsd)
        P = polyfit(vsg(pos_min:pos_max), id(pos_min:pos_max, i ), 1);
        vth_Lin_Fit(i) = -P(2)/P(1);

        %plot di verifica del fit a Vsd = 150mV
        %if PLOT_ON
            if vsd(i) == 150
                val = polyval(P , [0 , 0.9]);
                figure
                set(gca , "FontSize" , 12)
                hold on
                plot(vsg , id(: , i))
                plot([0 , 0.9] , val)
                title("Fit lineare - " + dispositivo , FontSize=10);
                xlim([0 , 0.7])
                xline(0.5 , "--")
                xline(0.6 , "--")
                yline(0 , "-.");
                xline(vth_Lin_Fit(i) , "--");
                xlabel("$V_{sg} [V]$" , "Interpreter","latex" , FontSize=15);
                ylabel("$I_D [A]$" , Interpreter="latex" , FontSize=15);
                legend( "$I_D$", "linear fit", Interpreter = "latex");
                hold off
                
                cd fig\
                saveas(gca , "FIT")
                cd ..
                
                if(PLOT_ON == 0)
                    close all;
                end
            end
        %end
    end

    %% Calcoliamo Gm
    
    % inizializzazione matrici
    gm1 = zeros(size(id));
    gm2 = gm1;
    
    for i=1:length(vsd)
        gm1(:,i) = gradient(id(:,i)) ./ gradient(vsg);
    end
    
    gm2(1,:) = gm1(1,:);
    
    for i=1:length(vsd)
        gm2(2:end,i) = gradient(id(1:end-1,i))./gradient(vsg(2:end));
    end
    
    gm = (gm1+gm2)/2;
    
    for i=1:length(vsd)
        gm(:,i) = smooth(gm(:,i));
    end
    
    %Plot di verifica
    if PLOT_ON
        figure
        set(gca , "FontSize" , 12)
        plot(vsg , gm .* 1e3)
        % nome assi
        ylabel('$g_m$ [mS]','interpreter','latex' , FontSize=15)
        xlabel('$V_{sg}$ [V]','interpreter','latex' , FontSize=15)
        title("gm - " + dispositivo , FontSize=10)
    end
    %% Calculate threshold - Transconductance Change Method (TCM)
    %Find the maximum point of the gm derivative
    %valido per basse Vds
    
    % inizializzazione dei dati
    derivata_TCM = zeros(size(id));
    
    % prendiamo il valore assoluto di gm
    gm = abs(gm);
    
    for i=1:length(vsd)
        % Derivata della gm rispetto Vsg
        derivata_TCM(:,i) = gradient(gm(:,i)) ./ gradient(vsg);
        % Smooth della derivata
        derivata_TCM(: , i) = smooth(derivata_TCM(: , i));
        % indice del valore massimo di di TCM per Vgs <= 700mV (700mV in posizione 201)
        [ ~ , indice_TCM(i)] = max(derivata_TCM(1:201,i));
        % estraiamo la vth
        vth_TCM_noFit(i, 1) = vsg(indice_TCM(i));
    end

            
    
    % Calcolo del massimo della funzione polinomiale che interpola i punti 
    % in un intorno di Vth calcolata con TCM a Vgs = 10 mV e di raggio 100 mV
    % for GRADO = 2:2:8
    coefficienti = zeros(length(vsd), GRADO + 1);

    for i = 1:length(vsd)
        %prendiamo gli indici dell'intervallo +-100mV con centro Vth
        indici_intervallo = indice_TCM(i)-20 : indice_TCM(i)+20;
        %creaiamo dei valori vsg nell'intervallo calcolato con un
        %incremento di 0.1mV
        intervallo_alta_ris = vsg(indici_intervallo(1)) : 0.0001 : vsg(indici_intervallo(end));
        %Troviamo il valori dei coefficenti della funzione polinomiale 
        coefficienti(i,:) = polyfit(vsg(indici_intervallo), derivata_TCM(indici_intervallo, i), GRADO);
        % calcoliamo le y della funzione polinomiale trovata
        grafico(:,i) = polyval(coefficienti(i,:), intervallo_alta_ris);
        % massimo della polinomiale
        [max_grafico(i), ind_grafico(i)] = max(grafico(: , i)); 
        % Estraiamo la Vth dalla polinomiale
        vth_TCM(i) = intervallo_alta_ris(ind_grafico(i));    
        % se Vsd = 150mv teniamo gli intervalli per fare il grafico
        % dopo il for
        if vsd(i) == 150 
            intervallo_vds_150mv = indici_intervallo;
            intervallo_vds_150mv_alta_ris = intervallo_alta_ris;
        end
     end

    % Plot di verifica
    % if PLOT_ON
        figure
        set(gca , "FontSize" , 12)
        hold on
        title("TCM - " + dispositivo , FontSize=10)
        % plot dati calcolati
        plot(vsg(intervallo_vds_150mv),derivata_TCM(intervallo_vds_150mv,1));
        % plot Vth calcolato senza il fit
        xline(vth_TCM_noFit(1),"--","Color","red");
        % plot della polinomiale
        plot(intervallo_vds_150mv_alta_ris,grafico(:, 1)); 
        % plot Vth calcolata con la polinomiale
        plot(vth_TCM(1) , max_grafico(1) , "*", color="r", MarkerSize=20);

        xlabel("$V_{SG} [V]$" , Interpreter="latex", FontSize = 15);
        ylabel("$\frac{\mathrm {d} g_m}{\mathrm {d} V_{SG}}$" , Interpreter="latex", FontSize = 15);
        legend("TCM","Massimo di TCM","Fit di grado "+ GRADO, "Massimo del fit")

        cd fig\
        saveas(gca , "TCM")
        cd ..
            
        if(PLOT_ON == 0)
            close all;
        end
    % end

    clear grafico;

    %end
    
    %% Calculate threshold - Second Difference of the Logarithm of the drain current Minimum (SDLM) method
    
    %calcoliamo il logaritmo di Id
    log_Id = log(abs(id));
    
    
    for i=1:length(vsd)
        %Eseguiamo lo smooth
        log_Id_smooth(: , i) = smooth(log_Id(: , i),SPAN);
        %Deriviamo log(id) rispetto Vsg
        derivata_SDLM(: , i) = gradient(log_Id_smooth(: , i)) ./ gradient(vsg);
        %Eseguiamo lo smooth della derivata
        derivata_SDLM(: , i) = smooth(derivata_SDLM(: , i),SPAN);
        %Deriviamo la seconda volta
        derivata_2_SDLM(: , i) = gradient(derivata_SDLM(:,i)) ./ gradient(vsg);
        % per bassi valori di Vsg (da -0.3 a -0.2) sostituiamo i valori ponendoli a 200 
        derivata_2_SDLM(: , i ) = [ones(20, 1)*200; derivata_2_SDLM(21:end,i)];
        %Smooth della derivata seconda
        derivata_2_SDLM(:, i) = smooth(derivata_2_SDLM(:,i),SPAN);
        % prendiamo l'indice del minimo valore della derivataseconda
        [ ~ , SDLM_Indice(i)] = min(derivata_2_SDLM(1 : 180, i));
        % estraiamo la Vth
        vth_SDLM_noFit(i, 1) = vsg(SDLM_Indice(i));
    end
    
    %Calcolo del minimo della funzione polinomiale che interpola i punti 
    % in un intorno di Vth calcolata con SDLM a Vgs = 900 mV e di raggio 100 mV
    

    coefficienti = zeros(length(vsd), GRADO+1);

    for i = 1:length(vsd)
        %prendiamo gli indici dell'intervallo +-100mV con centro Vth
        indici_intervallo = SDLM_Indice(i)-20 : SDLM_Indice(i)+20;
        %creaiamo dei valori vsg nell'intervallo calcolato con un
        %incremento di 0.1mV
        intervallo_alta_ris = vsg(indici_intervallo(1)) : 0.0001 : vsg(indici_intervallo(end));
        if length(intervallo_alta_ris) == 2000
            intervallo_alta_ris = [intervallo_alta_ris (intervallo_alta_ris(end)+0.0001)];
        end
        %Troviamo il valori dei coefficenti della funzione polinomiale 
        coefficienti(i,:) = polyfit(vsg(indici_intervallo), derivata_2_SDLM(indici_intervallo,i), GRADO);
        %calcoliamo le y della funzione polinomiale trovata
        grafico(:,i) = polyval(coefficienti(i,:), intervallo_alta_ris);
        %estraiamo il minimo della polinomiale
        [min_grafico(i), ind_grafico(i)] = min(grafico(: ,i));
        %estraiamo il valore della Vth dalla polinomiale
        vth_SDLM(i) = intervallo_alta_ris(ind_grafico(i));
        %se Vsd = 900mv teniamo gli intervalli per fare il grafico
        %dopo il for
        if vsd(i) == 900
            indici_intervallo_vsd_900mv = indici_intervallo;
            intervallo_vsd_900mv_alta_ris = intervallo_alta_ris;
        end
    end

    %Plot di verifica
    % if PLOT_ON
        figure
        set(gca , "FontSize" , 12)
        hold on
        title("SDLM - " + dispositivo , FontSize=10)
        xlabel("$V_{SG}[V]$" , "Interpreter","latex", "FontSize",15);
        ylabel("$\frac{\mathrm {d}^2 \log{I_d}}{\mathrm {d} V_{SG}^2}[\frac{A}{V^2}]$" , "Interpreter", "latex", "FontSize", 15);
        %Plot dei dati calcolati
        plot(vsg(indici_intervallo_vsd_900mv),derivata_2_SDLM(indici_intervallo_vsd_900mv , end))
        %plot della vth dei dati calcolati
        xline(vth_SDLM_noFit(end),"--","Color","r");
        %plot della polinomiale
        plot(intervallo_vsd_900mv_alta_ris, grafico(:, end));
        %plot vth della polinomiale
        plot(vth_SDLM(end) , min_grafico(end) , "*", color="r", MarkerSize=20)
        legend( "SDLM", "Minimo di SDLM", "Fit di grado "+ GRADO, "Minimo del fit");
        hold off

        cd fig\
        saveas(gca , "SDLM")
        cd ..
        
        if(PLOT_ON == 0)
            close all;
        end

    % end
    
    %% Creazione tabella contenente le Vth calcolate in base alle Vsd
    vth =  array2table([vsd' , round(vth_Lin_Fit' , 6), round(vth_TCM' , 6) , round(vth_SDLM' , 6)]);

    cd ..
end