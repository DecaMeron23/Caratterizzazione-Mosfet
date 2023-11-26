function plot_gds(file , type) 
    %% Estraiamo i dati
<<<<<<< HEAD
    vd = dati(: , 1);
    
    vsd = 0.9 - vd;
    
    
    COLONNE_ID = 2:5:width(dati); 
=======
>>>>>>> 9f8fc33558e016a114252c9571aa09f57737e86a

    [vds , id , vgs] = estrazione_dati_vds(file , type);

    %% calcoliamo la gm
    
<<<<<<< HEAD
     % inizializzazione matrici
    gds1 = zeros(size(id));
    gds2 = gds1;
    
    for i=1:width(id)
        gds1(:,i) = gradient(id(:,i)) ./ gradient(vsd);
    end

    gds2(1,:) = gds1(1,:);

    for i=1:width(id)
        gds2(2:end,i) = gradient(id(1:end-1,i))./gradient(vsd(2:end));
    end

    gds = (gds1+gds2)/2;

    for i=1:length(vgs)
        gds(:,i) = smooth(gds(:,i));
    end

    %% Facciamo il plot

    %figure(Visible="off");
    figure
    plot(vsd , gds , LineWidth=1)    
    title("$G_{ds} - V_{SD}$" , Interpreter="latex")
    xlabel("$V_{SD} [V]$", Interpreter="latex")
    ylabel("$G_{ds} [A/V]$" , Interpreter="latex")
    legend("$V_{SG}$ = " + vgs + " $[mV]$" , Location="best" , Interpreter="latex"  , FontSize= 12 )


    %% Salviamo il plot
    
    % cd plot\
    % saveas(gcf, 'plot_gds_vgs', 'eps');
    % saveas(gcf, 'plot_gds_vgs', 'png');
    % close(gcf)
    % cd ..
=======
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
    ylabel("$G_{ds} [A/V]$" , Interpreter="latex");
    legend("$"+ nome_vgs +" = " + vgs + " [mV]$" , Location="best" , Interpreter="latex");

    %% Salviamo il plot
    
    cd plot\eps
        saveas(gcf, 'plot_gds_vgs', 'eps');
    cd ..
    cd png\
        saveas(gcf, 'plot_gds_vgs', 'png');
    cd ..
    cd ..
>>>>>>> 9f8fc33558e016a114252c9571aa09f57737e86a
    
    %% Salviamo Gm
    
    if(type == 'P')
        varName(1) = "|Vds|";
        nome_vgs = "|Vgs|";
    elseif(type == 'N')
        varName(1) = "Vds";
        nome_vgs = "Vgs";
    end
<<<<<<< HEAD
    gm_table = [vsd(:) , gds(: , :)];
=======
    
    
    for i = 1 : length(vgs)
        varName(i+1) = "Gm_"+nome_vgs + "=" + vgs(i) * 1e-3 + "V";
    end
    
    gm_table = [vds(:) , gds(: , :)];
>>>>>>> 9f8fc33558e016a114252c9571aa09f57737e86a
    gm_table = array2table(gm_table , "VariableNames" , varName);

    writetable(gm_table , "gds.txt" , Delimiter='\t')
    

end