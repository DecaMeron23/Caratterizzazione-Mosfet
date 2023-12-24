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

    % ricerca del punto con vsg = 0.5V
    pos_min = 1;
    while(vgs(pos_min) < 0.5)
        pos_min = pos_min+1;
    end

    % ricerca del punto con vsg = 0.6V
    pos_max = pos_min;
    while(vgs(pos_max) < 0.6)
        pos_max = pos_max +1;
    end
  
    %calcolo dei coefficenti
    P = polyfit(vgs(pos_min:pos_max), id(pos_min:pos_max), 1);
    vth = -P(2)/P(1);

    %plot di verifica del fit a Vsd = 150mV
    if PLOT_ON
            val = polyval(P , [0 , 0.9]);
            figure
            set(gca , "FontSize" , 12)
            titolo = titoloPlot(dispositivo);
            hold on
            plot(vgs , id)
            plot([0 , 0.9] , val)
            title("Fit lineare - " + titolo , FontSize=10);
            xlim([0 , 0.7])
            xline(0.5 , "--")
            xline(0.6 , "--")
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
    end

    cd ..

end