function vth = SDLM(dispositivo , GRADO , PLOT_ON)

    cd (string(dispositivo))

    SPAN = 5;

    dispositivo = char(dispositivo);

    tipo = dispositivo(1);
    
    % Nomi dei file contenenti il le Id, al variare di Vds, e Vgs
    file = "id-vgs.txt";
    
     if exist("id_vgs.txt" , "file")
        file = "id_vgs.txt";
     end

    %se il file non esiste ritorna una tabella vuota
    if ~exist(file ,"file")
        vth = 0;
        cd ..;
        return;
    end

     % Carico i file
    id_Vgs_completo = readmatrix(file);

    % estraggo le Vg (sono uguali per entrambi i tipi)
    vgs = id_Vgs_completo(: , 1);

    if tipo == 'P'
    
        %predo le id_vsg per Vsd massima (900mV)
        id = id_Vgs_completo(:,2);        
        
        %calcoliamo i valori di Vsg
        vgs = 0.9 - vgs;
    elseif tipo == 'N'
        id = id_Vgs_completo(:, end - 4);
    end

    
    %calcoliamo il logaritmo di Id
    log_Id = log(abs(id));
    
    %Eseguiamo lo smooth
    log_Id = smooth(log_Id);
    %Deriviamo log(id) rispetto Vsg
    derivata_SDLM = gradient(log_Id) ./ gradient(vgs);
    %Eseguiamo lo smooth della derivata
    derivata_SDLM = smooth(derivata_SDLM , SPAN);
    %Deriviamo la seconda volta
    derivata_2_SDLM = gradient(derivata_SDLM) ./ gradient(vgs);
    % per bassi valori di Vsg (da -0.3 a -0.2) sostituiamo i valori ponendoli a 200 
    derivata_2_SDLM = [ones(20, 1)*200; derivata_2_SDLM(21:end)];
    %Smooth della derivata seconda
    derivata_2_SDLM = smooth(derivata_2_SDLM , SPAN);
    % prendiamo l'indice del minimo valore della derivata seconda
    [ ~ , SDLM_Indice] = min(derivata_2_SDLM(1 : 180));
    % estraiamo la Vth
    vth_SDLM_noFit = vgs(SDLM_Indice);
    
    %Calcolo del minimo della funzione polinomiale che interpola i punti 
    % in un intorno di Vth calcolata con SDLM a Vgs = 900 mV e di raggio 100 mV


    %prendiamo gli indici dell'intervallo +-100mV con centro Vth
    indici_intervallo = SDLM_Indice-20 : SDLM_Indice+20;
    %creaiamo dei valori vsg nell'intervallo calcolato con un
    %incremento di 0.1mV
    intervallo_alta_ris = vgs(indici_intervallo(1)) : 0.0001 : vgs(indici_intervallo(end));
    %Troviamo il valori dei coefficenti della funzione polinomiale 
    coefficienti = polyfit(vgs(indici_intervallo), derivata_2_SDLM(indici_intervallo), GRADO);
    %calcoliamo le y della funzione polinomiale trovata
    grafico = polyval(coefficienti, intervallo_alta_ris);
    %estraiamo il minimo della polinomiale
    [min_grafico, ind_grafico] = min(grafico);
    %estraiamo il valore della Vth dalla polinomiale
    vth = intervallo_alta_ris(ind_grafico);
  
    
    %Plot di verifica
    if PLOT_ON
        figure
        hold on
        set(gca , "FontSize" , 12)
        titolo = titoloPlot(dispositivo);
        title("SDLM - " + titolo , FontSize=10);
        
         if tipo == 'P'
            xlabeltxt = "$V_{SG}[V]$";
            ylabeltxt = "$\frac{\mathrm {d}^2 \log{I_d}}{\mathrm {d} V_{SG}^2}[\frac{A}{V^2}]$";
         elseif tipo == 'N'
            xlabeltxt = "$V_{GS}[V]$";
            ylabeltxt = "$\frac{\mathrm {d}^2 \log{I_d}}{\mathrm {d} V_{GS}^2}[\frac{A}{V^2}]$";
        end

        xlabel(xlabeltxt , "Interpreter","latex", "FontSize",15);
        ylabel(ylabeltxt , "Interpreter", "latex", "FontSize", 15);
        %Plot dei dati calcolati
        plot(vgs(indici_intervallo),derivata_2_SDLM(indici_intervallo))
        %plot della vth dei dati calcolati
        xline(vth_SDLM_noFit,"--","Color","r");
        %plot della polinomiale
        plot(intervallo_alta_ris, grafico);
        %plot vth della polinomiale
        plot(vth , min_grafico , "*", color="r", MarkerSize=20)
        legend( "SDLM", "Minimo di SDLM", "Fit di grado "+ GRADO, "Minimo del fit");
        hold off
    end

    cd ..;

end