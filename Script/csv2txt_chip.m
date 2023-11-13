function csv2txt_chip(path)
%   trasforma i file .csv in file .txt
%   path è la directory del chip che vogliamo analizzare   

    cd(path);

    %% estraiamo le cartelle dei dispositivi e le salviamo in folders
    directory = dir();
    j = 1;
    for i = 3 : length(directory(: , 1))
        temp = directory(i);
        if temp.isdir == 1
            nameFolder = temp.name;
            folders(j) = string(nameFolder);
            j = j+1;
        end
    end
    clear j directory temp nameFolder i

    %% per ogni cartella prendiamo il file .csv e lo trasfotmiamo in txt
    file_vds = "id_vds.csv";
    file_vgs = "id_vgs.csv";
    file_vgs2 = "id_vgs_2.csv";

    for i = folders
        %entriamo nella cartella
        cd(i);

        %verifichaimo se esiste il file
        if exist(file_vds , "file")
            % convertiamo il file in txt
            csv2txt(file_vds);
        end
        
        if exist(file_vgs , "file")
            csv2txt(file_vgs);
        end

        if exist(file_vgs2 , "file")
            csv2txt(file_vgs2);
        end

        cartella_plot = "plot";
        if(~exist(cartella_plot , "file"))
            mkdir(cartella_plot);
        end
        %% salviamo i plot
        cd(cartella_plot);        
    
        %facciamo i plot e li salviamo

        %usciamo dalla cartella
        cd ..
    end
end