function  delta_gm_percentuale(dispositivo) %dispositivo = "200-30" vds = 0.45

    [cartelle , tipologia]= estrazioneCartelle.getCartelle();

    grado = [0 5 50 100 200 600 1000];
    valori_vds = [0.15 , 0.30 , 0.45 , 0.6 , 0.75 , 0.9];
    delta = zeros(6 , 7);
    for i = 1: length(cartelle)
        disp("Grado = " + grado(i)+  "Mrad");
        cd(string(cartelle(i)));
        cartella_dispositivo = estrazioneCartelle.getFileCartella(dispositivo);

        cd(string(cartella_dispositivo(1)));
        
        file = "gm.txt";

        gm = readmatrix(file);
        %togliamo la vgs
        gm = gm(: , 2:end);

        %Per ogni valore di vds
        for j = 1 : length(valori_vds)
            %selezioniamo la vds, troviamo l'indice di vds
            disp("      Vds = " + valori_vds(j) + "V");
            indice_vds = (valori_vds - valori_vds(j)) == 0;
            gm_i = gm(: , indice_vds);
            % prendiamo la massima gm
            gm_max = max(gm_i);
    
            % se stiamo guardando i dati pre irraggiamento lo prendiamo come riferimento
            if(i == 1)
                gm_pre = gm_max;
                delta( j , 1) = 0;
            else
                delta(j , i) = (gm_max - gm_pre)*100/gm_pre;
            end

        end
        
        cd ../..
    
    end
    
    % creaimo la tabella
    %entriamo nella cartella DeltaGm
    if(~exist("DeltaGm\" + dispositivo , "dir"))
        mkdir("DeltaGm\" + dispositivo);
    end
    cd("DeltaGm\" + dispositivo);
    %componiamo la matrice da salvare
    matrice = ["Vds" , (grado + "Mrad"); valori_vds' , delta];
    writematrix(matrice , "Delta_gm_" + dispositivo+ ".xls");

    % Plot variazioni
    if(0)
    dispositivo = char(dispositivo);

    titolo = tipologia+"MOS $" + dispositivo(1:3)+"-"+"0.0"+ dispositivo(5:end) + "$" ;

    plot(grado , delta , Marker="diamond" , LineWidth=1);    
    ytickformat('percentage');
    title(titolo, Interpreter="latex" , FontSize=12);
    ylabel("$ \% \Delta g_m$" , Interpreter="latex" , FontSize=12);
    xlabel("Dose Assorbita $[Mrad]$" , Interpreter="latex" , FontSize=12);
    yline(0 , "--");
    grid on 
    end
end