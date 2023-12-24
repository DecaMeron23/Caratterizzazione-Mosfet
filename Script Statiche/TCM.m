function vth = TCM(dispositivo , GRADO , PLOT_ON)

    dispositivo = char(dispositivo);

    cd (string(dispositivo))

    tipo = dispositivo(1);
    
    % Nomi dei file contenenti il le Id, al variare di Vds, e Vgs
    file = "id-vgs.txt";
    
     if(exist("id_vgs.txt" , "file"))
        file = "id_vgs.txt";
     end

    %se il file non esiste ritorna una tabella vuota
    if(~exist(file ,"file"))
        vth = 0;
        cd ..;
        return;
    end

     % Carico i file
    id_Vgs_completo = readmatrix(file);
    % file composto da {Vg + (Id , Ig , Is , Iavdd , Igrd) * vd}
    
    % estraggo le Vg (sono uguali per entrambi i file)
    vgs = id_Vgs_completo(: , 1);

    if tipo == 'P'
        %predo le id_vgs per Vsd minima (150mV)
        id = id_Vgs_completo(: , end - 9);
        
        %calcoliamo i valori di Vsg
        vgs = 0.9 - vgs;
    else
        %predo le id_vgs per Vds minima (150mV)
        id = id_Vgs_completo(: , 7);
    end


    gm = gm_gds(id, vgs);
    gm = abs(gm);
    
    
    % Derivata della gm rispetto Vsg
    derivata_TCM = gradient(gm) ./ gradient(vgs);
    % Smooth della derivata
    derivata_TCM = smooth(derivata_TCM , SPAN);
    % indice del valore massimo di di TCM per Vgs <= 700mV (700mV in posizione 201)
    [ ~ , indice_TCM] = max(derivata_TCM(1:201));

    vth_TCM_noFit = vgs(indice_TCM);
            
    
    % Calcolo del massimo della funzione polinomiale che interpola i punti 
    % in un intorno di Vth calcolata con TCM a Vgs = 10 mV e di raggio 100 mV
  
    %prendiamo gli indici dell'intervallo +-100mV con centro Vth
    indici_intervallo = indice_TCM-20 : indice_TCM+20;
    %creaiamo dei valori vsg nell'intervallo calcolato con un
    %incremento di 0.1mV
    intervallo_alta_ris = vgs(indici_intervallo(1)) : 0.0001 : vgs(indici_intervallo(end));
    %Troviamo il valori dei coefficenti della funzione polinomiale 
    coefficienti = polyfit(vgs(indici_intervallo), derivata_TCM(indici_intervallo), GRADO);
    % calcoliamo le y della funzione polinomiale trovata
    grafico = polyval(coefficienti, intervallo_alta_ris);
    % massimo della polinomiale
    [max_grafico, ind_grafico] = max(grafico); 
    % Estraiamo la Vth dalla polinomiale
    vth = intervallo_alta_ris(ind_grafico);    
    % se Vsd = 150mv teniamo gli intervalli per fare il grafico
    % dopo il for


    % Plot di verifica
    if PLOT_ON
        figure
        hold on
        set(gca , "FontSize" , 12)
        titolo = titoloPlot(dispositivo);
        title("TCM - " + titolo , FontSize= 10)
        % plot dati calcolati
        plot(vgs(indici_intervallo),derivata_TCM(indici_intervallo));
        % plot Vth calcolato senza il fit
        xline(vth_TCM_noFit,"--","Color","red");
        % plot della polinomiale
        % plot(intervallo_alta_ris,grafico); 
        % plot Vth calcolata con la polinomiale
        % plot(vth , max_grafico, '*', color="r", MarkerSize=20);

        if tipo == 'P'
            xlabeltxt = "$V_{SG}[V]$";
            ylabeltxt = "$\frac{\mathrm {d} g_m}{\mathrm {d} V_{SG}}[\frac{A}{V^2}]$";
        elseif tipo == 'N'
            xlabeltxt = "$V_{GS}[V]$";
            ylabeltxt = "$\frac{\mathrm {d} g_m}{\mathrm {d} V_{GS}}[\frac{A}{V^2}]$";
        end

        xlabel(xlabeltxt , Interpreter="latex", FontSize=15);
        ylabel(ylabeltxt , Interpreter="latex", FontSize=15);
        legend("TCM","Massimo di TCM","Fit di grado "+ GRADO, "Massimo del fit")
    end

    cd ..;

end