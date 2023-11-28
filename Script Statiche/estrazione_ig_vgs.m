function  [mod_ig , vgs] = estrazione_ig_vgs(file , type)
    
    dati = readmatrix(file);
    vg = dati(: , 1);
    
    % per i dispositivi P consideriamo il -Vgs == Vsg
    if(type == 'P')
        vgs = vg - 0.9;
        vgs = -(vgs);
    elseif(type == 'N')
        vgs = vg;
    end

    if(type == 'P')
        COLONNA_IG_VDS_0 = 33;
    elseif(type == 'N')
        COLONNA_IG_VDS_0 = 3;
    end
    
    % prendiamo la |ig| a vds = 0
    mod_ig = abs(dati(: , COLONNA_IG_VDS_0));
    
end