function [titolo, W , L] = titoloPlot(nomeCartella)
    
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
    W = str2double(larghezzaCanale);
    L = str2double(lunghezzaCanale);

end