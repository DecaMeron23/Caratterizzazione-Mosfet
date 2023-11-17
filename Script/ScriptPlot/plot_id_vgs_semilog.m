function plot_id_vgs_semilog(file , type)
    % type = 'P';
    dati = readmatrix(file);
    %% estraiamo i dati     
    vg = dati(: , 1);

    % per i dispositivi P consideriamo il -Vgs
    if(type == 'P')
        vgs = vg - 0.9;
        vgs = -vgs;
    elseif(type == 'N')
        vgs = vg;
    end
    
    
    COLONNE_ID = 2:5:width(dati); 
    id = dati(: , COLONNE_ID);

    if(type == 'P')
        id = fliplr(id);
        id = abs(id);
    end
    
    id = id(: , 2:end); % escludiamo lo zero

    %per i dispositivi P si intende |Vds|
    if(length(COLONNE_ID) == 7) % file
        vds = 150 : 150 : 900;
    elseif(length(COLONNE_ID) == 11) % file _2.txt
        vds = 10 : 10 : 100; 
    end

    %% facciamo il plot
    semilogy(vgs, id , LineWidth = 1);

    if(type == 'P')
        nome_vgs = "V_{SG}";
        nome_id = "|I_D|";
        nome_vds = "|V_{DS}|";
    elseif(type == 'N')
        nome_vgs = "V_{GS}";
        nome_id = "I_D";
        nome_vds = "V_{DS}";
    end


    legend("$"+nome_vds+ "  = " + vds + " mV$", interpreter = "latex" ,  FontSize=12 , Location="best");
    xlabel("$" + nome_vgs +"[V]$", Interpreter="latex")
    ylabel("$" + nome_id+ " [A] $", Interpreter="latex");

    %% salviamo il plot
    cd plot;        
    saveas(gcf, 'plot_id_vds_semilog', 'eps');
    saveas(gcf, 'plot_id_vds_semilog', 'png');
    cd ..
end