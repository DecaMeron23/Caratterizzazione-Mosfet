function titolo = titoloPlot(nomeCartella)
    
    type = nomeCartella(1);
    % Dividi la stringa usando il carattere "-"
    tokens = strsplit(nomeCartella, '-');
    
    % Estrai i componenti
    tipoTransistor = type + "MOS";
    lunghezzaCanale = tokens{2};
    larghezzaCanale = tokens{3};
    
    % Converti la larghezza del canale in formato corretto
    larghezzaCanale = sprintf('%.3f', str2double(larghezzaCanale) / 1000);
    
    % Costruisci la nuova stringa
    titolo = sprintf('%s %s/%s', tipoTransistor, lunghezzaCanale, larghezzaCanale);

end