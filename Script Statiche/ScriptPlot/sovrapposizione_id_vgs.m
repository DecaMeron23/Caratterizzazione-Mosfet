function sovrapposizione_id_vgs(dispositivo) % il dispositivo in formato: "200-30"
    %% Obbiettivo: fornire un plot di come varia la caratteristica id-vgs al variare della dose 
    % posizionarsi nella cartella contenente le cartelle dei siversi
    % irragiamenti
    
    %% Giallo -> Rosso
    colors = [
    1, 1, 0;       % Giallo chiaro
    1, 0.8627, 0;  % Giallo
    1, 0.7059, 0;  % Giallo-arancione
    1, 0.5490, 0;  % Arancione
    1, 0.3922, 0;  % Arancio-rosso
    1, 0, 0;       % Rosso
    0.7059, 0, 0   % Rosso scuro
    ];

    %% Verdi
    % colors = [
    % 0.267004, 0.004874, 0.329415;
    % 0.283072, 0.130895, 0.449241;
    % 0.262138, 0.242286, 0.520837;
    % 0.220057, 0.357622, 0.552862;
    % 0.177423, 0.477504, 0.558148;
    % 0.141667, 0.586855, 0.534523;
    % 0.123069, 0.685407, 0.478975;
    % 0.150361, 0.7749,   0.406254;
    % 0.305394, 0.843443, 0.330553;
    % 0.585721, 0.894248, 0.20803;
    % ];


    [cartelle, tipologia]= estrazioneCartelle.getCartelle();
    
    %inizializziamo la legenda
    legenda = ["Pre" "5Mrad" "50Mrad" "100Mrad" "200Mrad" "600Mrad" "1Grad"];
    
    figure

    main = axes;
    %% plot dentro plot
    % create a new pair of axes inside current figure
    zoom = axes('position',[.215 .5 .35 .35]);
    box on % put box around new pair of axes


    for i = 1 : length(cartelle)
    
        cartella_i = string(cartelle(i));
        cd(cartella_i);
        
        % troviamo le cartelle che contengono la stringa dispositivo (mi aspetto che ce ne sia solo una)
        cartellaDispositivo = estrazioneCartelle.getFileCartella(dispositivo);
    
        % entriamo nella cartella
        cd(string(cartellaDispositivo(1)));

        file = "id-vgs.txt";
        if (~exist(file,  "file"))
            file = "id_vgs.txt";
        end

        %estraiamo i dati
        [vgs , id , ~] = EstrazioneDati.estrazione_dati_vgs(file , tipologia);
    
        % prendiamo a max vgs per i P max vsg
        id = id(: , end)*1e3;
        hold(main, 'on')
        %semilogy(vgs , id , LineWidth=1);  
        plot(main , vgs , id  ,LineWidth=1 , Color=colors(i ,: ));
        hold(main ,"off")
        
        indexOfInterest = (vgs >= 0.6) & (vgs <= 0.65);
        hold(zoom , "on")
        plot(zoom ,vgs(indexOfInterest) , id(indexOfInterest) , LineWidth=1 , Color=colors(i ,: )) % plot on new axes
        hold(zoom , "on")
        cd ../..
    end
    %per allineare i dati e il plot
    axis(main, 'tight');
    axis(zoom, 'tight');
    xlim(main ,[0.2 , 0.9]);
    xlim(zoom , [0.6 , 0.65])

    [minY , maxY] = getYZoomLimit(main , zoom);
    
    %ylim(zoom , [minY maxY]);
    axis(zoom, 'tight');
    
    dispositivo = char(dispositivo);
    W = dispositivo(1:3);
    L = "0.0"+dispositivo(5:end);

    ylabel(main , "$I_{d}[mA]$" , Interpreter="latex" , FontSize=12);
    xlabel(main , "$V_{GS}[V]$" , Interpreter="latex" , FontSize= 12);
    title(main , "Dispositivo $"+ W + "/"+ L +"$" , Interpreter="latex" , FontSize= 12);
    legend(main , legenda , "Location","southeast");


    ylabel(zoom , "$I_{d}[mA]$" , Interpreter="latex" , FontSize=12);
    xlabel(zoom , "$V_{GS}[V]$" , Interpreter="latex" ,FontSize=12);
    grid(zoom , "on");
    grid(zoom , "minor");

    hold off

end

%% non più utilizzata
% questa funzione serve per estrarre i limiti y del subplot
function [minY , maxY] = getYZoomLimit(main_plot , zoom_plot)
    
    ym = get(main_plot , "YLim");
    xm = get(main_plot , "XLim");
    yz = get(zoom_plot , "YLim");
    xz = get(zoom_plot , "XLim");

    ym = ym(2) - ym(1); 
    xm = xm(2) - xm(1);
    xz = xz(2) - xz(1);

    yz_calcolato = xz * ym / xm;

    minY = yz(1);
    maxY = yz(1) + yz_calcolato;


end