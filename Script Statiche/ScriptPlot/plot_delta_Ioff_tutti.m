function plot_delta_Ioff_tutti(vds ,tipologia)
    
    if char(tipologia) == 'N'
        dispositivi = [ "100-30" "100-60" "100-180" "200-30" "200-60" "200-180" "600-60" "600-180"];
        dispositiviLegenda = [ "100-0.030" "100-0.060" "100-0.0180" "200-0.030" "200-0.060" "200-0.0180" "600-0.060" "600-0.0180"];
    elseif char(tipologia) == 'P'
        dispositivi = [ "100-30" "100-60" "200-30" "200-60" "200-180" "600-30" "600-60" "600-180"];
        dispositiviLegenda = [ "100-0.030" "100-0.060" "200-0.030" "200-0.060" "200-0.0180" "600-0.030" "600-0.060" "600-0.0180"];
    end
    
    for i = 1: length(dispositivi)
       plot_delta_Ioff(vds , tipologia , dispositivi(i) , false);
       hold on
    end
    
    hold off
    if(char(tipologia)=='P')
        titolo = "PMOS - $V_{GS}=0.3V$ $ |V_{DS}|="+ vds + "V$";
        ylabel("$ |\Delta I_{off}|[Am]$" , Interpreter="latex" , FontSize=12);
    else
         titolo = "NMOS - $V_{GS}=-0.3V$ $ V_{DS}="+ vds + "V$";
         ylabel("$ \Delta I_{off}[Am]$" , Interpreter="latex" , FontSize=12);
    end
    title(titolo, Interpreter="latex" , FontSize=12);
    xlabel("Dose Assorbita $[Mrad]$" , Interpreter="latex" , FontSize=12);
    yline(0 , "--");
    grid on
    
    legend(dispositiviLegenda, "Location","southwest");

end