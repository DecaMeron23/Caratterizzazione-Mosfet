classdef csv2txt
    % csv2txt: Questa classe provvede a trasformare i file CSV in TXT,
    % inoltre crea tutti i principali plot: id-vds, id-vgs
    % (anche semilogaritmica) gm-vgs, gds-vds, id-gm (id * L/W) e il plot
    % della jg-vgs (jg /(L*W))
    methods(Static, Access = private)
        function singolo_file(file)
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
    end
       
    methods (Static)

        function chip(path)
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
            file_vds = "id-vds.csv";
            file_vgs = "id-vgs.csv";
            file_vgs2 = "id-vgs-2.csv";
            
            type = char(folders(1));
            type = type(1);
            
            
            legendaIg = {};
            
            for i = 1:length(folders)
                
                cartella_attuale = char(folders(i));
                
                disp("["+i +"/" + length(folders) +"]"+ "Inizio cartella: " + cartella_attuale);
                %entriamo nella cartella
                cd(cartella_attuale);
                
                
                %verifichaimo se esiste il file
                if exist(file_vds , "file")
                    % convertiamo il file in txt
                    csv2txt.csv2txt_singolo_file(file_vds);
                end
                
                if exist(file_vgs , "file")
                    csv2txt.csv2txt_singolo_file(file_vgs);
                end
                
                if exist(file_vgs2 , "file")
                    csv2txt.csv2txt_singolo_file(file_vgs2);
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
                if(exist("id-vgs.txt" , "file"))
                    fileVg = "id-vgs.txt";
                end
                fileVg2 = "id_vgs_2.txt";
                if(exist("id-vgs-2.txt" , "file"))
                    fileVg2 = "id-vgs-2.txt";
                end
                fileVd = "id_vds.txt";
                if(exist("id-vds.txt" , "file"))
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
    end
end