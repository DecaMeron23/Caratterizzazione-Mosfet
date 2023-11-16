function ordina(file)
    
    data = readmatrix(file);
    parametri = unique(data(: , 2)); %vettore dei valori del parametro
    num_correnti= length(data(1 , 3:end));
    num_colonne = size(data,1) / length(parametri);

    ordinato = (data(1 : num_colonne, 1));

    for i = 1:length(parametri)
        riga_inizio = 1+(i-1)*num_colonne;
        riga_fine = i*num_colonne;
        ordinato = [ordinato data(riga_inizio : riga_fine , 3 : end)];

    end

    
    
end