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
    path = pwd;
    pathParts = strsplit(path, filesep);
    cartella = char(pathParts{end});
    type = cartella(6) + ""+ cartella(5);
    % estraiamo le cartelle necessarie
    folders = estrazioneCartelle.getFileCartella(type); % le cartelle dovrebbero essere in ordine per W
    
    % prendiamo solo le cartelle
    folders = estrazioneCartelle.getSoloCartelle(folders);

    %% per ogni cartelle.getSoloCartella prendiamo il file .csv e lo trasfotmiamo in txt

    type = char(string(folders(1)));
    type = type(1);


    legendaIg = {};

    for i = 1:length(folders)

        
        cartella_attuale = char(string(folders(i)));
         
        disp("["+i +"/" + length(folders) +"]"+ "Inizio cartella: " + cartella_attuale);
        %entriamo nella cartella
        cd(cartella_attuale);


        % Cerchiamo i file da convertire
        file_vds = "id_vds.csv";

        if(~exist(file_vds , "file"))
            file_vds = "id-vds.csv";
        end
    
        file_vgs = "id_vgs.csv";
    
        if(~exist(file_vgs , "file"))
            file_vgs = "id-vgs.csv";
        end
    
    
        file_vgs2 = "id_vgs_2.csv";
    
        if(~exist(file_vgs2 , "file"))
            file_vgs2 = "id-vgs_2.csv";
        end

        
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
    
        if ~contains(cartella_attuale , "nf") %se il dispositivo è funzionante
            %% creaiamo le cartelle necessarie
            
            cartella_plot = "plot";
            
            mkdir(cartella_plot);
            
    
            cd plot\
            
            mkdir eps;
           
            mkdir png;
       
    
            cd ..
    
            %% salviamo i plot

            disp("Salvataggio plot...")
            [~, nomeCartella, ~] = fileparts(pwd);
    
            fileVg = "id_vgs.txt";
            if(exist("id-vgs.txt"))
               fileVg = "id-vgs.txt"; 
            end
            fileVg2 = "id_vgs_2.txt";
            if(exist("id-vgs-2.txt"))
               fileVg2 = "id-vgs-2.txt"; 
            end
            fileVd = "id_vds.txt";
            if(exist("id-vds.txt"))
               fileVd = "id-vds.txt"; 
            end
    
            [vds , id , vgs] = EstrazioneDati.estrazione_dati_vds(fileVd , type);
            DatiVd{1} = vds;
            DatiVd{2} = id;
            DatiVd{3} = vgs;
    
            [vgs , id , vds] = EstrazioneDati.estrazione_dati_vgs(fileVg , type);
            DatiVg{1} = vgs;
            DatiVg{2} = id;
            DatiVg{3} = vds;
    
            plot_id_vds(fileVd , nomeCartella , DatiVd);
            plot_id_vgs(fileVg , nomeCartella , DatiVg);
            plot_id_vgs_semilog(fileVg , nomeCartella , DatiVg); 
            plot_gm(fileVg , nomeCartella , DatiVg);
            plot_gds(fileVd , nomeCartella , DatiVd);
            plot_gm_id_w_l(fileVg , nomeCartella , DatiVg);

            if exist(fileVg2 , "file")
                plot_id_vgs(fileVg2 , nomeCartella);
                plot_id_vgs_semilog(fileVg2 , nomeCartella); 
                plot_gm(fileVg2 , nomeCartella);
            end
            if(~contains(cartella_attuale , "P1-100-180-nf"))
                [mod_jg(: , i) , vgs_jg(: , i)] = EstrazioneDati.estrazione_dati_jg_vgs(fileVg , type , cartella_attuale);
                legendaIg{end+1} = cartella_attuale;
            end
            
            
    
            
        
        end
        disp("["+i +"/" + length(folders) +"]"+ "Fine cartella: " + cartella_attuale);
        %usciamo dalla cartella
        cd ..
    end
    %% Plot della Ig

    mkdir plot;

    legendaIg = string(legendaIg);

    disp("Inizio plot ig")
    plot_jg_vgs(mod_jg , vgs_jg  , type , legendaIg);
    disp("Fine plot ig")
    
    
    %% end
    set(0,'DefaultFigureVisible','on');
    warning('on', 'all');
    disp("Tempo Trascorso: " + toc + "s");
    close all
end