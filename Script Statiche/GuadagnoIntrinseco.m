classdef GuadagnoIntrinseco
    
    methods (Static)
        %% Descrizione calcoli
        % Questa classe serve a calcolare il guadagno intrinseco, ovvero il massimo
        % guadagno ottenibile da un MOS, è dato dal rapporto di gm/gds in questo
        % sript utilizziamo:
        % - la gm a Vds = 0.9V
        % - la gds si dovrà calcolare prendendo le I_d a Vds (o Vsd) pari a 0.9 V e 
        % 0.75 V e poi fare il rapporto delta I_d / 0.15V
        %
        % In seguito si fa il rapporto delle colonne gm e gds. e per finire i plot
        % vengono fatti al variare di Ic0, coefficente di inversione, calcolato
        % come: Ic0 = (Id_Vds_0.9 / Iz* ) * (L/W)
        % con Iz* = 470nA nei NMOS e 370nA nei PMOS
        
        %% Come Utilizzare la funzione
        % Posizionarsi nella cartella del dispositivo del quale si vuole fare
        % l'analisi, per esempio all'interno della cartella "Chip4NMOS_3Grad", dopo
        % di ciò fare la chiamata alla funzione
        
        %% Funzione MAIN
        % questa per ogni dispositivo crea un file guadagno intrinseco ed esegue i
        % plot tenendo le stesse W
        function calcola()
            
            figure
          
            % estraiamo la tipologia del dispositivo
            path = pwd;
            pathParts = strsplit(path, filesep);
            cartella = char(pathParts{end});
            type = cartella(6) + ""+ cartella(5);
            numero_asic = cartella(5);
            tipo_canale = cartella(6);
            radiazioni = extractAfter(cartella , "_");
            if(isempty(radiazioni))
                radiazioni = "Pre";
            end
        
            % estraiamo le cartelle necessarie
            cartelle_dispositivi = estrazioneCartelle.getCartelleDispositivi();

            legenda = [];
            for i = 1:length(cartelle_dispositivi)
                cartella = string(cartelle_dispositivi(i));
        
                if ~contains(cartella , "nf")% se è un dispositivo funzionante continuiamo    
                    cd(cartella); % ci muoviamo nella cartella
                    try
                        [g , ic0] = GuadagnoIntrinseco.guadagnoIntrinseco_singolo();
                        temp = [ic0 , g];
                        temp = array2table(temp , "VariableNames", {'Coefficente_Inversione' , 'Guadagno_Intrinseco'});
                        writetable(temp , "guadagno_intrinseco.txt" , Delimiter="\t") 
                        [~ , ~ , L] = titoloPlot(cartella);
                        L = L * 1e3;
                        legenda = [legenda , ("gm/gds $L = " + L + "n m$")];
                    catch me
                        warning(me.message);
                    end
                    cd ..
        
                    
                end
                
                if mod(i , 3) == 0 % abbiamo fatto 3 dispositivi alla stessa W (o siamo al primo)
                    [~ , W ] = titoloPlot(cartella);
                    % testo = "$" + radiazioni + "$";
                    % testo = sprintf("Asic "  + numero_asic + "\n" + tipo_canale + "MOS\nW=" + W + "\\mum");
                    testo = "$W=" + W + "\mu m $";
                    annotation('textbox', [0.7, 0.25, 0.1, 0.1], 'String' , testo , 'EdgeColor' , 'none' , 'FitBoxToText', 'on', FontSize=14 , Interpreter='latex' )
                    set(gca, 'XScale', 'log', 'YScale', 'log')
                    legend(legenda , Interpreter="latex", Location = "southwest")
                    
                    GuadagnoIntrinseco.salvaFigura(W);
                    
                    if i ~= length(cartelle_dispositivi)
                        figure % facciamo una nuova figura
                        legenda = [];
                    end
                end
            
            end
        
        
        
        end

        % esegue i plot della variazione del guadagno intrinseco plottanto
        % il pre irraggiamento e il postirraggiamento 3Grad
        function calcolaVariazioneDose()
            close all

            COLORI = lines(3);
            limiti_X = [1e-2 1e2];
            limiti_Y = [1e-1 1e3];
            array_W = [100 200 600];
            array_L = [30 60 180];
            pos_dim_annotation = [0.15 0.1 0.25 0.25];
            font_size_annotation = 14;
            FILE = "guadagno_intrinseco.txt";

            temp = split(pwd , "\");
            tipoAsic = char(temp(end));

            setUpPlot()

            % W100 W200 W600 
            figure
            figure
            figure

            %creiamo la funzione
            funzione_irraggiamento = @f_irraggiamento;

            estrazioneCartelle.esegui_per_ogni_irraggiamento(funzione_irraggiamento)

            function f_irraggiamento()
                
                %Prendo il nome della cartella
                temp = split(pwd , "\");
                cartella_irraggiamento = char(temp(end));
                grado_irraggiamento = extractAfter(cartella_irraggiamento  , "_");
                
                funzione_dispositivi = @f_dispositivi;

                %solo i due casi pre e 3Grad
                if isempty(grado_irraggiamento) || contains(grado_irraggiamento , "3Grad")
                    
                    estrazioneCartelle.esegui_per_ogni_dispositivo(funzione_dispositivi);

                end

                function f_dispositivi()                
                    temp = split(pwd , "\");
                    cartella_dispositivo = char(temp(end));
                    
                    if ~contains(cartella_dispositivo , "nf")
                        temp = split(cartella_dispositivo , "-");
                        W = str2double(temp(2));
                        L = str2double(temp(3));
    
                        temp = readmatrix(FILE);
                        guadagno_intrinseco = temp(: , 2);
                        ic0 = temp(: , 1);

                        if isempty(grado_irraggiamento)
                            nome_legenda = "$L=" + L + "nm$ pre";
                        else
                            nome_legenda = "$L=" + L + "nm$ " + grado_irraggiamento;
                        end

                        indice_figura = find(array_W == W);  
                        indice_colore = array_L == L;
                        figure(indice_figura);
                        hold on

                        line = plot(ic0 , guadagno_intrinseco , DisplayName=nome_legenda , Color=COLORI(indice_colore, : ));
                        if ~isempty(grado_irraggiamento)
                            set(line ,"LineStyle" , "-.");
                        end
                        set(gca, 'XScale', 'log', 'YScale', 'log');
                        xlim(limiti_X);
                        ylim(limiti_Y);
                        ylabel("Guadagno intrinseco");
                        xlabel("Coefficente d'inversione");
                        grid on;
                    end
                end
            end
        
            cartella_plot = "Variazione_GuadagnoIntrinseco";
            if ~exist(cartella_plot , "dir")
                mkdir(cartella_plot);
            end
            


            cd(cartella_plot)

            figure(1)
            annotation("textbox" , pos_dim_annotation, "String" , "$W = 100\mu m$" , "EdgeColor","none" , "Interpreter", "latex" , "FontSize", font_size_annotation);
            legend("Interpreter","latex" , "Location", "southeast" , "FontSize", 10);
            saveas(gcf , "guadagnoIntrinsecoW100"  + tipoAsic + ".png")
            

            figure(2)
            annotation("textbox" , pos_dim_annotation , "String" , "$W = 200\mu m$" ,"EdgeColor","none" , "Interpreter", "latex" , "FontSize", font_size_annotation);
            legend("Interpreter","latex" , "Location", "southeast" , "FontSize", 10);
            saveas(gcf , "guadagnoIntrinsecoW200" + tipoAsic + ".png")

            figure(3)
            annotation("textbox" , pos_dim_annotation ,"String" , "$W = 600\mu m$" , "EdgeColor","none" , "Interpreter", "latex" , "FontSize", font_size_annotation);
            legend("Interpreter","latex" , "Location", "southeast" , "FontSize", 10);
            saveas(gcf , "guadagnoIntrinsecoW600" + tipoAsic + ".png")

            cd ..

        end

        %funzione che serve per plottare il guadagno intrinseco a
        %specifiche Vds e Vgs al variare dell'irraggiamento sia per P che N
        %iniseme... Da lanciare nella cartella Misure Statiche.
        function plot_guadagno_intrinseco_irraggiamento()
            close all

            
            Vds_mV = 600;
            Vgs_mV = 900;
            ARRAY_VDS = 150:150:900;
            ARRAY_VGS = ARRAY_VDS;


            NOME_CARTELLA = "guadagno_intrinseco_confronto";
            PREFISSO_NOME_FILE = "guadagno_intrinseco_confronto";


            %per i plot
            NOME_YLABEL = "$\frac{g_m}{g_{ds}} / (\frac{g_m}{g_{ds}})_{pre}$";
            NOME_XLABEL = "\textit{TID}$[Mrad]$";
            NOME_X_TICK = {0 500 1000 1500 2000 2500 3000 "annealing"};
            X_TICK = [0 500 1000 1500 2000 2500 3000 3500];
            X = [0 5 50 100 200 600 1000 3000 3500];
            COLORI = lines(2);
            LIMITI_X = [0 3500];

            NOME_CARTELLA_TABELLE = NOME_CARTELLA + "\dati";


            ARRAY_W = [100 200 600];
            ARRAY_L = [30 60 180];
            FILE_GM = "gm.txt";
            FILE_GDS = "gds.txt";
             
            fun = @f;
            
            %mi muovo dentro i P

            cd P1\
            dati = NaN(9 , 9);
            dati_pre = NaN(9 , 1);
            dati_gm = NaN(9 ,9 );
            dati_gds = NaN(9 , 9);
            dati_guadagno = NaN(9 , 9);

            estrazioneCartelle.esegui_per_ogni_irraggiamento_e_dispositivo(fun , true);
                
            dati_P = dati;
            dati_P_gm = dati_gm;
            dati_P_gds = dati_gds;
            dati_P_guadagno = dati_guadagno;
            
            %mi muovo dentro gli N
            cd ..\N4\

            dati = NaN(9 ,9);
            dati_pre = NaN(9 , 1);
            dati_gm = NaN(9 ,9 );
            dati_gds = NaN(9 , 9);
            dati_guadagno = NaN(9 , 9);
            
            estrazioneCartelle.esegui_per_ogni_irraggiamento_e_dispositivo(fun , true);

            dati_N = dati;
            dati_N_gm = dati_gm;
            dati_N_gds = dati_gds;
            dati_N_guadagno = dati_guadagno;
            
            cd ..

            % facciamo i plot
            if ~exist(NOME_CARTELLA , "dir")
                
                mkdir(NOME_CARTELLA);

            end
            cd(NOME_CARTELLA)
            for indice_dispositivo = 1:width(dati_N)

                figure
                setUpPlot();

                indice_L = mod((indice_dispositivo-1) , 3)+1;
                indice_W = floor((indice_dispositivo-1)/3)+1;

                dispositivo = string(ARRAY_W(indice_W)) + "-" + string(ARRAY_L(indice_L));


                plot(X , dati_P(indice_dispositivo , :) , "DisplayName", "PMOS" , "Color", COLORI(1 ,: ) , "LineStyle","-" , "Marker","o");
                hold on




                plot(X , dati_N(indice_dispositivo , : ) , "DisplayName", "NMOS" , "Color", COLORI(2 , : ), "LineStyle","-" , "Marker","square");


                ylabel(NOME_YLABEL , "Interpreter","latex");
                xlabel(NOME_XLABEL , "Interpreter","latex");

                xticks(X_TICK);

                xticklabels(NOME_X_TICK);

                xlim(LIMITI_X)

                title(dispositivo);

                legend("Location", "southeast" , "FontSize", 10 , "Interpreter","latex");

                nomeFile = PREFISSO_NOME_FILE + dispositivo + ".png";
                grid on


                saveas(gcf , nomeFile);

            end

            cd ..

            % Salviamo le tabelle
            if ~exist(NOME_CARTELLA_TABELLE , "dir")
                mkdir(NOME_CARTELLA_TABELLE)
            end
            
            cd(NOME_CARTELLA_TABELLE)

            %creaiamo i nomi delle righe
            NOMI_DISPOSITIVI = cell(9 , 1);
            i = 0;
            for W = ARRAY_W
                 for L = ARRAY_L
                     i = i+1;
                     NOMI_DISPOSITIVI{i} = W + "-" + L;
                 end
            end

            NOME_X_TICK = ["Dispositivo" , string(X)];

            dati_P = num2cell(dati_P);
            dati_P = [NOMI_DISPOSITIVI , dati_P];
            dati_P = array2table(dati_P , "VariableNames", NOME_X_TICK);
            
            dati_P_gm = num2cell(dati_P_gm);
            dati_P_gm = [NOMI_DISPOSITIVI , dati_P_gm];
            dati_P_gm = array2table(dati_P_gm , "VariableNames", NOME_X_TICK);
            
            dati_P_gds = num2cell(dati_P_gds);
            dati_P_gds = [NOMI_DISPOSITIVI , dati_P_gds];
            dati_P_gds = array2table(dati_P_gds , "VariableNames", NOME_X_TICK);
           
            dati_P_guadagno = num2cell(dati_P_guadagno);
            dati_P_guadagno = [NOMI_DISPOSITIVI , dati_P_guadagno];
            dati_P_guadagno = array2table(dati_P_guadagno , "VariableNames", NOME_X_TICK);
           
            dati_N = num2cell(dati_N);
            dati_N = [NOMI_DISPOSITIVI , dati_N];
            dati_N = array2table(dati_N , "VariableNames", NOME_X_TICK);
            
            dati_N_gm = num2cell(dati_N_gm);
            dati_N_gm = [NOMI_DISPOSITIVI , dati_N_gm];
            dati_N_gm = array2table(dati_N_gm , "VariableNames", NOME_X_TICK);
            
            dati_N_gds = num2cell(dati_N_gds);
            dati_N_gds = [NOMI_DISPOSITIVI , dati_N_gds];
            dati_N_gds = array2table(dati_N_gds , "VariableNames", NOME_X_TICK);
            
            
            dati_N_guadagno = num2cell(dati_N_guadagno);
            dati_N_guadagno = [NOMI_DISPOSITIVI , dati_N_guadagno];
            dati_N_guadagno = array2table(dati_N_guadagno , "VariableNames", NOME_X_TICK);
       

            writetable(dati_P , "Dati_P.xls");
            writetable(dati_P_gm , "Dati_P_gm.xls");
            writetable(dati_P_gds , "Dati_P_gds.xls");
            writetable(dati_P_guadagno , "Dati_P_guadagno_intrinseco.xls");
            
            writetable(dati_N , "Dati_N.xls");
            writetable(dati_N_gm , "Dati_N_gm.xls");
            writetable(dati_N_gds , "Dati_N_gds.xls");
            writetable(dati_N_guadagno , "Dati_N_guadagno_intrinseco.xls");
            
            cd ..\..

            
            function f()
                temp = split(pwd , "\");
                cartella_dispositivo = char(temp(end));                
                cartella_irraggiamento = char(temp(end-1));
                

                temp = split(cartella_dispositivo , "-");
                tipo_asic = char(temp(1));
                W = str2double(temp(2));
                L = str2double(temp(3));

                tipo_irraggiamento = extractAfter(cartella_irraggiamento , "_");
                if isempty(tipo_irraggiamento)
                    tipo_irraggiamento = "pre";
                end

                %bene prendiamo i dati
                %parto con gm
                             
                temp = readmatrix(FILE_GM);
                gm = temp(: , 2:end);
                
                vgs = temp(: , 1);

                % se è P non faccio nulla
                if tipo_asic(1) == "P"
                    vgs;
                end
                
                indice_colonna_gm = ARRAY_VDS == Vds_mV;
                [~ , indice_riga_gm] = min(abs(vgs - Vgs_mV/1000));

                gm = gm(indice_riga_gm , indice_colonna_gm);

                % ora la gds

                temp = readmatrix(FILE_GDS);
                gds = temp(: , 2:end);
                vds = temp(: , 1);

                % Se è un P impostiamo la vds come vsd
                if tipo_asic(1) == "P"
                    vds = 0.9 - vds;
                end

                indice_colonna_gds = ARRAY_VGS == Vgs_mV;
                [~ , indice_riga_gds] = min(abs(vds - Vds_mV/1000));
                
                gds = gds(indice_riga_gds , indice_colonna_gds);


                % bene salviamo i dati...
                %ricaviamo l'indice
                
                indice_W = find(ARRAY_W == W);
                indice_L = find(ARRAY_L == L);
                
                if W == 600 && L == 30
                    disp("600-30")
                end

                indice_riga_dati = (indice_W-1)*3 + indice_L;
                
                if contains(tipo_irraggiamento , "pre")
                    indice_colonna_dati = 1;
                elseif contains(tipo_irraggiamento , "Mrad")
                    grado =  str2double(extractBefore(tipo_irraggiamento , "Mrad"));
                    if grado == 5
                        indice_colonna_dati = 2;
                    elseif grado == 50
                        indice_colonna_dati = 3;
                    elseif grado == 100
                        indice_colonna_dati = 4;
                    elseif grado == 200
                        indice_colonna_dati = 5;
                    elseif grado == 600
                        indice_colonna_dati = 6;
                    end
                elseif contains(tipo_irraggiamento , "Grad")
                    grado =  str2double(extractBefore(tipo_irraggiamento , "Grad"));
                    if grado == 1
                        indice_colonna_dati = 7;
                    elseif grado == 3
                        indice_colonna_dati = 8;
                    end
                elseif contains(tipo_irraggiamento , "annealing")
                    indice_colonna_dati = 9;
                end
               
                guadagno_intrinseco = gm/gds;

                dati_gm(indice_riga_dati , indice_colonna_dati) = gm;
                dati_gds(indice_riga_dati , indice_colonna_dati) = gds;
                dati_guadagno(indice_riga_dati , indice_colonna_dati) = guadagno_intrinseco;

                if(indice_colonna_dati == 1)
                    dati_pre(indice_riga_dati) = guadagno_intrinseco;
                    dati(indice_riga_dati) = 1;
                else
                    % divido il dato con il pre irraggiamento
                    dati(indice_riga_dati , indice_colonna_dati) = guadagno_intrinseco / dati_pre(indice_riga_dati);
                end
                % fine?
            end
        end

        
        % Questa funzione fa il vero lavoro, calcola il guadagno intrinseco
        % [g , ic0] = guadagnoIntrinseco_singolo()
        % - g       guadagno intrinseco
        % - ic0     coefficente di inversione
        function [g , ic0] = guadagnoIntrinseco_singolo()
            % Inizzializzazione
            set(0,'DefaultLineLineWidth', 1.5);
            set(0,'defaultAxesFontSize', 14)
            set(0,'defaulttextInterpreter','latex')
            rng('default');
            
            
            % Definizione costanti
            Iz_P = 370e-9; %[A]
            Iz_N = 470e-9; %[A]
            delta_Vds = 0.15; %[V] 
            
            % Estrazione delle informazioni principali (ad esempio dimensioni e tipologia) 
            path = pwd;
            pathParts = strsplit(path, filesep);
            cartella = pathParts{end};
            
            [~ , W , L , type ] = titoloPlot(cartella); % W e L sono in um
            
            if type ~= "P" && type ~= "N"
                error("Non sono risucito a definire che tipologia è: " + type);
            end
            
            % Prelievo gm a 0.9V
            nome_gm = "gm.txt";
            if ~exist(nome_gm , "file")
                if exist("gm-vgs.txt" , "file")
                    nome_gm = "gm-vgs.txt";
                else
                    error("Il file gm.txt non esiste");
                end
            end
            
            temp = readmatrix(nome_gm);
            
            vgs = temp(: , 1); 
            gm = temp(: , end); % Sia nei P che nei N la gm a |Vds| massima è nell'ultima colonna 
            
            % Calcoliamo la gds
            id_vgs = "id_vgs.txt"; 
            if ~exist(id_vgs , "file") % controlliamo se esiste il file
                if exist("id-vgs.txt" , "file")
                    id_vgs = "id-vgs.txt";
                else
                    error("Il file id_vgs.txt non esiste");
                end
            end
            
            [~ , temp , vds_temp] = EstrazioneDati.estrazione_dati_vgs(id_vgs , type);
           
            id_vds_750mV = temp( : , vds_temp == 750);
            id_vds_900mV = temp( : , vds_temp == 900);
            
            gds = (id_vds_900mV - id_vds_750mV) / delta_Vds;
            
            % Calcolo coefficente di inversione IC0
            if type == "P"
                Iz = Iz_P;
            elseif type == "N"
                Iz = Iz_N;
            end
            
            ic0 = (id_vds_900mV / Iz) * (L / W);
            
            % Calcolo guadagno intrinseco
            
            g = gm ./ gds; % Divisione elemento per elemento
            
            % Esecuione plot
            hold on
            loglog(ic0 , g);
            
            ylabel("guadagno intrinseco")
            xlabel("coefficente di inversione")
            
            xlim([1e-2 , 1e2]);
            ylim([1e-1  1e3]);
        end
        
        % questa funzione serve a verificare se le cartelle sono in ordine 100 ,
        % 200 , 600.
        function boolean = inOrdine(cartelle)
            ordine = ["100" "100" "100" "200" "200" "200" "600" "600" "600"];
            for i = 1:length(cartelle)
                cartella = string(cartelle(i));
                if ~(contains(cartella , ordine(i)))
                    boolean = false;
                    return
                end
            end
            boolean = true;
        end
        
        % Questa funzione ordina le cartelle secondo 100 200 e 600 W e con lordine
        % di L 30 60 180;
        function  cartelle_odinate = ordinaCartelle(cartelle)
            cartelle_odinate = cell(9 , 1);
            W_ordine = ["100" "200" "600"];
            L_ordine = ["30" "60" "180"];
            for i = 1:length(cartelle)
                cartella = string(cartelle(i));
                cartella_vera = cartella; % serve per evitare che rimanga _nf nel caso di dispositivio non funzionante
                if contains(cartella , "nf")
                   cartella = split(cartella_vera , "nf");
                   cartella = char(cartella(1));
                   cartella = cartella(1:end-1);
                   cartella = string(cartella);
                end
        
                parti = split(cartella, '-');
                try
                    W = parti(2);
                    L = parti(3);
        
                    %Verifichiamo se sono numeri
                    isNumber(W);
                    isNumber(L);
        
                    indice = (find(W_ordine == W)-1)*3 + (find(L_ordine == L)-1)+1;
            
                    cartelle_odinate(indice) = {cartella_vera};
                catch ME
                    warning("Cartella/file scartato: " + cartella);
                end
                        
            end
        end
        
        % Funzione che verifica se la stringa è un numero. lancia un errore se non
        % lo è sennò ritorna il valore del numero
        function numero = isNumber(str)
            numero = str2num(str);
            if isnan(numero)
                error(sprintf("la stringa: %s non è un numero" , str ))
            end
        end
        
        function salvaFigura(W)
            if(~exist("plot\" , "dir"))
                mkdir plot\
            end
            cd plot\
            nome_file = "Guadagno_Intrinseco_W-" + W + ".png";
            saveas(gcf, nome_file);
            cd ..
        end
    end
    
end