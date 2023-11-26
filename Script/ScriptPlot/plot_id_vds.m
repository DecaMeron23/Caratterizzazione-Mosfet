<<<<<<< HEAD
%function plot_id_vds(dati)

    dati = readmatrix("id-vds.txt");
    vds = .9 - dati(2:end , 1);

    vsg = 900:-150:0;
    id = dati(2:end , 7:5:end);

    id = abs(id);

    plot(vds, id)
    legend("$V_{SG} = " + vsg + " mV$", interpreter = "latex");
    title("$|I_D| - V_{SD}$", Interpreter="latex")
    xlabel("$V_{SD} [V]$", Interpreter="latex")
    ylabel("$|I_D| [A] $", Interpreter="latex");
    hold off;

    %cd plot\
    saveas(gcf, 'plot_id_vds.png', 'png');
    %cd ..
%end
=======
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
>>>>>>> 9f8fc33558e016a114252c9571aa09f57737e86a
