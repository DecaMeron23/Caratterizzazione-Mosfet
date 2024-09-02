classdef PLOT_ID_VGS_VDS
    % Classe per esegure tutti i plot di "ID-Vgs" e  "Id-Vds" 

    methods (Static)

        % Funzione che esegue i plot di "ID-Vgs", per utilizzarla
        % posizionarsi nella cartella relativa all'irraggiamento da cui si
        % vuole fare i plot, chiamare la funzione con eventualmente un
        % parametro che indica a quale VDS in mV si vuole fare il plot, di
        % default è 900mV
        function ID_VGS_Raggruppata_W(VDS_mV)

            if nargin == 0
                VDS_mV = 900;
            end

            temp = split(pwd , "\");

            if ~contains(temp , "Chip")
                error("Verificare di essere nella cartella esatta...")
            end
            
            temp = string(temp(end));

            temp = char(extractAfter(temp  , "Chip"));
            tipologia_canale = temp(2);

            ARRAY_VDS_mV = 150:150:900;
            ARRAY_W = [100 200 600];
            ARRAY_L = [30 60 180];
            ARRAY_COLORI = lines(3);
            VGS_LABEL = ["GS" , "SG"];
            ID_LABEL = ["" ," |"];
            TIPOLOGIA = ["N" , "P"];


            PREFISSO_nomePlot = "id-vgs__Vds_%d__W_%d.png";
            NOME_CARTELLA_SALVATAGGIO = "plot/id-vgs/";    
            FILE_DATI = "id-vgs.txt";

            vgs = nan(241 , 1);
            id = nan(241 , length(ARRAY_VDS_mV));

            %Estraiamo i dati
            f = @funzione;

            close all
            figure
            figure
            figure

            estrazioneCartelle.esegui_per_ogni_dispositivo(f , true);
            
            % definisco la funzine per fare i plot
            function funzione()
                
                %estraggo il nome del dispositivo
                temp = split(pwd  , "\");
                temp = split(temp(end) , "-");
                W = str2double(temp(2));
                L = str2double(temp(3));
                
                indice_figura = find(ARRAY_W == W);
                indice_colore_plot = ARRAY_L == L;
                indice_vds = ARRAY_VDS_mV == VDS_mV;

                LEGENDA = sprintf("$L = %d n m$" , L);

                [vgs , id , ~ ] = EstrazioneDati.estrazione_dati_vgs(FILE_DATI , tipologia_canale);

                figure(indice_figura);
                plot(vgs , id( : , indice_vds) , Color=ARRAY_COLORI(indice_colore_plot , :) , DisplayName= LEGENDA )
                
                hold on

            end

            x_label = sprintf("$V_{%s} [V]$" , VGS_LABEL(TIPOLOGIA == tipologia_canale));
            y_label = sprintf("$%sI_{D}%s [A]$" , ID_LABEL(TIPOLOGIA == tipologia_canale) , ID_LABEL(TIPOLOGIA == tipologia_canale));
            posizione_legenda = "northwest";
            
            if ~exist(NOME_CARTELLA_SALVATAGGIO , "dir")
                mkdir(NOME_CARTELLA_SALVATAGGIO);
            end


            for i = 1 : 3
                figure(i)
                titolo = sprintf("%sMOS $%d \\mu m$" , tipologia_canale ,  ARRAY_W(i));
                PLOT_ID_VGS_VDS.grafica_plot(titolo , x_label , y_label , posizione_legenda);
                grid on
                xlim([min(vgs) , max(vgs)]);

                nome_plot_salvataggio = NOME_CARTELLA_SALVATAGGIO + sprintf(PREFISSO_nomePlot , VDS_mV , ARRAY_W(i));

                saveas(gcf , nome_plot_salvataggio);

            end



        end

        % Funzione che esegue i plot di "ID-Vds", per utilizzarla
        % posizionarsi nella cartella relativa all'irraggiamento da cui si
        % vuole fare i plot, chiamare la funzione con eventualmente un
        % parametro che indica a quale VGS in mV si vuole fare il plot, di
        % default è 900mV
        function ID_VDS_Raggruppata_W(VDS_mV)

            if nargin == 0
                VDS_mV = 900;
            end

            temp = split(pwd , "\");

            if ~contains(temp , "Chip")
                error("Verificare di essere nella cartella esatta...")
            end
            
            temp = string(temp(end));

            temp = char(extractAfter(temp  , "Chip"));
            tipologia_canale = temp(2);

            ARRAY_VGS_mV = 150:150:900;
            ARRAY_W = [100 200 600];
            ARRAY_L = [30 60 180];
            ARRAY_COLORI = lines(3);
            VDS_LABEL = ["DS" , "SD"];
            ID_LABEL = ["" ," |"];
            TIPOLOGIA = ["N" , "P"];


            PREFISSO_nomePlot = "id-vds__Vgs_%d__W_%d.png";
            NOME_CARTELLA_SALVATAGGIO = "plot/id-vds/";    
            FILE_DATI = "id-vds.txt";

            vds = nan(181 , 1);
            id = nan(181 , length(ARRAY_VGS_mV));

            %Estraiamo i dati
            f = @funzione;

            close all
            figure
            figure
            figure

            estrazioneCartelle.esegui_per_ogni_dispositivo(f , true);
            
            % definisco la funzine per fare i plot
            function funzione()
                
                %estraggo il nome del dispositivo
                temp = split(pwd  , "\");
                temp = split(temp(end) , "-");
                W = str2double(temp(2));
                L = str2double(temp(3));
                
                indice_figura = find(ARRAY_W == W);
                indice_colore_plot = ARRAY_L == L;
                indice_vds = ARRAY_VGS_mV == VDS_mV;

                LEGENDA = sprintf("$L = %d n m$" , L);

                [vds , id , ~ ] = EstrazioneDati.estrazione_dati_vds(FILE_DATI , tipologia_canale);

                figure(indice_figura);
                plot(vds , id( : , indice_vds) , Color=ARRAY_COLORI(indice_colore_plot , :) , DisplayName= LEGENDA )
                
                hold on

            end

            x_label = sprintf("$V_{%s} [V]$" , VDS_LABEL(TIPOLOGIA == tipologia_canale));
            y_label = sprintf("$%sI_{D}%s [A]$" , ID_LABEL(TIPOLOGIA == tipologia_canale) , ID_LABEL(TIPOLOGIA == tipologia_canale));
            posizione_legenda = "southeast";
            
            if ~exist(NOME_CARTELLA_SALVATAGGIO , "dir")
                mkdir(NOME_CARTELLA_SALVATAGGIO);
            end


            for i = 1 : 3
                figure(i)
                titolo = sprintf("%sMOS $%d \\mu m$" , tipologia_canale ,  ARRAY_W(i));
                PLOT_ID_VGS_VDS.grafica_plot(titolo , x_label , y_label , posizione_legenda);
                grid on
                xlim([min(vds) , max(vds)]);

                nome_plot_salvataggio = NOME_CARTELLA_SALVATAGGIO + sprintf(PREFISSO_nomePlot , VDS_mV , ARRAY_W(i));

                saveas(gcf , nome_plot_salvataggio);

            end
        end


        % Funzione che rifinisce il plot mettendo i nomi degli assi il
        % titolo e la legenda con la posizione indicata
        function grafica_plot(titolo , x_label , y_label , posizione_legenda)
            setUpPlot();
            legend(Location= posizione_legenda , Interpreter= "latex");
            xlabel(x_label , Interpreter="latex");
            ylabel(y_label , Interpreter="latex");
            title(titolo , Interpreter="latex");
        end
    end
end