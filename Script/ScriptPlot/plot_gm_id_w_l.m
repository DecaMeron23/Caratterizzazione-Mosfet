function plot_gm_id_w_l(file , type , W  , L)
    %% estrazione data
    
    [vgs , id , vds] = estrazione_dati_vgs(file , type);

    %% calcolo Gm

    gm = gm_gds(id , vgs);

    %% Calcolo Id * W/L
    id_w_l = id .* (W/L);

    %% facciamo il plot

    semilogx(id_w_l  , gm , LineWidth=1);
    
    if(type == 'P')
        nome_id = "|I_D|";
        nome_vds = "|V_{DS}|";
    elseif(type == 'N')
        nome_id = "I_D";
        nome_vds = "V_{DS}";
    end
    
    ylabel("$G_m [A/V]$" , Interpreter="latex");
    xlabel("$" + nome_id +"\cdot W/L [A]$", Interpreter="latex");
    legend("$"+ nome_vds +" = " + vds + " [mV]$" , Location="best" , Interpreter="latex" , FontSize=12);

    %% salviamo i plot
    
    if (contains(file  , '2'))
        name = "plot_gm_id_w_l_2";
    else
        name = "plot_gm_id_w_l";
    end

    cd plot\eps;        
        saveas(gcf, name , 'eps');
    cd ..
    cd png
        saveas(gcf, name , 'png');
    cd ..
    cd ..

end