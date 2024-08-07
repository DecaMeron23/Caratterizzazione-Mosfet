function plot_delta_gm_tutti()
    
    %estraiamo la tipologia del dispositivo
    cartella_attuale = pwd;

    % estraiamo la tipologia del dispositivo P o N
    tipologia = char(extractAfter(cartella_attuale , "Misure statiche\"));
    tipologia = tipologia(1);
    
    % creiamo tutte le vds
    vds = 0.15:0.15:0.9;

    for i = 1:length(vds)
        disp("Esecuzione plot per la tensione "+ vds(i) +"V...");
        figure
        plot_delta_gm_tutti_singola_tensione(vds(i) , tipologia)
    end

end

function plot_delta_gm_tutti_singola_tensione(vds ,tipologia)
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
    titolo = tipologia+"MOS $V_{GS} = " + vds + "V$";
    ytickformat('percentage');
    title(titolo, Interpreter="latex" , FontSize=12);
    ylabel("$ \% \Delta g_m$" , Interpreter="latex" , FontSize=12);
    xlabel("Dose Assorbita $[Mrad]$" , Interpreter="latex" , FontSize=12);

    y_line = yline(0 , "--");
    y_line.Annotation.LegendInformation.IconDisplayStyle = 'off';
    grid on
    
    legend('Location', 'best' ,'NumColumns', 3, 'Interpreter', 'latex' ,'FontSize', 10 );
    
    if(~exist("Plot" , "dir"))
        mkdir plot
    end

    cd plot
    
    vds_str = char(string(vds));
    pos = strfind(vds_str, '.');

    % Modifica del carattere alla posizione trovata (cambia 'W' in 'w')
    if ~isempty(pos)
        vds_str(pos) = '_';
    end

    saveas(gca , "Delta_Gm_"+ tipologia + "MOS_Vds_"+ vds_str +".png")

    cd ..
        
end


