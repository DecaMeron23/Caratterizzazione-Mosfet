function Sovrapposizione_plot_deltaVth_W(file)
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

    % per ogni dimensione di W
    for i=0:2
        W = (i+1)*100;
        if W == 300
            W = 600;
        end
        %eseguiamo il plot per il singolo dispositivo
        figure
        hold on
        for j = 3*i+1 : 3*(i+1)
            if sum(delta_Vth(j , :))~=0
                plot(irraggiamenti(1:width(delta_Vth)) , delta_Vth(j , :) , "-s");
            end
        end
        yline(0 , "-.") 
        title("Delta Vth " + nome_metodo +" W = "+ W );
        xlabel("$Mrad$" , Interpreter= "latex");
        ylabel("$\Delta V_{th}$", Interpreter="latex");
        legend(dispositivi(3*i+1:3*(i+1)), "Location","northwest")
        hold off
        grid on


         cd eps
        saveas(gcf , "sovrapposizione-delta-vth-"+metodo+ "-P" + W + ".eps");
        cd ..\png
        saveas(gcf , "sovrapposizione-delta-vth-"+metodo+ "-P" + W +".png");
        cd ..\fig
        saveas(gcf , "sovrapposizione-delta-vth-"+metodo+ "-P" + W +".fig");
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
    

