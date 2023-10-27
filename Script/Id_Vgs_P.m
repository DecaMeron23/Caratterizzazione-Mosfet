%Calcolo Delle Vth con i metodo RM , TCM e SDLM

function [vth] = Id_Vgs_P(dispositivo)

    cd (string(dispositivo))
    
    % Tipo del dispositivo
    device_type = dispositivo(1);
    
    % Nomi dei file contenenti il le Id, al variare di Vds, e Vgs
    file = "id-vgs.txt";
    
    % Carico i file  
    id_Vgs_completo = readmatrix(file);
    % file composto da {Vg + (Id , Ig , Is , Iavdd , Igrd) * vd}
    % numero di colonne totali
    NUM_COLONNE_TOT = length(id_Vgs_completo(1, :));
    %seleziono gli indici di colonna contenenti Id (non prendiamo le Vd = 0)
    colonne_vg_id = 2:5:NUM_COLONNE_TOT;
    
    % estraggo le colonne con Id
    id = id_Vgs_completo(: , colonne_vg_id);

    
    % estraggo le Vg (sono uguali per entrambi i file)
    vsg = id_Vgs_completo(: , 1);
    
    
    %specchiamo da sinistra a destra le id
    % cosi abbiamo id a Vd = 900mv, quindi con Vsd = 0mv, come primo valore 
    id = fliplr(id_1());
    id = id(: , 2:end);
    % Valori di Vsd in mV
    vd = 150:150:900;
    %calcoliamo i valori di Vsg
    vsg = 0.9 - vsg;

    plot(vsg,id);


    %% Ratio Method
    
    pos_min = 1;
    while(vsg(pos_min)<0.6)
        pos_min = pos_min+1;
    end
    
    pos_max = pos_min;
    while(vsg(pos_max)<0.9)
        pos_max = pos_max +1;
    end
    
    for i=1:length(vd)
        P = polyfit(vsg(pos_min:pos_max), id(pos_min:pos_max,i), 1);
        vth_RM(i) = -P(2)/P(1);
    end
   

    
    %% Calcoliamo Gm
    
    gm1 = zeros(size(id));
    gm2 = gm1;
    
    for i=1:length(vd)
        gm1(:,i) = gradient(id(:,i))./gradient(vsg);
    end
    
    gm2(1,:) = gm1(1,:);
    
    for i=1:length(vd)
        gm2(2:end,i) = gradient(id(1:end-1,i))./gradient(vsg(2:end));
    end
    
    gm = (gm1+gm2)/2;
    
    for i=1:length(vd)
        gm(:,i) = smooth(gm(:,i));
    end
    
    % figure
    % plot(vg , gm .* 1e3)
    % 
    % % nome assi
    % ylabel('$g_m$ [mS]','interpreter','latex')
    % xlabel('$V_{gs}$ [V]','interpreter','latex')
    % 
    % % titolo del plot
    % title(device_type + " - $g_m$",'interpreter','latex')
    % 
    % % creo la legenda
    % for i = 1: length(vd)
    %     legend_text(i) = "Vds = " + (vd(i))+ " mV"; 
    % end
    % 
    % if device_type == "N"
    %     legend(legend_text,'Location','northwest')
    % else
    %     if device_type == "P"
    %     legend(legend_text,'Location','southwest') 
    %     end
    % end
    
   
    %% Calculate threshold - Transconductance Change Method (TCM)
    %Find the maximum point of the gm derivative
    %valido per basse Vds
    
    % inizializzazione dei dati
    TCM_data = zeros(length(id(:, 1)), length(vd));
    
    
    % se il dispositivo è un P specchiamo verticalmente la gm 
    if(device_type=='P')
        gm = abs(gm);
    end
    
    for i=1:length(vd)
        TCM_data(:,i) = gradient(gm(:,i))./gradient(vsg);
    end
    
    % Smooth della derivata
    for i=1:length(vd)
        TCM_data(: , i) = smooth(TCM_data(: , i));
    end
    
    [TCM_Max, TCM_Indice] = max(TCM_data(1:201,:)); % valore e indice massimo di di TCM per Vgs<=700mV
    
    for i=1:length(vd)
        vth_TCM_noFit(i, 1) = vsg(TCM_Indice(i));
    end
    
    
    %Calcolo del massimo della funzione polinomiale che interpola i punti 
    % in un intorno di Vth calcolata con TCM a Vgs = 10 mV e di raggio 100 mV
    
    grado = 2; % grado della polinomiale
    coefficienti = zeros(length(vd), grado+1);
    
    for i = 1:length(vd)
        indici_intervallo = TCM_Indice(i)-20 : TCM_Indice(i)+20;
        intervallo_alta_ris = vsg(indici_intervallo(1)) : 0.0001 : vsg(indici_intervallo(end));
        coefficienti(i,:) = polyfit(vsg(indici_intervallo), TCM_data(indici_intervallo,i), grado);
        grafico(:,i) = polyval(coefficienti(i,:), intervallo_alta_ris);
        % se Vds = 10mv (i == 1) teniamo gli intervalli per fare il grafico
        % dopo il for
        if(i == 1)
            intervallo_vds_10mv = indici_intervallo;
            intervallo_vds_10mv_alta_ris = intervallo_alta_ris;
        end
    end
    
    %massimo della polinomiale
    [max_grafico, ind_grafico] = max(grafico); 
    
    for i=1:length(vd)
        vth_TCM(i) = intervallo_vds_10mv_alta_ris(ind_grafico(i));
    end
    
    % figure
    % hold on
    % title("TCM - " + dispositivo)
    % plot(vg(intervallo_vds_10mv),TCM_data(intervallo_vds_10mv,1)); %grafico dati
    % xline(vth_TCM_noFit(1),"--","Color","red");  %Vth dati
    % xlabel("$V_{gs}$" , "Interpreter","latex");
    % ylabel("$\frac{\mathrm {d} g_m}{\mathrm {d} V_{gs}}$" , Interpreter="latex");
    % plot(intervallo_vds_10mv_alta_ris,grafico(:, 1)); %grafico polinomiale
    % plot(vth_TCM(1) , max_grafico(1) , "o") %minimo della polinomiale (Vth)
    % legend("SDLM","Massimo di TCM","Fit di grado "+grado, "Massimo del fit")
    
    
    %% Calculate threshold - Second Difference of the Logarithm of the drain current Minimum (SDLM) method
    
    % inizzializzazione parametri
    % vth_SDLM = zeros(length(Vds),1);
    % log_Id_smooth = zeros(size(Id));
    % SDLM_derivata_Smooth = log_Id_smooth;
    % SDLM_derivata_2_smooth = log_Id_smooth;

    span = 20;
    
    %calcoliamo il logaritmo di Id
    log_Id = log(abs(id));
    
    %Eseguiamo lo smooth
    for i=1:length(vd)
        log_Id_smooth(: , i) = smooth(log_Id(: , i),span);
    end
    
    %Deriviamo rispetto Vgs
    for i = 1:length(vd) 
        SDLM_derivata(: , i) = gradient(log_Id_smooth(: , i)) ./ gradient(vsg);
    end
    
    %Eseguiamo lo smooth della derivata
    for i=1:length(vd)
        SDLM_derivata(: , i) = smooth(SDLM_derivata(: , i),span);
    end
    
    %Deriviamo la seconda volta
    for i= 1:length(vd)
        SDLM_derivata_2(: , i) = gradient(SDLM_derivata(:,i)) ./ gradient(vsg);
    end
    
    % per bassi valori di Vgs (da -0.3 a -0.2) sostituiamo i valori 
    spuriousRemoved = [ones(20,length(vd))*200; SDLM_derivata_2(21:end,:)]; 
    
    %Smooth della derivata seconda
    for i=1:length(vd)
        SDLM_derivata_2(:, i) = smooth(spuriousRemoved(:,i),span);
    end
    
    [SDLM_Min, SDLM_Indice] = min(SDLM_derivata_2); % #modifica: SDLM_derivata_2 --> SDLM_derivata_2_smooth
    
    for i=1:length(vd)
        vth_SDLM_noFit(i, 1) = vsg(SDLM_Indice(i));
    end
    
    %Calcolo del minimo della funzione polinomiale che interpola i punti 
    % in un intorno di Vth calcolata con SDLM a Vgs = 900 mV e di raggio 100 mV
    
    grado = 6; % grado della polinomiale
    coefficienti = zeros(length(vd), grado+1);
    
    for i = 1:length(vd)
        indici_intervallo = SDLM_Indice(i)-20 : SDLM_Indice(i)+20;
        intervallo_alta_ris = vsg(indici_intervallo(1)):0.0001:vsg(indici_intervallo(end));
        coefficienti(i,:) = polyfit(vsg(indici_intervallo), SDLM_derivata_2(indici_intervallo,i), grado);
        grafico(:,i) = polyval(coefficienti(i,:), intervallo_alta_ris);
        % se Vds = 900mv (i == length(Vds)) teniamo gli intervalli per fare il grafico
        % dopo il for
        if(i == length(vd))
            indici_intervallo_vds_900mv = indici_intervallo;
            intervallo_vds_900mv_alta_ris = intervallo_alta_ris;
        end
    end
    
    [min_grafico, ind_grafico] = min(grafico); %minimo della polinomiale
    
    for i=1:length(vd)
        vth_SDLM(i) = intervallo_vds_900mv_alta_ris(ind_grafico(i));
    end
    
    % figure
    % hold on
    % title("SDLM - " + dispositivo)
    % xlabel("$V_{gs}$" , "Interpreter","latex");
    % ylabel("$\frac{\mathrm {d}^2 \log{I_d}}{\mathrm {d} V_{gs}^2}$" , Interpreter="latex");
    % plot(vg(indici_intervallo_vds_900mv),SDLM_derivata_2(indici_intervallo_vds_900mv,end)) %grafico dati
    % xline(vth_SDLM_noFit(end),"--","Color","r"); %Vth dati
    % plot(intervallo_vds_900mv_alta_ris, grafico(:, end)); %grafico polinomiale
    % plot(vth_SDLM(end) , min_grafico(end) , "o") %minimo della polinomiale (Vth)
    % legend( "SDLM", "Minimo di SDLM", "Fit di grado "+ grado, "Minimo del fit");
    
    %creo una matrice contenente le Vth calcolate
    vth =  array2table([vd' , round(vth_RM' , 6), round(vth_TCM' , 6) , round(vth_SDLM' , 6)]);

    cd ..
    
end