function plot_delta_gm_tutti(vds ,tipologia)
    
    if(tipologia == "N")
        dispositivi = [ "100-30" "100-60" "100-180" "200-30" "200-60" "200-180" "600-60" "600-180"];
        dispositiviLegenda = [ "100-0.030" "100-0.060" "100-0.0180" "200-0.030" "200-0.060" "200-0.0180" "600-0.060" "600-0.0180"];
    elseif tipologia == "P"
        dispositivi = [ "100-30" "100-60" "200-30" "200-60" "200-180" "600-30" "600-60" "600-180"];
        dispositiviLegenda = [ "100-0.030" "100-0.060" "200-0.030" "200-0.060" "200-0.0180" "600-0.030" "600-0.060" "600-0.0180"];
    end
    
    for i = 1: length(dispositivi)
       plot_delta_gm(vds , tipologia , dispositivi(i) , false);
       hold on
    end
    
    hold off
    titolo = tipologia+"MOS";
    ytickformat('percentage');
    title(titolo, Interpreter="latex" , FontSize=12);
    ylabel("$ \% \Delta g_m$" , Interpreter="latex" , FontSize=12);
    xlabel("Dose Assorbita $[Mrad]$" , Interpreter="latex" , FontSize=12);
    yline(0 , "--");
    grid on
    
    legend(dispositiviLegenda);

end