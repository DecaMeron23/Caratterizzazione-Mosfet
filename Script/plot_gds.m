% function plot_gds(dati , type)
     
    dati = readmatrix("id_vds.txt");
    %% Estraiamo i dati
    vds = dati(: , 1);
    
    vds = 0.9 - vds;
    
    
    COLONNE_ID = 2:5:width(dati); 

    id = dati(: , COLONNE_ID);

    id = fliplr(id);
    % escludiamo la vd a 900mV (Vsd = 0mV)
    id = id(: , 2:end);

    % verifichiamo se il file è "_2" o normale
    if width(id) == 6
        vgs = 150:150:900;
    elseif width(id) == 10
        vgs = 10:10:100;
    end
    

    %% calcoliamo la gm
    
     % inizializzazione matrici
    gds1 = zeros(size(id));
    gds2 = gds1;
    
    for i=1:width(id)
        gds1(:,i) = gradient(id(:,i)) ./ gradient(vds);
    end

    gds2(1,:) = gds1(1,:);

    for i=1:width(id)
        gds2(2:end,i) = gradient(id(1:end-1,i))./gradient(vds(2:end));
    end

    gds = (gds1+gds2)/2;

    for i=1:length(vgs)
        gds(:,i) = smooth(gds(:,i));
    end

    %% Facciamo il plot

    figure(Visible="off");

    plot(vds , gds , LineWidth=1);    
    title("$G_{ds} - V_{SD}$" , Interpreter="latex");
    xlabel("$V_{SD} [V]$", Interpreter="latex");
    ylabel("$G_{ds} [A/V]$" , Interpreter="latex");
    legend("$V_{SG}$ = " + vgs + " $[mV]$" , Location="best" , Interpreter="latex"  , FontSize= 12 );


    %% Salviamo il plot
    
    cd plot\
    saveas(gcf, 'plot_gds_vgs', 'eps');
    saveas(gcf, 'plot_gds_vgs', 'png');
    close(gcf)
    cd ..
    
    %% Salviamo Gm
    
    varName(1) = "Vds";
    for i = 1 : length(vgs)
        varName(i+1) = "Vsg = " + vgs(i);
    end
    gm_table = [vds(:) , gds(: , :)];
    gm_table = array2table(gm_table , "VariableNames" , varName);

    writetable(gm_table , "gds.txt" , Delimiter='\t')
    clear

% end