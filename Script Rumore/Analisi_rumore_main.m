%% Posizionarsi nella cartella che contiene tutti i dispositivi ad una certa
%% quantità di radiazioni

tic;
% trovo la directory in cui ci troviamo
directory = dir();
% Lista dei file nella cartella
lista_dispositivi = {directory.name};
% tolgo dalla lista dei dispositivi . .. e, se esiste, rumore_finale
lista_dispositivi(1:2) = [];
if exist("rumore_finale","dir")
    lista_dispositivi(end) = [];
end
% verifichiamo se ci sono dei file nella cartella
if isempty(lista_dispositivi)
    error("Cartella del livello di irraggiamento è vuota...")
else

    %scorro tutte i dispositivi
    for i = 1:length(lista_dispositivi)
        dispositivo = char(lista_dispositivi(i));
        disp("["+i +"/" + length(lista_dispositivi) +"]"+ "Inizio dispositivo: " + dispositivo);
        cd(dispositivo);
        directory = dir();
        directory([directory.isdir] == 0) = [];
        lista_correnti = {directory.name};
        lista_correnti(1:2) = [];
    
        %scorro tutte le correnti all'interno di un dispositivo
        for j = 1:length(lista_correnti)
            corrente = char(lista_correnti(j));
            disp("      > " + corrente + "...");
            cd(corrente)
            directory = dir();
            lista_misure = {directory.name};
            lista_misure(1:2) = [];

            noise = '';
            fondo = '';
            fdt = '';
            
            %scorro tutti i file di una corrente, scovando noise, fondo
            %e fdt. Poi ne faccio l'analisi
            for k = 1:length(lista_misure)
                misura = char(lista_misure(k));
                if length(misura) >= 7 %se il nome del file è piu' corto di otto caratteri non posso fare la successive comparazioni
                    if strcmp(misura(1:7), 'noise_N') || strcmp(misura(1:7), 'noise_P')
                        noise  = misura;
                    elseif strcmp(misura(1:7), 'fondo_P') || strcmp(misura(1:7), 'fondo_N')
                        fondo  = misura;
                    elseif strcmp(misura(1:5), 'fdt_P') || strcmp(misura(1:5), 'fdt_N')
                        fdt  = misura;
                    end
                end
                if ~strcmp(noise, '') && ~strcmp(fondo, '') && ~strcmp(fdt, '')
                    Analisi_rumore(fondo, noise, fdt);
                end
            end

            cd ..;
        end
    
        cd ..;
        disp("["+i +"/" + length(lista_dispositivi) +"]"+ "Fine dispositivo: " + dispositivo);
    end
end
disp("Tempo Trascorso: " + toc + "s");