function plot_id_vds(file , type)    
    %% estraiamo i dati     
    
    [vds , id , vgs] = estrazione_dati_vds(file , type);

    %% facciamo i plot

    plot(vds, id , LineWidth=1);
    
    if(type == 'P')
        nome_vgs = "|V_{GS}|";
        nome_id = "|I_D|";
        nome_vds = "|V_{DS}|";
    elseif(type == 'N')
        nome_vgs = "V_{GS}";
        nome_id = "I_D";
        nome_vds = "V_{DS}";
    end

    legend("$"+ nome_vgs+ "  = " + vgs + " mV$", interpreter = "latex" , Location="best");
    xlabel("$" + nome_vds +"[V]$", Interpreter="latex")
    ylabel("$" + nome_id+ " [A] $", Interpreter="latex");
    
    %% save plot
    cd plot\eps;
        saveas(gcf, 'plot_id_vds', 'eps');
    cd ..
    cd png\
        saveas(gcf, 'plot_id_vds', 'png');
    cd ..
    cd ..
end