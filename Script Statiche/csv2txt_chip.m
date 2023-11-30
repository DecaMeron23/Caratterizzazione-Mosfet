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
    % inizzializzazione
    mod_jg = zeros(241 , 9);
    vgs = zeros(241 , 9);
    %% estraiamo le cartelle dei dispositivi e le salviamo in folders
    directory = dir();
    j = 1;
    for folder_iesima = 3 : length(directory(: , 1))
        temp = directory(folder_iesima);
        if temp.isdir == 1
            nameFolder = temp.name;
            % escludiamo la cartella plot
            if(strcmp(nameFolder , "plot") == 0 && strcmp(nameFolder,"Vth") == 0)
                folders(j) = string(nameFolder);
                j = j+1;
            end        
        end
    end
    clear j directory temp nameFolder folder_iesima

    %% per ogni cartella prendiamo il file .csv e lo trasfotmiamo in txt
    file_vds = "id_vds.csv";
    file_vgs = "id_vgs.csv";
    file_vgs2 = "id_vgs_2.csv";

    type = char(folders(1));
    type = type(1);


    legendaIg = {};


    for i = 1:length(folders)

        temp = char(folders(i));
        temp = temp(1:2);
        if(strcmp(temp , "P1") || strcmp(temp , "N4"))
            

            disp("["+i +"/" + length(folders) +"]"+ "Inizio cartella: " + folders(i));
            %entriamo nella cartella
            cd(folders(i));
    
            
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
            [~, nomeCartella, ~] = fileparts(pwd);

            fileVg = "id_vgs.txt";
            fileVg2 = "id_vgs_2.txt";
            fileVd = "id_vds.txt";
            
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

            plot_id_vgs(fileVg2 , nomeCartella);
            plot_id_vgs_semilog(fileVg2 , nomeCartella); 
            plot_gm(fileVg2 , nomeCartella);

            if(~strcmp(folders(i) , 'P1-100-180-nf'))

                [mod_id_i , vgs_i] = EstrazioneDati.estrazione_dati_ig_vgs(fileVg , type);
                [~  , W , L] = titoloPlot(folders(i));
                W = W * 1e-4; %trasformiamo in cm
                L = L * 1e-4;
                mod_jg(: , i) = mod_id_i / (W * L);
                vgs(: , i) = vgs_i;
                legendaIg{end+1} = folders(i);

            end
            %usciamo dalla cartella
            cd ..
    
            disp("["+i +"/" + length(folders) +"]"+ "Fine cartella: " + folders(i));
        end
    end
    %% Plot della Ig

    if(~exist("plot" , "file"))
        mkdir plot;
    end

    legendaIg = string(legendaIg);

    disp("Inizio plot ig")
    plot_jg_vgs(mod_jg , vgs  , type , legendaIg);
    disp("Fine plot ig")
    
    
    %% end
    set(0,'DefaultFigureVisible','on');
    warning('on', 'all');
    disp("Tempo Trascorso: " + toc + "s");
end