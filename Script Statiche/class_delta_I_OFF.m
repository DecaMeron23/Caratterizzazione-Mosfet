classdef class_delta_I_OFF
    
    methods(Static)

        function delta_I_off()
            
            [cartelle]= estrazioneCartelle.getCartelle();

            grado = [0 5 50 100 200 600 1000 3000 "annealing"];
            valori_vds = [0.15 , 0.30 , 0.45 , 0.6 , 0.75 , 0.9];
            nomi_dispositivi = ["100-30" , "100-60" , "100-180" , "200-30" , "200-60", "200-180" , "600-30" , "600-60" , "600-180"];

            for k = 1:length(nomi_dispositivi)
                dispositivo = nomi_dispositivi(k);
                disp("Dispositivo = "+ dispositivo);
                delta = zeros(6 , 7);
                for i = 1: length(cartelle)
                    disp("      Grado = " + grado(i)+  "Mrad");
                    cd(string(cartelle(i)));
                    cartella_dispositivo = estrazioneCartelle.getFileCartella(dispositivo);
                    try
                    cartella_dispositivo = string(cartella_dispositivo(1));
                    catch
                    end
                    if(~exist(cartella_dispositivo , "dir"))
                        warning("Dispositivo non torvato: '" + dispositivo + "'");
                        delta(1:end , i) = zeros(length(valori_vds) , 1);
                    else
                        cd(cartella_dispositivo);
                        for j = 1:length(valori_vds)

                            if contains(cartella_dispositivo , "nf")
                                delta(j , i) = NaN;
                            else
                                I_off = class_delta_I_OFF.calcola_I_off(valori_vds(j), char(cartella_dispositivo));
                                
                                if(i == 1)
                                        I_off_pre(j , 1) = I_off;
                                        delta( j , 1) = 0;
                                    else
                                        delta(j , i) = abs(I_off) - abs(I_off_pre(j,1)); 
                                end
                            end
                        end
                        
                        cd ..
                    end
                    cd ..
                end
                
                % creaimo la tabella
                %entriamo nella cartella DeltaGm
                if(~exist("DeltaIoff", "dir"))
                    mkdir("DeltaIoff\");
                end
                cd DeltaIoff;
                %componiamo la matrice da salvare
                
                matrice =  horzcat(valori_vds' , delta);
                valori = ["Vds" , (grado + "Mrad")];        
                matrice = array2table(matrice);
                vecchi_nomi = 1:width(matrice);
                matrice = renamevars(matrice,vecchi_nomi,valori);
                writetable(matrice , "Delta_I_off_" + dispositivo+ ".xls");
                
            
                cd ..
            end
            cd DeltaIoff

            % aggiungiamo le tabelle raggruppate
            class_delta_I_OFF.tabelleRaggruppateDispositivo()
            
            cd ..
        end

        function tabelleRaggruppateDispositivo()
            ARRAY_VDS_mV = 150:150:900;
            
            for VDS_mV = ARRAY_VDS_mV
                class_delta_I_OFF.tabellaRaggruppataDispositivo_Vds(VDS_mV)
                class_delta_I_OFF.plotDeltaIoff_Vds(VDS_mV);
            end


        end

        function tabellaRaggruppataDispositivo_Vds(VDS_mV)
            PREFISSO_FILE_IN_LETTURA = "Delta_I_off_%d-%d.xls";
            NOME_FILE_IN_SCRITTURA = sprintf("Delta_I_off_Vds_%d.xls" , VDS_mV); 
            ARRAY_L = [30 60 180];
            ARRAY_W = [100 200 600];
            CARTELLA = "tabelle\";
            NOMI_COLONNE = string({"dispositivo" 0 5 50 100 200 600 1000 3000 "annealing"});
            ARRAY_VDS_mV = 150:150:900;
            NOMI_DISPOSITIVI = {};
                
            indice_VDS = ARRAY_VDS_mV == VDS_mV;
            


            dati = NaN((length(ARRAY_W) * length(ARRAY_L)) , length(NOMI_COLONNE)-1);
            
            indiceDispositivo = 0;

            

            for W = ARRAY_W
                    for L = ARRAY_L
                        indiceDispositivo = indiceDispositivo + 1;
                        %Definiamo il nome del file da leggere
                        file_in_lettura = sprintf(PREFISSO_FILE_IN_LETTURA , W , L);
                        delta = readmatrix(file_in_lettura);
                        dati(indiceDispositivo , :) = delta(indice_VDS , 2:end);
                        NOMI_DISPOSITIVI{end+1} = sprintf("%d-%d" , W , L);
                    end
            end


            dati = num2cell(dati);
            dati = [NOMI_DISPOSITIVI' , dati];

            dati = array2table(dati , "VariableNames", NOMI_COLONNE);
            
            if ~exist(CARTELLA , "dir")
                mkdir(CARTELLA)
            end

            cd(CARTELLA);

            writetable(dati , NOME_FILE_IN_SCRITTURA);
            cd ..

        end

        %Funzione che esegue il plot di tutte le delte i off per un
        % dispositivo in particolare
        function plotDeltaIoff_Vds(VDS_mV)
            close all
            setUpPlot();
            NOME_CARTELLA = sprintf("plot\\%d_mV\\" , VDS_mV);
            NOME_FILE_LETTURA = sprintf("Delta_I_off_Vds_%d.xls" , VDS_mV);
            temp = split(pwd , "\");
            temp = char(temp(end-1));
            TIPO_DISPOSITIVO = temp(1);

            ARRAY_L = [30 60 180];
            ARRAY_W = [100 200 600];

            % per il plot
            COLORI = lines(3);
            X_TICKS = 0:500:3500;
            X_TICKS_LABEL = num2cell(X_TICKS);
            X_TICKS_LABEL{end} = "annealing";
            X = [0 5 50 100 200 600 1000 3000 3500];
            TITOLO = "%sMOS $W = %d \\mu m$";
            
            figure
            figure
            figure

            X_LABEL = "\textit{TID} $[Mrad]$";
            Y_LABEL = "$\Delta I_{off} [nA]$";

            cd tabelle\
            
            temp = readmatrix(NOME_FILE_LETTURA);
            % escludiamo il nome del dispositivo
            dati = temp(: , 2:end);

            indice_dispositivo = 0;
            indice_figura = 0; 
            for W = ARRAY_W
                indice_figura = indice_figura + 1;
                for L = ARRAY_L
                    figure(indice_figura);
                    indice_dispositivo = indice_dispositivo + 1;
                    colore_linea = COLORI( L == ARRAY_L , :);
                    name_line = sprintf("$L = %d nm$" , L);
                    delta = dati(indice_dispositivo , :);
                    if any(isnan(delta))
                        continue
                    end

                    plot(X, delta , "Color", colore_linea , "LineStyle", "-" , "Marker","square" , "DisplayName", name_line);
                    hold on
                end
                cd ..
                if ~exist(NOME_CARTELLA)
                    mkdir(NOME_CARTELLA)
                end
                cd(NOME_CARTELLA)
                
                NOME_FIGURA = sprintf("Delta_I_off_W_%d_VDS_%d_mV.png" , W , VDS_mV);

                if TIPO_DISPOSITIVO == "P"
                    LOCATION = "northeast";
                elseif TIPO_DISPOSITIVO == "N"
                    LOCATION = "northwest";
                end
                legend(Interpreter="latex" , FontSize=12 , Location= LOCATION);
                ylabel(Y_LABEL);
                xlabel(X_LABEL);
                xlim([0 3500]);


                title(sprintf(TITOLO , TIPO_DISPOSITIVO , W));

                grid on

                ax = gca;
                ax.XTick = X_TICKS; 
                % Imposta le etichette degli x-ticks
                ax.XTickLabel = X_TICKS_LABEL;
                
                % ax.YScale = "log";
                saveas(gcf , NOME_FIGURA);

                cd ..\..
                cd tabelle\ 
            end

            cd ..
            close all


        end

        % Funzione che estrae la I_off in nA
        function I_off = calcola_I_off(vds, dispositivo)

            if exist("id-vgs.txt","file")
                id_vgs = readmatrix("id-vgs.txt");
            elseif exist("id_vgs.txt","file")
                id_vgs = readmatrix("id_vgs.txt");
            end

            id_vgs = id_vgs(1,[2,7,12,17,22,27,32]);

            % L_dispositivo = str2double(string(dispositivo(8:end)))*1e-9;
            % N_finger = str2double(string(dispositivo(4:6))) / 2.5;

            if(dispositivo(1) == 'P')
                indice_vds = 7-vds/0.15;
            else 
                indice_vds = 1+vds/0.15;
            end
            % I_off = id_vgs(indice_vds)*L_dispositivo/N_finger;
            I_off = id_vgs(indice_vds) * 1e9;
        end

        % funzione che crea i plot per fare i confronti tra P e N MOS
        function plot_confronto_P_N(Vds_mV)  
            close all

            cartella = sprintf("delta_i_off_confronto\\Vds_%d", Vds_mV);

            if ~exist( cartella, "dir")
                mkdir(cartella);
            end

            X = [0 5 50 100 200 600 1000 3000 3500];

            COLORI = lines(3);
            ARRAY_W_L = [100  200 600;
                30 60 180];
            
            CARTELLE = ["P1" "N4"];

            FILE_P = (sprintf("%s\\DeltaIoff\\tabelle\\Delta_I_off_Vds_%d.xls"  ,CARTELLE(1) , Vds_mV)); 
            FILE_N = (sprintf("%s\\DeltaIoff\\tabelle\\Delta_I_off_Vds_%d.xls"  ,CARTELLE(2) , Vds_mV));

            temp = readmatrix(FILE_P);
            Dati_P = temp(: , 2:end);
            
            temp = readmatrix(FILE_N);
            Dati_N = temp(: , 2:end);

            figure
            figure
            figure
            
            numero_figura = 0;
            riga_dispositivo = 0;
            for W = ARRAY_W_L(1 , :)
                numero_figura = numero_figura + 1;
                figure(numero_figura);
                for L = ARRAY_W_L(2 , :)
                    riga_dispositivo = riga_dispositivo + 1;
                    
                    I_OFF_P = Dati_P(riga_dispositivo , :);
                    I_OFF_N = Dati_N(riga_dispositivo , :);
                    
                    selettore_colore = L == ARRAY_W_L(2 ,:);

                    if ~any(isnan(I_OFF_N))
                        plot(X , I_OFF_N , "LineStyle","-", "Marker","o" , "Color", COLORI(selettore_colore , :) ...
                            , "DisplayName", sprintf("NMOS $L = %d nm$" , L));
                        hold on
                    end
                    if ~any(isnan(I_OFF_P))
                        plot(X , I_OFF_P , "LineStyle","--", "Marker","^" , "Color", COLORI(selettore_colore , :) ...
                            , "DisplayName", sprintf("PMOS $L = %d nm$" , L));
                        hold on
                    end
                end

                title(sprintf("$W = %d \\mu m$" , W) , Interpreter="latex");
                ylabel("$\Delta I_{OFF} [A]$" , Interpreter="latex");
                xlabel("\textit{TID} $[Mrad]$" , Interpreter="latex");

                legend(Interpreter="latex" , FontSize=10 , Location="best");
                
                ax = gca;
                ax.XTick = 0:500:3500;
                ax.XTickLabel = {0 500 1000 1500 2000 2500 3000 "annealing"};

                xlim([0 , 3500]);
                grid on
                
                saveas(gcf , sprintf("%s\\W_%d.png", cartella, W));

            end
        end

        function I_OFF(Vds_mV)
            
            close all

            irraggiamenti = string({"pre" "5Mrad" "50Mrad" "100Mrad" "200Mrad" "600Mrad" "1Grad" "3Grad" "annealing"});
            ARRAY_W = [100 200 600];
            ARRAY_L = [30 60 180];

            i_off = NaN(9 , length(irraggiamenti));
    
            COLORI = lines(3);
            DISPOSITIVI = {};
            X = [0 5 50 100 200 600 1000 3000 3500];
            X_Tick = 0:500:3500;
            X_Tick_Label = {0 500 1000 1500 2000 2500 3000 "annealing"};
            
            figure
            figure
            figure

            f = @funzione_interna;

            estrazioneCartelle.esegui_per_ogni_irraggiamento_e_dispositivo(f , true)
            
            Cartella = "Variazione_I_OFF";

            if ~exist( Cartella, "dir")
                mkdir(Cartella)
            end

            function funzione_interna()
                temp = split(pwd , "\");
                cartella_attuale = char(temp(end));
                cartella_irraggiamento = char(temp(end-1));
                
                temp = split(cartella_attuale , "-");
                W = str2double(temp(2));
                L = str2double(temp(3));
                % IS_NF = contains(cartella_attuale , "nf");
                % temp = char(temp(1));
                % tipo_dispositivo = temp(1);

                temp = extractAfter(cartella_irraggiamento , "_");
                if isempty(temp)
                    grado = "pre";
                else
                    grado = temp;
                end
                   
                indice_dispositivo = (find(ARRAY_W == W)-1)*3 + find(ARRAY_L == L);
                indice_grado = (irraggiamenti == grado);

                i_off(indice_dispositivo , indice_grado) = abs(class_delta_I_OFF.calcola_I_off(Vds_mV/1e3 , cartella_attuale)*1e-9);
            end

            indice_dispositivo = 0;
            indice_figura = 0;
            for W = ARRAY_W
                indice_figura = indice_figura + 1;
                figure(indice_figura);
                for L = ARRAY_L
                    indice_dispositivo = indice_dispositivo + 1;
                    
                    colore = ARRAY_L == L;

                    DISPOSITIVI{end+1} = sprintf("%d - %d" , W , L);

                    plot(X , i_off(indice_dispositivo , :) , DisplayName= sprintf("$L = %d nm$" , L) , Color=COLORI(colore , :) ,LineStyle="-", Marker="^")
                    hold on

                end
                
                title(sprintf("$W = %d\\mu m$" , W), Interpreter="latex");
                legend(Interpreter="latex" , FontSize=12);
                xlabel("\textit{TID}$[Mrad]$" , Interpreter="latex");
                ylabel("$I_{OFF} [A]$" , Interpreter="latex");
                xlim([0 3500])
                
                ax = gca;
                ax.XTick = X_Tick;
                ax.XTickLabel = X_Tick_Label;
                
                ax.YScale = "log";

                grid on
                
                Cartella_PLOT = sprintf("%s\\plot\\Vds_mv_%d" , Cartella , Vds_mV);

                if ~exist( Cartella_PLOT, "dir")
                    mkdir(Cartella_PLOT)
                end

                saveas(gcf , sprintf("%s\\W_%d.png" , Cartella_PLOT , W));

            end            

            i_off = num2cell(i_off);
            i_off = [DISPOSITIVI' , i_off];

            i_off = cell2table(i_off , "VariableNames", ["dispositivi" , irraggiamenti]);

            writetable(i_off , sprintf("%s\\I_OFF_VDS_mV_%d.xls" , Cartella , Vds_mV));
            


        end
    end
end