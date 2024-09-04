function Sovrapposizione_plot_deltaVth_W(file , type)
%% Posizionarsi all'interno della cartella contenente i file delle delta Vth
%plot_deltaVth questa funzione riceve come parametro una stringa che
%identifica il file da prendere es: "Delta_RM.txt" con la quale crea un
%plot e lo salva come eps, jpg e fig in una cartella all'interno dell
%folder dove è presente il file delle delta
    close all
    setUpPlot();

    file = char(file);
    % prendiamo il nome del metodo della vth
    metodo = getMetodo(file);
    %estraiamo il nome del metodo per il plot
    nome_metodo = nomeMetodo(metodo);
    
    fprintf("Esecuzione plot per il metodo '%s'\n" , nome_metodo);

    irraggiamenti = [5 50 100 200 600 1000 3000 4000]; %Il 4000 corrisponde all'annealing
    delta_Vth = readmatrix(file);

    
    ARRAY_W = [100 200 600];
    ARRAY_L = [30 60 180];
    ARRAY_COLORI = lines(3);


    % escludiamo la prima colonna che contiene solo il nome dei dispositivi
    delta_Vth = delta_Vth(: , 2:end);

    %verficichiamo se non esiste la cartella
    cartella = "plot_" + metodo;
    if ~exist(cartella , "dir")
        mkdir(cartella)
        mkdir(cartella+ "\eps")
        mkdir(cartella+ "\fig")
        mkdir(cartella+ "\png")
    end
    
    cd(cartella);

    indice_dispositivo = 0;
    
    % per ogni dimensione di W
    for W = ARRAY_W 

        %eseguiamo il plot per il singolo dispositivo
        figure
        hold on

        indice_colore = 0;
        for L = ARRAY_L

            indice_dispositivo = indice_dispositivo + 1;
            indice_colore = indice_colore + 1;
            
            % se la somma delle delta VTH è zero non la plottiamo
            if sum(delta_Vth(indice_dispositivo , :)) ~=0
                plot(irraggiamenti(1:width(delta_Vth)) , delta_Vth(indice_dispositivo , :) , ...
                    "Color" , ARRAY_COLORI(indice_colore , :) , "Marker" ,"square" , ...
                    "DisplayName" , sprintf("$L = %d nm$" , L));
            end
        end
        yl = yline(0 , "-.");
        yl.Annotation.LegendInformation.IconDisplayStyle = 'off';  % Escludi dalla leggenda
        
        title(sprintf("$W = %d \\mu m$" , W) , Interpreter="latex");
        xlabel("\textit{TID} $[Mrad]$" , Interpreter= "latex");
        ylabel("$\Delta V_{th}$ $[mV]$", Interpreter="latex");
        
        legend("Location","northwest" , Interpreter="latex")
        
        % Impostazione degli xtick
        xticks([1 5 10 100 1000 4000]);
        xlim([irraggiamenti(1) , irraggiamenti(end)]);

        % Impostazione delle etichette degli xtick
        xticklabels({"1" , "5" , "10", "100" , "1000" , "annealing"});

        set(gca , "XScale" , "log")
        
        hold off
        grid on
        
        ARRAY_TIPOLOGIA_FILE = ["eps" "png" "fig"];

        NOME_FILE = sprintf("%ssovrapposizione-deltaVth-%s-%s%d.%s" , "%s" , metodo , type , W , "%s");
    
        for file = ARRAY_TIPOLOGIA_FILE
            saveas(gcf , sprintf(NOME_FILE , file+"\" , file));
        end    
    end
    cd ..
end

%% Funzione che estrae dal nome del file il nome del metodo
function metodo = getMetodo(file)
    
    metodo = extractAfter(file , "Delta_");
    metodo = extractBefore(metodo , ".txt");

end

%% Funzione da implementare, serve per tornare il nome del metodo da mettere nel titolo del plot
function nome = nomeMetodo(metodo)
    if metodo == "TCM"
    elseif metodo == "SDLM"
    elseif metodo == "RM_pre"
    elseif metodo == "RM"
    elseif metodo == "FIT"
    end

    nome  = metodo;
end

%% Funzione che modifica la legenda, non esce bene, non usare
function  legenda = getLegenda(dispositivi)

    for i = 1 :length(dispositivi)
        legenda(i) = "Dispositivo " + dispositivi(i);
    end

end
    

