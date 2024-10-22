function plot_gm(file ,nomeCartella , dati)
    %% Estraiamo i dati
     
    type = nomeCartella(1);
    titolo = titoloPlot(nomeCartella);
    
    if nargin == 3
        % Se la funzione è chiamata con 3 argomenti prendiamo i dati dal
        % terzo
        vgs = dati{1};
        id = dati{2};
        vds = dati{3};
    elseif nargin == 2
        [vgs , id , vds] = EstrazioneDati.estrazione_dati_vgs(file , type);
    end
   
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
    ylabel("$g_m [A/V]$" , Interpreter="latex");
    legend("$"+ nome_vds +" = " + vds + " mV$" , Location="best" , Interpreter="latex");
    title(titolo);
    %% Salviamo il plot
    
    if (contains(file  , '2'))
        name = "plot_gm_vgs_2";
    else
        name = "plot_gm_vgs";
    end
    cd plot\eps
        saveas(gcf, name, 'eps');
    cd ..
    cd png\
        saveas(gcf, name, 'png');
    cd ..
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

    if (contains(file  , '2'))
        name = "gm_2";
    else
        name = "gm";
    end

    writetable(gm_table, name , Delimiter='\t' , FileType='text');

end