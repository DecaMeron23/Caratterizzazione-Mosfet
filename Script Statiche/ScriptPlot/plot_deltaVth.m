function plot_deltaVth(file)
%plot_deltaVth questa funzione riceve come parametro una stringa che
%identifica il file da prendere es: "Delta_RM.txt" con la quale crea un
%plot e lo salva come eps, jpg e fig in una cartella all'interno dell
%folder dove è presente il file delle delta

    file = char(file);
    % prendiamo il nome del metodo della vth
    metodo = getMetodo(file);
    
    dispositivi = ["100/30" "100/60" "100/180" "200/30" "200/60" "200/180" "600/30" "600/60" "600/180"];
    irraggiamenti = [5 50 100 200 600 1000];
    delta_Vth = readmatrix(file);

    % escludiamo la prima colonna che contiene solo il nome dei dispositivi
    delta_Vth = delta_Vth(: , 2:end);

    figure
    hold on

    % per ogni dispositivo
    for i = 1: length(dispositivi)
        
        plot()
    end

    hold off
    

end

%% FUnzione che estrae dal nome del file il nome del metodo
function metodo = getMetodo(file)
    
    metodo = extractAfter(file , "Delta_");
    metodo = extractBefore(metodo , ".txt");

end
    

