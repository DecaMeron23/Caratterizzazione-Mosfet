function plot_gm_id_w_l(file , nomeCartella)
    %% estrazione data
    addpath '..\..\..\Script Statiche\ScriptPlot';

    type = nomeCartella(1);

    [vgs , id , vds] = EstrazioneDati.estrazione_dati_vgs(file , type);

    id_vds_max = id(: , end);
    vds_max = vds(end);

    [titolo , W , L] = titoloPlot(nomeCartella);
    %% calcolo Gm

    gm_vds_max = gm_gds(id_vds_max , vgs);

    gm_id = gm_vds_max ./ id_vds_max;

    %% Calcolo Id * L/W
    
    id_l_w = id_vds_max * (L/W);

    %% Calcolo intercette
    
    [val_y , val_x , x ,y ]= intercette(id_l_w , gm_id , gm_vds_max , id_vds_max);
    


    %% facciamo il plot
    
    loglog(id_l_w , gm_id , LineWidth=2);
    hold on
    grid on
    yline(val_y , '--');
    plot(x , y , '--', 'Color' , [0 0 0]);
    xline(val_x , '--');
    hold off
    if(type == 'P')
        nome_id = "|I_D|";
        nome_vds = "|V_{DS}|";
    elseif(type == 'N')
        nome_id = "I_D";
        nome_vds = "V_{DS}";
    end

    title(titolo);
    ylabel("$g_m / I_d [1/V]$" , Interpreter="latex" , FontSize= 12);
    xlabel("$" + nome_id +"\cdot L/W [A]$", Interpreter="latex" , FontSize= 12);
    % legend("$"+ nome_vds +" = " + vds_max + " mV$" , Location="best" , Interpreter="latex");
    

    ylim([1 100]);
    xlim([1e-9 1e-5]);
    
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
% troviamo le intercette per fare il plot
function [val_y , val_x , x , y] = intercette(id_l_w ,gm_id , gm , id)
    
    val_y = max(gm_id);

    valori_giusti = gm ./ sqrt(id);

    valori_assoluti = abs(valori_giusti - 1);
    indici_valori(1) = find( valori_assoluti == min(valori_assoluti));
        
    array_Booleano = true(1 , length(id_l_w));

    array_Booleano(indici_valori(1)) = false;

    indici_valori(2) = find(valori_assoluti == min(valori_assoluti(array_Booleano)));

    coefficenti = polyfit(log(id_l_w(indici_valori)), log(gm_id(indici_valori)) , 1);

    x = linspace(id_l_w(1) , id_l_w(end) , 1e6);

    y = polyval(coefficenti , log(x));

    y = exp(y);
    
        
    valori_vicini = abs(y-val_y);
    indice = (valori_vicini == min(valori_vicini));
    val_x = x(indice);

    x  = linspace(id_l_w(1) , id_l_w(end) , 2);
  
    y = polyval(coefficenti , log(x));

    y = exp(y);
    
end