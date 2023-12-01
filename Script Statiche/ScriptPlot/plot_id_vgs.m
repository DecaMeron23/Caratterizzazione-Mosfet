function plot_id_vgs(file , nomeCartella , dati)    
%% estraiamo i dati     
    
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
   
    %% facciamo il plot
    plot(vgs, id , LineWidth = 1);

    if(type == 'P')
        nome_vgs = "V_{SG}";
        nome_id = "|I_D|";
        nome_vds = "|V_{DS}|";
    elseif(type == 'N')
        nome_vgs = "V_{GS}";
        nome_id = "I_D";
        nome_vds = "V_{DS}";
    end
    
    title(titolo);
    legend("$"+ nome_vds+ "  = " + vds + " mV$", interpreter = "latex", Location="best");
    xlabel("$" + nome_vgs +"[V]$", Interpreter="latex")
    ylabel("$" + nome_id+ " [A] $", Interpreter="latex");

    %% salviamo il plot

    if (contains(file  , '2'))
        name = "plot_id_vgs_2";
    else
        name = "plot_id_vgs";
    end
        
    cd plot\eps;        
        saveas(gcf, name, 'eps');
    cd ..
    cd png\
        saveas(gcf, name, 'png');
    cd ..
    cd ..

end