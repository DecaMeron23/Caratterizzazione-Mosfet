function plot_id_vgs_semilog(file , type)
    %% estraiamo i dati     
    
    [vgs , id , vds] = estrazione_dati_vgs(file , type);

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


    legend("$"+nome_vds+ "  = " + vds + " mV$", interpreter = "latex", Location="best");
    xlabel("$" + nome_vgs +"[V]$", Interpreter="latex")
    ylabel("$" + nome_id+ " [A] $", Interpreter="latex");

    %% salviamo il plot

    if (contains(file  , '2'))
        name = "plot_id_vgs_semilog_2";
    else
        name = "plot_id_vgs_semilog";
    end

    cd plot\eps;        
        saveas(gcf, name , 'eps');
    cd ..
    cd png
        saveas(gcf, name , 'png');
    cd ..
    cd ..
end