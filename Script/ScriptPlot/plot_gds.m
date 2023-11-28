function plot_gds(file , type) 
    %% Estraiamo i dati
    [vds , id , vgs] = estrazione_dati_vds(file , type);

    %% calcoliamo la gm
    
    gds = gm_gds(id , vds);

    %% Facciamo il plot

    plot(vds , gds , LineWidth=1);

    if(type == 'P')
        nome_vgs = "|V_{GS}|";
        nome_vds = "|V_{DS}|";
    elseif(type == 'N')
        nome_vgs = "V_{GS}";
        nome_vds = "V_{DS}";
    end
    xlabel("$" + nome_vds +" [V]$", Interpreter="latex");
    ylabel("$G_{ds} [A/V]$" , Interpreter="latex");
    legend("$"+ nome_vgs +" = " + vgs + " [mV]$" , Location="best" , Interpreter="latex");

    %% Salviamo il plot
    
    cd plot\eps
        saveas(gcf, 'plot_gds_vgs', 'eps');
    cd ..
    cd png\
        saveas(gcf, 'plot_gds_vgs', 'png');
    cd ..
    cd ..
    
    %% Salviamo Gm
    
    if(type == 'P')
        varName(1) = "|Vds|";
        nome_vgs = "|Vgs|";
    elseif(type == 'N')
        varName(1) = "Vds";
        nome_vgs = "Vgs";
    end
  
    for i = 1 : length(vgs)
        varName(i+1) = "Gm_"+nome_vgs + "=" + vgs(i) * 1e-3 + "V";
    end
    
    gm_table = [vds(:) , gds(: , :)];
    gm_table = array2table(gm_table , "VariableNames" , varName);

    writetable(gm_table , "gds.txt" , Delimiter='\t')   

end