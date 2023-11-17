function plot_id_vgs(file , type)    
    %% estraiamo i dati     
    
    [vgs , id , vds] = estrazione_dati_vgs(file , type);

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

    legend("$"+ nome_vds+ "  = " + vds + " mV$", interpreter = "latex" ,  FontSize=12 , Location="best");
    xlabel("$" + nome_vgs +"[V]$", Interpreter="latex")
    ylabel("$" + nome_id+ " [A] $", Interpreter="latex");

    %% salviamo il plot
    cd plot;        
        saveas(gcf, 'plot_id_vds_semilog', 'eps');
        saveas(gcf, 'plot_id_vds_semilog', 'png');
    cd ..

%end