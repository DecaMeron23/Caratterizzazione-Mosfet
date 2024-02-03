function plot_deltaVth(file)
%% Posizionarsi all'interno della cartella contenente i file delle delta Vth
%plot_deltaVth questa funzione riceve come parametro una stringa che
%identifica il file da prendere es: "Delta_RM.txt" con la quale crea un
%plot e lo salva come eps, jpg e fig in una cartella all'interno dell
%folder dove è presente il file delle delta

    file = char(file);
    % prendiamo il nome del metodo della vth
    metodo = getMetodo(file);
    %estraiamo il nome del metodo per il plot
    nome_metodo = nomeMetodo(metodo);
    
    dispositivi = ["100/30" "100/60" "100/180" "200/30" "200/60" "200/180" "600/30" "600/60" "600/180"];
    irraggiamenti = [5 50 100 200 600 1000];
    delta_Vth = readmatrix(file);

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

    % per ogni dispositivo
    for i = 1: length(dispositivi)
        %eseguiamo il plot per il singolo dispositivo
        figure
        plot(irraggiamenti(1:width(delta_Vth)) , delta_Vth(i , :) , "-s");
        yline(0 , "-.") 
        title("Delta Vth " + nome_metodo +" "+  dispositivi(i));
        xlabel("$Mrad$" , Interpreter= "latex");
        ylabel("$\Delta V_{th}$", Interpreter="latex");
        grid on
    
        dispositivo = strrep(dispositivi(i) ,"/"  , "-");


        cd eps
        saveas(gcf , "delta_vth_" + dispositivo + "_"+metodo+ ".eps");
        cd ..\png
        saveas(gcf , "delta_vth_" + dispositivo + "_"+metodo+ ".png");
        cd ..\fig
        saveas(gcf , "delta_vth_" + dispositivo + "_"+metodo+ ".fig");
        cd ..
    end    
    cd ..
    close all
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
    

