function plot_gm_id_w_l(file , type , W  , L)
    %% estrazione data
    
    [vgs , id , vds] = estrazione_dati_vgs(file , type);

    %% calcolo Gm

    gm = gm_gds(id , vgs);

    %% Calcolo Id * W/L
    id_w_l = id .* (W/L);

    %% facciamo il plot
    semilogx(gm , id_w_l , LineWidth=1);
    
end