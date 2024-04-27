function  delta_gds_percentuale() %dispositivo = "200-30" vds = 0.45

    [cartelle]= estrazioneCartelle.getCartelle();


    grado = [0 5 50 100 200 600 1000 3000];
    valori_vgs = [0.15 , 0.30 , 0.45 , 0.6 , 0.75 , 0.9];
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
            
            file = "gds.txt";
    
            gds = readmatrix(file);
            %togliamo la vgs
            gds = gds(: , 2:end);
    
            %Per ogni valore di vgs
            for j = 1 : length(valori_vgs)
                %selezioniamo la vgs, troviamo l'indice di vgs
                disp("              Vgs = " + valori_vgs(j) + "V");
                indice_vgs = (valori_vgs - valori_vgs(j)) == 0;
                gds_i = gds(: , indice_vgs);
                % prendiamo la massima gm
                gds_max = max(gds_i);
        
                % se stiamo guardando i dati pre irraggiamento lo prendiamo come riferimento
                if(i == 1)
                    gds_pre = gds_max;
                    delta( j , 1) = 0;
                else
                    delta(j , i) = (gds_max - gds_pre)*100/gds_pre;
                end
    
            end
            
            cd ../..
        
        end
        
        % creaimo la tabella
        %entriamo nella cartella DeltaGm
        if(~exist("DeltaGds", "dir"))
            mkdir("DeltaGds\");
        end
        cd DeltaGds;
        %componiamo la matrice da salvare
        
        matrice =  horzcat(valori_vgs' , delta);
        valori = ["Vgs" , (grado + "Mrad")];        
        matrice = array2table(matrice);
        vecchi_nomi = 1:width(matrice);
        matrice = renamevars(matrice,vecchi_nomi,valori);
        writetable(matrice , "Delta_ds_" + dispositivo+ ".xls");
        cd ..
    end
end