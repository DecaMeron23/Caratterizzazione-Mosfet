function plot_gm(dati ,type)
    
    % dati = readmatrix("id_vgs.txt");
    %% Estraiamo i dati
    vsg = dati(: , 1);
    
    vsg = 0.9 - vsg;

    vsd = 150:150:900;

    COLONNE_ID = 2:5:width(dati); 

    id = dati(: , COLONNE_ID);

    id = fliplr(id);
    % escludiamo la vd a 900mV (Vsd = 0mV)
    id = id(: , 2:end);

    %% calcoliamo la gm
    
     % inizializzazione matrici
    gm1 = zeros(size(id));
    gm2 = gm1;
    
    for i=1:width(id)
        gm1(:,i) = gradient(id(:,i)) ./ gradient(vsg);
    end
    
    gm2(1,:) = gm1(1,:);
    
    for i=1:width(id)
        gm2(2:end,i) = gradient(id(1:end-1,i))./gradient(vsg(2:end));
    end
    
    gm = (gm1+gm2)/2;
    
    for i=1:length(vsd)
        gm(:,i) = smooth(gm(:,i));
    end
    
    %% Facciamo il plot
    plot(vsg , gm , LineWidth=1);    
    title("$G_m - V_{SG}$" , Interpreter="latex");
    xlabel("$V_{GS} [V]$", Interpreter="latex");
    ylabel("$G_m [A/V]$" , Interpreter="latex");
    legend("$V_{SD}$ = " + vsd + " $[mV]$" , Location="best" , Interpreter="latex"  , FontSize= 12 );

    %% Salviamo il plot
    cd plot\
    saveas(gcf, 'plot_gm_vds', 'eps');
    saveas(gcf, 'plot_gm_vds', 'png');
    cd ..
    
    %% Salviamo Gm
    
    varName(1) = "Vsg";
    for i = 1 : length(vsd)
        varName(i+1) = "Vsd = " + vsd(i);
    end
    gm_table = [vsg(:) , gm(: , :)];
    gm_table = array2table(gm_table , "VariableNames" , varName);

    writetable(gm_table , "gm.txt" , Delimiter='\t')
    clear

end