function  delta_gm_percentuale() %dispositivo = "200-30" vds = 0.45

    [cartelle]= estrazioneCartelle.getCartelle();

    grado = [0 5 50 100 200 600 1000];
    valori_vds = [0.15 , 0.30 , 0.45 , 0.6 , 0.75 , 0.9];
    nomi_dispositivi = ["100-30" , "100-60" , "100-180" , "200-30" , "200-60", "200-180" , "600-30" , "600-60" , "600-180"];

    for k = 1:length(nomi_dispositivi)
        dispositivo = nomi_dispositivi(k);
        disp("Dispositivo = "+ dispositivo);
        delta = zeros(6 , 7);
        for i = 1: length(cartelle)
            disp("      Grado = " + grado(i)+  "Mrad");
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
                disp("              Vds = " + valori_vds(j) + "V");
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
        if(~exist("DeltaGm", "dir"))
            mkdir("DeltaGm\");
        end
        cd DeltaGm;
        %componiamo la matrice da salvare
        matrice = ["Vds" , (grado + "Mrad"); valori_vds' , delta];
        writematrix(matrice , "Delta_gm_" + dispositivo+ ".xls");
        cd ..
    end
end