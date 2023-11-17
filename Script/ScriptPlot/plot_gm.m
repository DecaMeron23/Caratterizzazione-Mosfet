function plot_gm(file ,type)
    %% Estraiamo i dati
    
    [vgs , id , vds] = estrazione_dati_vgs(file , type);

    %% calcoliamo Gm
    gm = gm_gds(id , vgs);
    
    %% Facciamo il plot
    plot(vgs , gm , LineWidth=1); 

    if(type == 'P')
        nome_vgs = "V_{SG}";
        nome_vds = "|V_{DS}|";
    elseif(type == 'N')
        nome_vgs = "V_{GS}";
        nome_vds = "V_{DS}";
    end
    xlabel("$" + nome_vgs +" [V]$", Interpreter="latex");
    ylabel("$G_m [A/V]$" , Interpreter="latex");
    legend("$"+ nome_vds +" = " + vds + " [mV]$" , Location="best" , Interpreter="latex" , FontSize=12);

    %% Salviamo il plot
    cd plot\
        saveas(gcf, 'plot_gm_vds', 'eps');
        saveas(gcf, 'plot_gm_vds', 'png');
    cd ..
    
    %% Salviamo Gm

    if(type == 'P')
        varName(1) = "|Vgs|";
        nome_vds = "|Vds|";
    elseif(type == 'N')
        varName(1) = "Vgs";
        nome_vds = "Vds";
    end

    for i = 1 : length(vds)
        varName(i+1) = "Gm_" + nome_vds + "=" + vds(i) * 1e-3 + "V";
    end

    gm_table = [vgs(:) , gm(: , :)];
    gm_table = array2table(gm_table , "VariableNames" , varName);

    writetable(gm_table , "gm.txt" , Delimiter='\t');

end