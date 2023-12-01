function vth = TCM_P(dispositivo , GRADO , PLOT_ON)

    cd (string(dispositivo))
    
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
    
    %predo le id_vgs per Vds minima (150mV)
    id = id_Vgs_completo(: , 27);

    
    % estraggo le Vg (sono uguali per entrambi i file)
    vsg = id_Vgs_completo(: , 1);
    
    
    %calcoliamo i valori di Vsg
    vsg = 0.9 - vsg;

    gm = gm_gds(id, vsg);
    gm = abs(gm);
    
    
    % Derivata della gm rispetto Vsg
    derivata_TCM = gradient(gm) ./ gradient(vsg);
    % Smooth della derivata
    derivata_TCM = smooth(derivata_TCM);
    % indice del valore massimo di di TCM per Vgs <= 700mV (700mV in posizione 201)
    [ ~ , indice_TCM] = max(derivata_TCM(1:201));

    vth_TCM_noFit = vsg(indice_TCM);
            
    
    % Calcolo del massimo della funzione polinomiale che interpola i punti 
    % in un intorno di Vth calcolata con TCM a Vgs = 10 mV e di raggio 100 mV
  
    %prendiamo gli indici dell'intervallo +-100mV con centro Vth
    indici_intervallo = indice_TCM-20 : indice_TCM+20;
    %creaiamo dei valori vsg nell'intervallo calcolato con un
    %incremento di 0.1mV
    intervallo_alta_ris = vsg(indici_intervallo(1)) : 0.0001 : vsg(indici_intervallo(end));
    %Troviamo il valori dei coefficenti della funzione polinomiale 
    coefficienti = polyfit(vsg(indici_intervallo), derivata_TCM(indici_intervallo), GRADO);
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
        title("TCM - " + dispositivo)
        % plot dati calcolati
        plot(vsg(indici_intervallo),derivata_TCM(indici_intervallo));
        % plot Vth calcolato senza il fit
        xline(vth_TCM_noFit,"--","Color","red");
        % plot della polinomiale
        plot(intervallo_alta_ris,grafico); 
        % plot Vth calcolata con la polinomiale
        plot(vth , max_grafico, '*', color="r", MarkerSize=20 );

        xlabel("$V_{sg}$" , "Interpreter","latex");
        ylabel("$\frac{\mathrm {d} g_m}{\mathrm {d} V_{sg}}$" , Interpreter="latex");
        legend("TCM","Massimo di TCM","Fit di grado "+ GRADO, "Massimo del fit")
    end

    cd ..;

end