function csv2txt(file)
%   file: nome del file .csv
    file = char(file);
    data = readmatrix(file);
    type_file = file(5);
    %% contiamo il numero diverso di vg che esistono
    vg = data(: , 2);
    vg = sort(vg)';
    temp = vg(1);
    num_vg = 1;
    % contiamo il numero di vg
    for vg_i = vg
        if vg_i ~= temp
            num_vg = num_vg + 1;
            temp = vg_i;
        end
    end   
    clear vg temp vg_i
    
    %% Dividaimo le righe in colonne
    %numero di vds per vg
    num_vds = height(data) / num_vg;
    dati_finali = zeros(num_vds , num_vg + 1);
    ind_correnti = 3 : width(data);
    num_correnti  = length(ind_correnti);

    for i  = 1 : num_vg
        indici_colonne_dati_finali = (num_correnti * (i-1) + 1) : num_correnti*i;
        indici_righe_data = ((num_vds * (i-1)) + 1):num_vds*i;
        dati_finali(1 : num_vds , indici_colonne_dati_finali) = data(indici_righe_data , ind_correnti );
    end
    
    dati_finali = [ data(1:num_vds,1) , dati_finali];
    % vettore contenente tutte le vg (nel caso il file sia 'id-vds.csv') 
    vg = unique(data(: , 2));
    
    [ ~ , nome_cartella  , ~]  = fileparts(pwd);
     
    if nome_cartella(1) == 'P'
        vg  = flipud(0.9 - vg);
    end

    % creaiamo i nomi delle diverse colonne
    name_table = "v" + type_file;
    for vg_i = vg'
        if type_file == 'g'
            name_table = [name_table ,"id_vd = " + vg_i+ "V" ,  "ig_vd = " + vg_i+ "V" , "is_vd = " + vg_i+ "V" ,"iavdd_vd = " + vg_i+ "V" , "ignd_vd = " + vg_i+ "V"];
        elseif type_file == 'd'
            name_table = [name_table ,"id_vg = " + vg_i+ "V" ,  "ig_vg = " + vg_i+ "V" , "is_vg = " + vg_i+ "V" ,"iavdd_vg = " + vg_i+ "V" , "ignd_vg = " + vg_i+ "V"];
        end
        
    end
    dati_finali = array2table(dati_finali , "VariableNames", name_table);
    %% Salvo il file nella cartella attuale
    writetable(dati_finali  , file(1:(end-4)) , "FileType", "text", "Delimiter", "\t");
end