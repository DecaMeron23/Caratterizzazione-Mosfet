function  delta_gm_percentuale()

    [cartelle]= estrazioneCartelle.getCartelle();

    grado = [0 5 50 100 200 600 1000 3000 "annealing"];
    valori_vds = [0.15 , 0.30 , 0.45 , 0.6 , 0.75 , 0.9];
    nomi_dispositivi = ["100-30" , "100-60" , "100-180" , "200-30" , "200-60", "200-180" , "600-30" , "600-60" , "600-180"];

    for k = 1:length(nomi_dispositivi)
        dispositivo = nomi_dispositivi(k);
        disp("Dispositivo = "+ dispositivo);
        delta = zeros(6 , 7);
        for i = 1: length(cartelle)
            if grado(i) == "annealing"
                print = grado(i);
            else
                print = grado(i) +  "Mrad";
            end
            disp("      Grado = " + print);
            cd(string(cartelle(i)));
            cartella_dispositivo = estrazioneCartelle.getFileCartella(dispositivo);
    
            try
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
                gm_max = max(gm_i);
        
                % se stiamo guardando i dati pre irraggiamento lo prendiamo come riferimento
                if(i == 1)
                    gm_pre(j , 1) = gm_max;
                    delta( j , 1) = 0;
                else
                    delta(j , i) = (gm_max - gm_pre(j,1))*100/gm_pre(j,1);
                end
    
            end
            
            cd ..
        
            catch e
                
                %Se non esiste il dispositivo
                warning("Dispositivo: '" + dispositivo + "' non trovato")
                delta(: ,i) = zeros(length(valori_vds) , 1);
            end
            cd ..
        end
        
        % creaimo la tabella
        %entriamo nella cartella DeltaGm
        if(~exist("DeltaGm", "dir"))
            mkdir("DeltaGm\");
        end
        cd DeltaGm;
        %componiamo la matrice da salvare
        
        matrice =  horzcat(valori_vds' , delta);
        valori = ["Vds" , (grado(1:end-1) + "Mrad") , grado(end)];        
        matrice = array2table(matrice);
        vecchi_nomi = 1:width(matrice);
        matrice = renamevars(matrice,vecchi_nomi,valori);
        writetable(matrice , "Delta_gm_" + dispositivo+ ".xls");
        cd ..
    end
end