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
            if(contains(nameFolder , "P1") || contains(nameFolder , "N4"))
                folders{end+ 1} = nameFolder;
            end        
        end
    end
    clear j directory temp nameFolder folder_iesima

    %% per ogni cartella prendiamo il file .csv e lo trasfotmiamo in txt
    type = char(folders(1));
    type = type(1);


    legendaIg = {};

    for i = 1:length(folders)
        
        cartella_attuale = char(folders(i));
         
        disp("["+i +"/" + length(folders) +"]"+ "Inizio cartella: " + cartella_attuale);
        %entriamo nella cartella
        cd(cartella_attuale);

        % cerchiamo i file da convertire
        if(exist("id_vds.csv", "file"))
            file_vds = "id_vds.csv";
        elseif(exist("id-vds.csv", "file"))
            file_vds = "id-vds.csv";
        else 
            error('Non è stato trovate nessun file nominato "id_vds.csv" o "id-vds.csv"');
        end

        if(exist("id_vgs.csv", "file"))
            file_vgs = "id_vgs.csv";
        elseif(exist("id-vgs.csv", "file"))
            file_vgs = "id-vgs.csv";
        else 
            error('Non è stato trovate nessun file nominato "id_vgs.csv" o "id-vgs.csv"');
        end
        
        if (exist("id_vgs_2.csv", "file"))
            file_vgs2 = "id_vgs_2.csv";
        elseif (exist("id-vgs_2.csv", "file")) 
            file_vgs2 = "id-vgs_2.csv";
        elseif (exist("id-vgs-2.csv", "file")) 
           file_vgs2 = "id-vgs-2.csv";
        elseif (exist("id_vgs-2.csv", "file")) 
            file_vgs2 = "id_vgs-2.csv";
        else 
            error('Non è stato trovate nessun file nominato "id_vgs_2.csv" o "id-vgs_2.csv" o "id-vgs-2.csv" o "id_vgs-2.csv"');
        end

        % convertiamo il file in txt
        csv2txt(file_vds);
        csv2txt(file_vgs);
        csv2txt(file_vgs2);
    
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
        [~, nomeCartella, ~] = fileparts(pwd);

        if(exist("id_vds.txt", "file"))
            fileVd = "id_vds.txt";
        elseif(exist("id-vds.txt", "file"))
            fileVd = "id-vds.txt";
        else 
            error('Non è stato trovate nessun file nominato "id_vds.txt" o "id-vds.txt"');
        end

        if(exist("id_vgs.txt", "file"))
            fileVg = "id_vgs.txt";
        elseif(exist("id-vgs.txt", "file"))
            fileVg = "id-vgs.txt";
        else 
            error('Non è stato trovate nessun file nominato "id_vgs.txt" o "id-vgs.txt"');
        end
        
        if (exist("id_vgs_2.txt", "file"))
            fileVg2 = "id_vgs_2.txt";
        elseif (exist("id-vgs_2.txt", "file")) 
            fileVg2 = "id-vgs_2.txt";
        elseif (exist("id-vgs-2.txt", "file")) 
           fileVg2 = "id-vgs-2.txt";
        elseif (exist("id_vgs-2.txt", "file")) 
            fileVg2 = "id_vgs-2.txt";
        else 
            error('Non è stato trovate nessun file nominato "id_vgs_2.txt" o "id-vgs_2.txt" o "id-vgs-2.txt" o "id_vgs-2.txt"');
        end

        [vds , id , vgs] = EstrazioneDati.estrazione_dati_vds(fileVd , type);
        DatiVd{1} = vds;
        DatiVd{2} = id;
        DatiVd{3} = vgs;

        [vgs , id , vds] = EstrazioneDati.estrazione_dati_vgs(fileVg , type);
        DatiVg{1} = vgs;
        DatiVg{2} = id;
        DatiVg{3} = vds;

        % plot_id_vds(fileVd , nomeCartella , DatiVd);
        % plot_id_vgs(fileVg , nomeCartella , DatiVg);
        % plot_id_vgs_semilog(fileVg , nomeCartella , DatiVg); 
        plot_gm(fileVg , nomeCartella , DatiVg);
        % plot_gds(fileVd , nomeCartella , DatiVd);
        % plot_gm_id_w_l(fileVg , nomeCartella , DatiVg);

        % if exist(fileVg2 , "file")
        %     plot_id_vgs(fileVg2 , nomeCartella);
        %     plot_id_vgs_semilog(fileVg2 , nomeCartella); 
        %     plot_gm(fileVg2 , nomeCartella);
        % end
        if(~contains(cartella_attuale , "P1-100-180-nf"))
            [mod_jg(: , i) , vgs_jg(: , i)] = EstrazioneDati.estrazione_dati_jg_vgs(fileVg , type , cartella_attuale);
            legendaIg{end+1} = cartella_attuale;
        end
        %usciamo dalla cartella
        cd ..

        disp("["+i +"/" + length(folders) +"]"+ "Fine cartella: " + cartella_attuale);
    end
    %% Plot della Ig

    if(~exist("plot" , "file"))
        mkdir plot;
    end

    legendaIg = string(legendaIg);

    disp("Inizio plot ig")
    plot_jg_vgs(mod_jg , vgs_jg  , type , legendaIg);
    disp("Fine plot ig")
    
    
    %% end
    set(0,'DefaultFigureVisible','on');
    warning('on', 'all');
    disp("Tempo Trascorso: " + toc + "s");
end