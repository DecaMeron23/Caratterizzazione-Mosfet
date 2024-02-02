function vth = RM(dispositivo , PLOT_ON)

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
        vgs = 0.9 - vgs(:);
    else
        %predo le id_vgs per Vds minima (150mV)
        id = id_Vgs_completo(: , 7);
    end

    gm = abs(gm_gds(id, vgs));
    rm_data = id./sqrt(gm);

    %settiamo l'R^2 migliore a 0
    R_migliore = 0;

    % per colpa di chi ha inventato i floatingpoint 0.3 non è uguale a
    % 0.3 e devo scrivere più codice...
    [~, indice1] = min(abs(vgs - 0.1));
    [~, indice2] = min(abs(vgs - (0.75)));
    % dalla posizione in cui è a 0.3V fino a (0.9-0.15)V
    for i = indice1:indice2
    
        % prendiamo l'intervallo
        x = vgs(i : i+30);
        y = rm_data(i : i+30);

        modello_Fit = fitlm(x , y);
        
        R_attuale = modello_Fit.Rsquared.Ordinary;
        
        % se questo fit è migliore lo salviamo
        if(R_attuale > R_migliore)
            R_migliore = R_attuale;
            modello_migliore = modello_Fit;
            intervallo = [vgs(i) , vgs(i+30)];
        end
    end

    disp(dispositivo + " coefficente R^2 migliore è: "+ R_migliore);

    % troviamo la vth
    coefficenti = modello_migliore.Coefficients.Estimate;
    
    vth = -coefficenti(1) / coefficenti(2);   
    
    x_new = [vth-0.2 , 0.9];
    y_fit = predict(modello_migliore , x_new');
    figure
    set(gca , "FontSize" , 12)
    titolo = titoloPlot(dispositivo);
    hold on
    plot(vgs , rm_data)
    plot(x_new , y_fit)
    xlim([0 , 0.9])
    %ylim([-0.15, 0.15])
    title("RM - " + titolo , FontSize=10);
    xline(vth , "--");
    yline(0, "-.");
    xline(intervallo(1) , '--');
    xline(intervallo(2) , '--');
    plot(vth,  0 , "*" ,color = "r" , MarkerSize=20);

    if tipo == 'P'
        xlabelb_txt = "$V_{SG} [V]$";
    elseif tipo == 'N'
        xlabelb_txt = "$V_{GS} [V]$";
    end


    xlabel( xlabelb_txt, "Interpreter","latex" , FontSize=15);
    ylabel("$\frac{I_D}{g_m^(\frac{1}{2})} [\sqrt{\frac{A^3}{V}}]$" , Interpreter="latex" , FontSize=15);
    legend( "$I_D$", "Ratio Method", Interpreter = "latex" , Location = "northwest");
    hold off

    if ~exist("fig\" , "dir")
        mkdir("fig\")
    end

    cd fig\

    saveas(gca , "RM.fig")

    cd ..\..
      
    if ~PLOT_ON
        close all
    end

end
