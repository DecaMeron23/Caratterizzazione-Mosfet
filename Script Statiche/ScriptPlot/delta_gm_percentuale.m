function  delta_gm_percentuale(dispositivo) %dispositivo = "200-30";

    [cartelle , tipologia]= estrazioneCartelle.getCartelle();

    grado = [0 5 50 100 200 600 1000];
    delta = zeros(1 , 7);
    for i = 1: length(cartelle)
        
        cd(string(cartelle(i)));
        cartella_dispositivo = estrazioneCartelle.getFileCartella(dispositivo);

        cd(string(cartella_dispositivo(1)));
        
        file = "id-vgs.txt";
        if(~exist(file , "file"))
            file = "id_vgs.txt";
        end

        [vgs , id , ~] = EstrazioneDati.estrazione_dati_vgs(file , tipologia);
        
        %calcoliamo la gm alla massima vds
        gm = gm_gds(id(: , end) , vgs);
        
        %prendiamo la massima gm
        gm = max(gm);
    
        % se stiamo guardando i dati pre irraggiamento lo prendiamo come riferimento
        if(i == 1)
            gm_pre = gm;
            delta(1) = 0;
        else
            delta(i) = (gm - gm_pre)*100/gm_pre;
        end

        cd ../..
    end

    plot(grado , delta , "LineStyle","-.");
    
end