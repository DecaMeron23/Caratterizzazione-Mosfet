classdef class_plot_gm
    %class_plot_gm classe che prevede alcuni nuovi plot (non tutti) per la
    %Gm

    methods(Static)
        % funzione che esegue i plot della gm a W costante
        % ci si deve posizionare all'interno della cartella ad un relativo
        % irraggiamento
        function gm_w_costante(vds_mV)
            setUpPlot();
            
            vds = 150:150:900;
            indice_vds = find(vds==vds_mV);
            
            close all
            
            figure
            figure
            figure

            % Definisco la funzione come una funzione di handle
            funzione = @() funzia();

            function funzia()
                %possibili W
                possibili_w = [100 , 200 ,600];
                
                cartella_attuale = split(pwd , "\");
                cartella_attuale = char(cartella_attuale(end));
                elementi = split(cartella_attuale , "-");
                W = str2double(elementi(2));
                L = str2double(elementi(3));
                type = char(upper(elementi(1)));
                type = type(1);
                %estraiamo i dati
                gm = readmatrix("gm.txt");
                
                vgs = gm(: , 1);
                gm = gm(: , indice_vds);
                
                figura = find(possibili_w == W);
                
                % apriamo la figura corrispondente
                figure(figura);
                
                % Eseguiamo il plot
                plot(vgs , gm , DisplayName="L = $"+L+"nm$");
                xlabel("$V_{GS}[V]$" , Interpreter="latex");
                xticks(vgs(1):0.2:vgs(end));
                ylabel("$g_m[\frac{A}{V}]$" , Interpreter="latex");
                title( type + "MOS $W="+ W + "\mu m$" , Interpreter="latex")
                legend([] , "Interpreter" , "latex" , "location" , "northwest");
                grid on
                hold on
                

            end

            estrazioneCartelle.esegui_per_ogni_dispositivo(funzione , true);
            
            if~exist("plot\gm_W" , "dir")
                mkdir plot\gm_W;
            end

            cd plot\gm_W


            figure(1)
            saveas(gcf , "gm_w_100_vds_"+ vds_mV+"_mV.png")    
            
            figure(2)
            saveas(gcf , "gm_w_200_vds_"+ vds_mV+"_mV.png")
            figure(3)
            saveas(gcf , "gm_w_600_vds_"+ vds_mV+"_mV.png")
            cd ..\..

        end

        % So che non devo metterla qua ma lo faccio lo stesso, questa
        % funzione unisce tutti i dati delle delta gm per prepararle per
        % latex
        function delta_gm_tabella_vds(vds_mV)

            
                
            PREFISSO_FILE = "Delta_gm_";
            
            nomi_tabella = ["5Mrad" , ]

            % definisco le diverse W e L
            array_W = [100 , 200 , 600];
            array_L = [30 , 60 , 180];
            array_vds_mV = 150:150:900; 
            indice_vds = find(array_vds_mV == vds_mV);
            if ~isempty(indice_vds)
                error("La Vds inidcata in mV non esiste, Vds=" + vds_mV)
            end

            tabella_delta_gm = zeros(length(array_W) * length(array_L), length(nomi_tabella));

            %scorriamo tutte le dimensioni
            for i = 1:length(array_W)
                W = array_W(i);
                for j = 1:length(array_W)
                    L = array_L(j);
                    % costruisco il nome del file
                    file = PREFISSO_FILE + W + "-" + L + ".xls";
                    temp = readmatrix(file);
                    % esclusiamo il pre irraggiamento
                    tabella_delta_gm(i , :) = temp(indice_vds , 3:end);
                end
            end

            cartella = 

        end
    end
end