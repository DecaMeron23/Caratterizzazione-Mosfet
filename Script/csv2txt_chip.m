function csv2txt_chip(path)
%   trasforma i file .csv in file .txt
%   path è la directory del chip che vogliamo analizzare   
    tic;
    cd(path);

    %% estraiamo le cartelle dei dispositivi e le salviamo in folders
    directory = dir();
    j = 1;
    for folder_iesima = 3 : length(directory(: , 1))
        temp = directory(folder_iesima);
        if temp.isdir == 1
            nameFolder = temp.name;
            folders(j) = string(nameFolder);
            j = j+1;
        end
    end

    clear j directory temp nameFolder folder_iesima

    %% per ogni cartella prendiamo il file .csv e lo trasfotmiamo in txt
    file_vds = "id_vds.csv";
    file_vgs = "id_vgs.csv";
    file_vgs2 = "id_vgs_2.csv";

    for i = 1:length(folders)

        disp("["+i +"/" + length(folders) +"]"+ "Inizio cartella: " + folders(i));
        %entriamo nella cartella
        cd(folders(i));

        type = char(folders(i));
        type = type(1);

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
    
        %% creaiamo le cartelle necessarie
        cartella_plot = "plot";
        if(~exist(cartella_plot , "file"))
            mkdir(cartella_plot);
        end

        cd plot\
        
        if(~exist("eps" , "file"))
            mkdir eps;
        end

        if(~exist("png" , "file"))
            mkdir png;
        end

        cd ..

        %% salviamo i plot
       
        fileVg = "id_vgs.txt";
        fileVg2 = "id_vgs_2.txt";
        fileVd = "id_vds.txt";
        
        plot_id_vds(fileVd , type);
        plot_id_vgs(fileVg , type);
        plot_id_vgs_semilog(fileVg , type); 
        plot_gm(fileVg , type);
        plot_gds(fileVd , type);
        
        plot_id_vgs(fileVg2 , type);
        plot_id_vgs_semilog(fileVg2 , type); 
        plot_gm(fileVg2 , type);
        
        %usciamo dalla cartella
        cd ..

        disp("["+i +"/" + length(folders) +"]"+ "Fine cartella: " + folders(i));
    end

    disp("Tempo Trascorso: " + toc + "s");
end