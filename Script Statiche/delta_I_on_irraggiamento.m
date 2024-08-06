%% posisizionarsi nella cartella con tutti gli irraggiamenti
function delta_I_on_irraggiamento()
    
    [cartelle]= estrazioneCartelle.getCartelle();

    grado = [0 5 50 100 200 600 1000 3000 "annealing"];
    valori_vds = [0.15 , 0.30 , 0.45 , 0.6 , 0.75 , 0.9];
    nomi_dispositivi = ["100-30" , "100-60" , "100-180" , "200-30" , "200-60", "200-180" , "600-30" , "600-60" , "600-180"];

    for k = 1:length(nomi_dispositivi)
        dispositivo = nomi_dispositivi(k);
        disp("Dispositivo = "+ dispositivo);
        delta = zeros(6 , 8);
        for i = 1: length(cartelle)
            disp("      Grado = " + grado(i)+  "Mrad");
            cd(string(cartelle(i)));
            cartella_dispositivo = estrazioneCartelle.getFileCartella(dispositivo);
            try
            cartella_dispositivo = string(cartella_dispositivo(1));
            catch
            end
            if(~exist(cartella_dispositivo , "dir"))
                warning("Dispositivo non torvato: '" + dispositivo + "'");
                delta(1:end , i) = zeros(length(valori_vds) , 1);
            else
                cd(cartella_dispositivo);
                for j = 1:length(valori_vds)
                    I_on = calcola_I_on(valori_vds(j), char(cartella_dispositivo));
                    
                    if(i == 1)
                            I_on_pre(j , 1) = I_on;
                            delta( j , 1) = 0;
                        else
                            delta(j , i) = (I_on - I_on_pre(j,1))*100/I_on_pre(j,1);
                    end
                end
             
                cd ..
            end
            cd ..
        end
        
        % creaimo la tabella
        %entriamo nella cartella DeltaGm
        if(~exist("DeltaIon", "dir"))
            mkdir("DeltaIon\");
        end
        cd DeltaIon;
        %componiamo la matrice da salvare
        
        matrice =  horzcat(valori_vds' , delta);
        valori = ["Vds" , (grado + "Mrad")];        
        matrice = array2table(matrice);
        vecchi_nomi = 1:width(matrice);
        matrice = renamevars(matrice,vecchi_nomi,valori);
        writetable(matrice , "Delta_I_on_" + dispositivo+ ".xls");
        cd ..
    end
end


function I_on = calcola_I_on(vds, dispositivo)

    if exist("id-vgs.txt","file")
        id_vgs = readmatrix("id-vgs.txt");
    elseif exist("id_vgs.txt","file")
           id_vgs = readmatrix("id_vgs.txt");
    end
    id_vgs = id_vgs(:,[2,7,12,17,22,27,32]);
    if(dispositivo(1) == 'P')
        indice_vds = 7-vds/0.15;
        if(strcmp(dispositivo, 'P1-600-30'))
            I_on = id_vgs(202, indice_vds); %corrente a Vsg = 0,7V e Vsd passata come parametro
        else
             I_on = id_vgs(end, indice_vds); %corrente a Vsg = 0,9V e Vsd passata come parametro
        end
    else 
        indice_vds = 1+vds/0.15;
        if(strcmp(dispositivo, 'N4-600-60') && vds == 0.9)
            I_on = id_vgs(202, indice_vds); %corrente a Vgs = 0,7V e Vsd passata come parametro
        else
            I_on = id_vgs(end, indice_vds); %corrente a Vgs = 0,9V e Vsd passata come parametro
        end
    end
end
