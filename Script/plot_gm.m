%function plot_gm(dati)
    
    dati = readmatrix("id_vgs.txt");
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
    
    %% Facciamo i plot
    plot(vsg , gm , LineWidth=1);    
    title("$G_m - V_{SG}$" , Interpreter="latex");
    xlabel("$V_{GS} [V]$", Interpreter="latex");
    ylabel("$G_m [A/V]$" , Interpreter="latex");
    legend("$V_{SD}$ = " + vsd + " $[mV]$" , Location="best" , Interpreter="latex"  , FontSize= 12 );

    clear
%end