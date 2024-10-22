function plot_gds(file , nomeCartella , dati) 
    %% Estraiamo i dati
    type = nomeCartella(1);
    titolo = titoloPlot(nomeCartella);
    
    if nargin == 3
        % Se la funzione è chiamata con 3 argomenti prendiamo i dati dal
        % terzo
        vds = dati{1};
        id = dati{2};
        vgs = dati{3};
    elseif nargin == 2
        [vds , id , vgs] = EstrazioneDati.estrazione_dati_vds(file , type);
    end
    
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
    ylabel("$g_{ds} [A/V]$" , Interpreter="latex");
    legend("$"+ nome_vgs +" = " + vgs + " mV$" , Location="best" , Interpreter="latex");
    title(titolo);
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