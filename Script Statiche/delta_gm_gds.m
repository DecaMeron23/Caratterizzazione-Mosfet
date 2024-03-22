classdef delta_gm_gds
    % delta_gm_gds: questa classe fornisce le funzioni che calcolano per
    % ogni dispositivo le delta gm (o gds) massima ad ogni corrente, per ogni irraggiamento

    %% Come utilizzare:
    % posizionarsi nella cartella contenente tutte le misure di irraggiamento di
    % un ASIC (quindi la cartella contenente: "Chip4NMOS, Chip4NMOS_5Mrad,
    % ecc.") e avviare la funzione delta_gds_percentuale (oppure
    % delta_gds_percentuale).
    % A fine esecuzione nella cartella si crerà una nuova directory, chiamata 
    % DeltaGm (o DeltaGds) contenente un file .xls per ogni dispositivo.
    % Il file è così composto: sulle righe le diverse Vgs (o Vds) a cui si
    % è misurato gm (o gds) sulle colonne invece saranno presenti le
    % diverse dosi di irraggiamento
    
    methods (Static)
        % calcolo della delta gds percentuale
        function  delta_gds_percentuale()
            
            [cartelle]= estrazioneCartelle.getCartelle();
            
            
            grado = [0 5 50 100 200 600 1000];
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

        % calcolo della delta gm percentuale
        function  delta_gm_percentuale()
            
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
                        gm_max = max(gm_i);
                        
                        % se stiamo guardando i dati pre irraggiamento lo prendiamo come riferimento
                        if(i == 1)
                            gm_pre(j , 1) = gm_max;
                            delta( j , 1) = 0;
                        else
                            delta(j , i) = (gm_max - gm_pre(j,1))*100/gm_pre(j,1);
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
                
                matrice =  horzcat(valori_vds' , delta);
                valori = ["Vds" , (grado + "Mrad")];
                matrice = array2table(matrice);
                vecchi_nomi = 1:width(matrice);
                matrice = renamevars(matrice,vecchi_nomi,valori);
                writetable(matrice , "Delta_gm_" + dispositivo+ ".xls");
                cd ..
            end
        end
    end
end