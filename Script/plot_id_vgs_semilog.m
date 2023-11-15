%function plot_id_vgs(dati)
    dati = readmatrix("id_vgs.txt");
    %% estraiamo i dati 
    vg = dati(: , 1);
    
    vsd = 150:150:900;

    COLONNE_ID = 2:5:width(dati); 

    id = dati(: , COLONNE_ID);

    id = fliplr(id);
    id = id(: , 2:end);

    %% facciamo il plot
    for i = 1:width(id)
    semilogy(vg, id(: , i) , 'LineWidth', 1);
    hold all
    end 
    legend("$V_{SG} = " + vsd + " mV$", interpreter = "latex" ,  FontSize=12 , Location="best");
    title("$I_D - V_{GS}$ - $I_D$ in Scala Logaritmica", Interpreter="latex")
    xlabel("$V_{GS} [V]$", Interpreter="latex")
    ylabel("$I_D [A] $", Interpreter="latex");
    hold off;

    %% salviamo il plot
    cd plot;        
    saveas(gcf, 'plot_id_vds_semilog', 'eps');
    saveas(gcf, 'plot_id_vds_semilog', 'png');
    cd ..
%end