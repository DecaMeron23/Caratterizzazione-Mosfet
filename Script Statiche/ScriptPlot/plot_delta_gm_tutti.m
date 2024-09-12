function plot_delta_gm_tutti()
    close all
    
    setUpPlot()

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
        % dispositiviLegenda = [ "100-0.030" "100-0.060" "100-0.0180" "200-0.030" "200-0.060" "200-0.0180" "600-0.060" "600-0.0180"];
    elseif tipologia == "P"
        dispositivi = [ "100-30" "100-60" "200-30" "200-60" "200-180" "600-30" "600-60" "600-180"];
        % dispositiviLegenda = [ "100-0.030" "100-0.060" "200-0.030" "200-0.060" "200-0.0180" "600-0.030" "600-0.060" "600-0.0180"];
    end
    for i = 1: length(dispositivi)
        % dividiamo per W
        if i ~= 1 
            temp = split(dispositivi(i) , "-");
            attuale = temp(1);
            temp  = split(dispositivi(i-1) , "-");
            prec = temp(1);
            if attuale ~= prec
                % Salviamo il plot e ne creiamo una nuova figura
                salvaPlot(tipologia , vds , W)
                figure
            end

            W = attuale;
        end

        plot_delta_gm(vds , tipologia , dispositivi(i) , false);
        hold on
        

    end
    
    salvaPlot(tipologia , vds , W)

    close all
        
end


function salvaPlot(tipologia, vds , W)
    

    titolo = tipologia+"MOS $V_{GS} = " + vds + "V$";
    ytickformat('percentage');
    title(titolo, Interpreter="latex" , FontSize=12);
    ylabel("$ \% \Delta g_m$" , Interpreter="latex" , FontSize=12);
    xlabel("\textit{TID} $[Mrad]$" , Interpreter="latex" , FontSize=12);
    testo = "$W=" + W + "\mu m $";
    annotation('textbox', [0.15, 0.20 0.1, 0.1], 'String' , testo , 'EdgeColor' , 'none' , 'FitBoxToText', 'on', FontSize=14 , Interpreter='latex' )
    y_line = yline(0 , "--");
    y_line.Annotation.LegendInformation.IconDisplayStyle = 'off';
    grid on
    
    legend('Location', 'south' ,'NumColumns', 1, 'Interpreter', 'latex' ,  FontSize=12);
    
    vds_str = char(string(vds));
    pos = strfind(vds_str, '.');
    
    % Modifica del carattere alla posizione trovata (cambia 'W' in 'w')
    if ~isempty(pos)
        vds_str(pos) = '_';
    end
    
    cartella = "plot/vds_"+vds_str;
    
    if(~exist(cartella , "dir"))
        mkdir(cartella)
    end
    
    cd(cartella)
    setUpPlot()
    saveas(gcf , "Delta_Gm_"+ tipologia + "MOS_Vds_"+ vds_str +"_W_"+W+".png")

    cd ..\..
end