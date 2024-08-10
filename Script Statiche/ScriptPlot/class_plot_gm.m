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
                temp = readmatrix("gm.txt");
                
                vgs = temp(: , 1);
                gm = temp(: , (indice_vds+1));
                
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

        % funzione che crea una tabella unita per le delta gm per tutte le
        % vds al variare della dose assorbita
        function delta_gm_tabella()

            array_vds = 150:150:900;

            for vds = array_vds
                class_plot_gm.delta_gm_tabella_vds(vds);  
            end

        end

        % So che non devo metterla qua ma lo faccio lo stesso, questa
        % funzione unisce tutti i dati delle delta gm per prepararle per
        % latex
        function delta_gm_tabella_vds(vds_mV)

            PREFISSO_FILE = "Delta_gm_";
            
            nomi_tabella = ["Dispositivo" , "5Mrad" ,"50Mrad" , "100Mrad" , "200Mrad" , "600Mrad"  , "1Grad"  ,"3Grad" , "annealing"];

            % definisco le diverse W e L
            array_W = [100 , 200 , 600];
            array_L = [30 , 60 , 180];
            array_vds_mV = 150:150:900; 
            
            indice_vds = find(array_vds_mV == vds_mV);
            if isempty(indice_vds)
                error("La Vds inidcata in mV non esiste, Vds=" + vds_mV)
            end
            numero_dispositivi = length(array_W) * length(array_L);
            array_dispositivi = cell(1 , numero_dispositivi);
            tabella_delta_gm = zeros(numero_dispositivi, length(nomi_tabella)-1);
            indice_dispositivo = 0;
            %scorriamo tutte le dimensioni
            for i = 1:length(array_W)
                W = array_W(i);
                for j = 1:length(array_W)
                    indice_dispositivo = indice_dispositivo + 1;
                    L = array_L(j);
                    % costruisco il nome del file
                    dispositivo = W + "-" + L;
                    file = PREFISSO_FILE + dispositivo + ".xls";
                    temp = readmatrix(file);
                    % esclusiamo il pre irraggiamento
                    tabella_delta_gm(indice_dispositivo , 1:end) = temp(indice_vds , 3:end);
                    array_dispositivi{1 , indice_dispositivo} =  dispositivo;
                end
            end

            array_dispositivi = (array_dispositivi)';
            tabella_delta_gm = num2cell(tabella_delta_gm);
            
            tabella_delta_gm = [array_dispositivi , tabella_delta_gm];

            tabella_delta_gm = cell2table(tabella_delta_gm ,"VariableNames", nomi_tabella);

            cartella = "tabelle";
            if ~exist(cartella , "dir")
                mkdir(cartella);
            end
            cd(cartella)
            
                writetable(tabella_delta_gm , "Delta_gm_vds_" + vds_mV + "mV.xls")

            cd ..

        end
    end
end