function vth = RM(dispositivo , PLOT_ON)

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

    % ricerca del punto con vsg = 0.7V
    pos_min = 1;
    while(vgs(pos_min) < 0.6)
        pos_min = pos_min+1;
    end

    % ricerca del punto con vsg = 0.9V
    pos_max = pos_min;
    while(vgs(pos_max) < 0.9)
        pos_max = pos_max +1;
    end

    P = polyfit(vgs(pos_min:pos_max), rm_data(pos_min:pos_max), 1);
    vth = -P(2)/P(1);
    


    if PLOT_ON
        val = polyval(P , vgs);
        figure
        set(gca , "FontSize" , 12)
        titolo = titoloPlot(dispositivo);
        hold on
        plot(vgs , rm_data)
        plot(vgs , val)
        xlim([0 , 0.9])
        ylim([-0.15, 0.15])
        title("Fit lineare - " + titolo , FontSize=10);
        xline(vth , "--");
        yline(0, "--");
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

    end

    cd ..;

end

