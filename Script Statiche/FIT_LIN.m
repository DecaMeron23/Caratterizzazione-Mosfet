function vth = FIT_LIN(dispositivo , PLOT_ON)

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
        %predo le id_vgs per Vsd minima (150mV)
        id = id_Vgs_completo(: , 7);
    end
    
    %settiamo l'R^2 migliore a 0
    R_migliore = 0;

    % dalla posizione in cui è a 0.3V fino a (0.9-0.15)V
    for i = 121:211
        
        % prendiamo l'intervallod 
        x = vgs(i : i+30);
        y = id(i : i+30);

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
    
    %plot di verifica del fit a Vsd = 150mV
    x_new = [vth-0.2 , 0.9];
    y_fit = predict(modello_migliore ,x_new' );
    figure
    set(gca , "FontSize" , 12)
    titolo = titoloPlot(dispositivo);
    hold on
    plot(vgs , id)
    plot(x_new , y_fit)
    title("Fit lineare - " + titolo , FontSize=10);
    xlim([0.2 , 0.9])
    xline(intervallo(1) , "--")
    xline(intervallo(2) , "--")
    yline(0 , "-.");
    xline(vth , "--");
    plot(vth ,  0 , "*" ,color = "r" , MarkerSize=20);

    if tipo == 'P'
        xlabelb_txt = "$V_{SG} [V]$";
    elseif tipo == 'N'
        xlabelb_txt = "$V_{GS} [V]$";
    end
    

    xlabel( xlabelb_txt, "Interpreter","latex" , FontSize=15);
    ylabel("$I_D [A]$" , Interpreter="latex" , FontSize=15);
    legend( "$I_D$", "fit lineare", Interpreter = "latex" , Location = "northwest");
    hold off
    
    %salvo il plot
    if(~exist("fig\" , "dir"))
        mkdir("fig\")
    end
    
    cd fig\

    saveas(gca , "FIT.fig");


    if ~PLOT_ON
        close all
    end

    cd ..\..

end