function csv2txt_chip(path)
%%   trasforma i file .csv in file .txt e fa i plot necessari
%   path è la directory del chip che vogliamo analizzare   
     if nargin == 0
        % Se la funzione è chiamata senza argomenti, utilizza la directory corrente
        path = pwd;
     end

    tic;
    cd(path);
    % disabilitiamo i plot
    set(0,'DefaultFigureVisible','off');
    %disabilitiamo i warnign
    warning('off', 'all');
    %% estraiamo le cartelle dei dispositivi e le salviamo in folders
    directory = dir();
    folders = {};
    for folder_iesima = 3 : length(directory(: , 1))
        temp = directory(folder_iesima);
        if temp.isdir == 1
            nameFolder = temp.name;
            % escludiamo la cartella plot
            if((contains(nameFolder , "P") || contains(nameFolder , "N")) && contains(nameFolder , "-"))
                folders{end+ 1} = nameFolder;
            end        
        end
    end

    % per ogni cartella prendiamo il file .csv e lo trasfotmiamo in txt
    canale_dispositivo = char(folders(1));
    canale_dispositivo = canale_dispositivo(1);

    % Legenda per il plot di I_g
    legendaIg = {};

    % Scorriamo tutti i dispositivi
    for i = 1:length(folders)
        close all

        % estraiamo la cartella attuale
        cartella_attuale = char(folders(i));
         
        disp("["+i +"/" + length(folders) +"]"+ "Inizio cartella: " + cartella_attuale);
        % entriamo nella cartella
        cd(cartella_attuale);
        
        % definiamo i nomi dei file
        file_vds_csv = "id-vds.csv";
        file_vgs_csv = "id-vgs.csv";
        file_vgs2_csv = "id-vgs_2.csv";
        
        % Se sono stati nominati in modo sbagliato li rinominiamo
        cambia_nome(file_vds_csv , "id_vds.csv");
        cambia_nome(file_vgs_csv , "id_vgs.csv");

        cambia_nome(file_vgs2_csv, "id_vgs_2.csv");
        cambia_nome(file_vgs2_csv, "id-vgs-2.csv");
        cambia_nome(file_vgs2_csv, "id_vgs-2.csv");

        %verifichiamo se esistono i file
        verifica_file(file_vds_csv);
        verifica_file(file_vgs_csv);
        verifica_file(file_vgs2_csv);

        % convertiamo il file in txt
        csv2txt(file_vds_csv);
        csv2txt(file_vgs_csv);
        csv2txt(file_vgs2_csv);
    
        % creaiamo le cartelle necessarie
        cartella_plot = "plot";
        mkdir(cartella_plot + "/eps");
        mkdir(cartella_plot + "/png");

        % Creaiamo e salviamo i plot
        [~, nomeCartella, ~] = fileparts(pwd);

        % Definiamo i nomi dei file csv
        file_vds_txt = "id-vds.txt";
        file_vgs_txt = "id-vgs.txt";
        file_vgs2_txt = "id-vgs-2.txt";

        [vds , id , vgs] = EstrazioneDati.estrazione_dati_vds(file_vds_txt , canale_dispositivo);
        DatiVd{1} = vds;
        DatiVd{2} = id;
        DatiVd{3} = vgs;

        [vgs , id , vds] = EstrazioneDati.estrazione_dati_vgs(file_vgs_txt , canale_dispositivo);
        DatiVg{1} = vgs;
        DatiVg{2} = id;
        DatiVg{3} = vds;

        plot_id_vds(file_vds_txt , nomeCartella , DatiVd);
        
        plot_id_vgs(file_vgs_txt , nomeCartella , DatiVg);
        
        plot_id_vgs_semilog(file_vgs_txt , nomeCartella , DatiVg); 
        
        plot_gm(file_vgs_txt , nomeCartella , DatiVg);
        
        plot_gds(file_vds_txt , nomeCartella , DatiVd);
        
        if(~contains(cartella_attuale , "nf"))
            plot_gm_id_w_l(file_vgs_txt , nomeCartella , DatiVg);
        end

        % se esiste il file vgs2 
        if exist(file_vgs2_txt , "file")
            plot_id_vgs(file_vgs2_txt , nomeCartella);
            plot_id_vgs_semilog(file_vgs2_txt , nomeCartella); 
            plot_gm(file_vgs2_txt , nomeCartella);
        end

        % verifichiamo se il dispositivo attuale funziona
        if(~contains(cartella_attuale , "nf"))
            [mod_jg(: , i) , vgs_jg(: , i)] = EstrazioneDati.estrazione_dati_jg_vgs(file_vgs_txt , canale_dispositivo , cartella_attuale);
            legendaIg{end+1} = cartella_attuale;
        end
        

        cd ..

        disp("["+i +"/" + length(folders) +"]"+ "Fine cartella: " + cartella_attuale);
        
        % Chiudiamo tutti i plot
        close all

    end
    %% Plot della Ig

    if(~exist("plot" , "file"))
        mkdir plot;
    end

    legendaIg = string(legendaIg);

    disp("Inizio plot ig")
    plot_jg_vgs(mod_jg , vgs_jg  , canale_dispositivo , legendaIg);
    disp("Fine plot ig")
    
    
    %% end
    set(0,'DefaultFigureVisible','on');
    warning('on', 'all');
    disp("Tempo Trascorso: " + toc + "s");
end


function cambia_nome(NOME_CORRETTO , NOME_SBAGLIATO)
    if(exist(NOME_SBAGLIATO, "file"))
        movefile(NOME_SBAGLIATO , NOME_CORRETTO);
    end
end

function verifica_file(FILE)
    if(~exist(FILE , "file"))
         error('Non è stato trovate nessun file nominato: "%s"' , FILE);
    end
end