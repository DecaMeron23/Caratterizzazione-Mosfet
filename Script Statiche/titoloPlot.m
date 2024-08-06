function [titolo, W , L , type] = titoloPlot(nomeCartella)
    %titolo: il titolo del plot (es NMOS 100/0.030)
    %W : la largezza del canale in um (es 100)
    %L : la lunghezza del canale in um (es 0.03)
    %type: il tipo del dispositivo

    type = nomeCartella(1);
    % Dividi la stringa usando il carattere "-"
    tokens = strsplit(nomeCartella, '-');
    
    % Estrai i componenti
    tipoTransistor = type + "MOS";
    larghezzaCanale = tokens{2};
    lunghezzaCanale = tokens{3};
    
    % Converti la larghezza del canale in formato corretto
    lunghezzaCanale = sprintf('%.3f', str2double(lunghezzaCanale) / 1000);
    
    % Costruisci la nuova stringa
    titolo = sprintf('%s %s/%s', tipoTransistor, larghezzaCanale, lunghezzaCanale);
    
    %sono in micro-metri
    W = str2double(larghezzaCanale);
    L = str2double(lunghezzaCanale);

end