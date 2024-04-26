function delta_I_off()
    
    [cartelle]= estrazioneCartelle.getCartelle();

    grado = [0 5 50 100 200 600 1000 3000];
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
            cartella_dispositivo = string(cartella_dispositivo(1));
    
            cd(cartella_dispositivo);
            for j = 1:length(valori_vds)
                I_off = calcola_I_off(valori_vds(j), char(cartella_dispositivo));
                
                if(i == 1)
                        I_off_pre(j , 1) = I_off;
                        delta( j , 1) = 0;
                    else
                        delta(j , i) = abs((I_off - I_off_pre(j,1))); 
                end
            end
         
            cd ../..
        
        end
        
        % creaimo la tabella
        %entriamo nella cartella DeltaGm
        if(~exist("DeltaIoff", "dir"))
            mkdir("DeltaIoff\");
        end
        cd DeltaIoff;
        %componiamo la matrice da salvare
        
        matrice =  horzcat(valori_vds' , delta);
        valori = ["Vds" , (grado + "Mrad")];        
        matrice = array2table(matrice);
        vecchi_nomi = 1:width(matrice);
        matrice = renamevars(matrice,vecchi_nomi,valori);
        writetable(matrice , "Delta_I_off_" + dispositivo+ ".xls");
        cd ..
    end
end


function I_off = calcola_I_off(vds, dispositivo)

    if exist("id-vgs.txt","file")
        id_vgs = readmatrix("id-vgs.txt");
    elseif exist("id_vgs.txt","file")
           id_vgs = readmatrix("id_vgs.txt");
    end
    id_vgs = id_vgs(1,[2,7,12,17,22,27,32]);

    L_dispositivo = str2double(string(dispositivo(8:end)))*1e-9;
    N_finger = str2double(string(dispositivo(4:6))) / 2.5;

    if(dispositivo(1) == 'P')
        indice_vds = 7-vds/0.15;
    else 
        indice_vds = 1+vds/0.15;
    end
    I_off = id_vgs(indice_vds)*L_dispositivo/N_finger;
       
end
