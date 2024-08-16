classdef class_delta_i_on

    methods(Static)
  
        % posisizionarsi nella cartella con tutti gli irraggiamenti
        function delta_I_on_irraggiamento()
            
            [cartelle]= estrazioneCartelle.getCartelle();

            grado = [0 5 50 100 200 600 1000 3000 "annealing"];
            valori_vds = [0.15 , 0.30 , 0.45 , 0.6 , 0.75 , 0.9];
            nomi_dispositivi = ["100-30" , "100-60" , "100-180" , "200-30" , "200-60", "200-180" , "600-30" , "600-60" , "600-180"];

            for k = 1:length(nomi_dispositivi)
                dispositivo = nomi_dispositivi(k);
                disp("Dispositivo = "+ dispositivo);
                delta = zeros(6 , 8);
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

                        if contains(cartella_dispositivo , "nf")
                            delta(: , i) = NaN;
                        else
                            for j = 1:length(valori_vds)
                                I_on = class_delta_i_on.calcola_I_on(valori_vds(j), char(cartella_dispositivo));
                                
                                if(i == 1)
                                        I_on_pre(j , 1) = I_on;
                                        delta( j , 1) = 0;
                                    else
                                        delta(j , i) = (I_on - I_on_pre(j,1))*100/I_on_pre(j,1);
                                end
                            end
                        end
                    
                        cd ..
                    end
                    cd ..
                end
                
                % creaimo la tabella
                %entriamo nella cartella DeltaGm
                if(~exist("DeltaIon", "dir"))
                    mkdir("DeltaIon\");
                end
                cd DeltaIon;
                %componiamo la matrice da salvare
                
                matrice =  horzcat(valori_vds' , delta);
                valori = ["Vds" , (grado + "Mrad")];        
                matrice = array2table(matrice);
                vecchi_nomi = 1:width(matrice);
                matrice = renamevars(matrice,vecchi_nomi,valori);
                writetable(matrice , "Delta_I_on_" + dispositivo+ ".csv");
                cd ..
            end

            cd DeltaIon\

            % dividiamo per Vds
            class_delta_i_on.tabelle_delta_i_on_tutte_vds();
            
            cd ..

        end

        % Funzione che crea le tabelle raggruppate per Vds
        function tabelle_delta_i_on_tutte_vds()
            
            ARRAY_VDS_mV = 150:150:900;

            CARTELLA = "tabelle\";

            if ~exist(CARTELLA , "dir")
                mkdir(CARTELLA);
            end

            for Vds_mV = ARRAY_VDS_mV
                
                class_delta_i_on.tabelle_delta_i_on_vds(Vds_mV);
                class_delta_i_on.plot_delta_i_on_vds(Vds_mV);

            end
        end

        % Questa funzione raggruppa tutte le tabelle per Vds della I_on 
        function tabelle_delta_i_on_vds(Vds_mV)
            DATI_I_ON = NaN(9 , 9);

            INTESTAZIONI = [0 5 50 100 200 600 1000 3000 "annealing"];
            INTESTAZIONI = ["Dispositivi" , INTESTAZIONI(1:end-1) + "Mrad" , INTESTAZIONI(end)];

            CARTELLA = "tabelle";
            NOME_FILE_DA_SCIVERE = sprintf("%s\\Delta_i_on_Vds_%d_mV.csv" , CARTELLA ,  Vds_mV);

            DISPOSITIVI = cell(9 , 1);

            indice_vds = 150:150:900 == Vds_mV;

            ARRAY_W = [100 200 600];
            ARRAY_L = [30 60 180];

            NOME_FILE_DA_LEGGERE = "Delta_I_on_%d-%d.csv";
            
            indice_dispositivo = 0;
            for W = ARRAY_W
                for L = ARRAY_L
                    indice_dispositivo = indice_dispositivo + 1;
                    file_da_leggere = sprintf(NOME_FILE_DA_LEGGERE , W , L);
                    
                    temp = readmatrix(file_da_leggere);
                    delta_i_on = temp(indice_vds , 2:end);

                    DATI_I_ON(indice_dispositivo , : ) = delta_i_on;

                    DISPOSITIVI{indice_dispositivo} = sprintf("%d-%d" , W , L);
                end
            end

            DATI_I_ON = num2cell(DATI_I_ON);
            DATI_I_ON = [DISPOSITIVI , DATI_I_ON];

            DATI_I_ON = cell2table(DATI_I_ON , "VariableNames" , INTESTAZIONI);

            writetable(DATI_I_ON , NOME_FILE_DA_SCIVERE);

        end

        % Creazioe dei plot raggruppati per W della I_on per una specifica V_ds
        function plot_delta_i_on_vds(Vds_mV)
            close all
            setUpPlot();

            %preleviamo il tipo del dispositivo
            temp = split(pwd , "\");
            temp = char(temp(end-1));
            TIPO = temp(1);

            CARTELLA = sprintf("plot\\Vds_%d_mV\\" , Vds_mV);
            NOME_FILE = "Delta_i_on_W_%d.png";

            if ~exist(CARTELLA,  "dir")
                mkdir(CARTELLA);
            end

            X = [0 5 50 100 200 600 1000 3000 3500];
            
            XTICK = 0:500:3500;
            XTICK_LABEL = [num2cell(XTICK(1:end-1)) , "annealing"];

            ARRAY_W = [100 200 600];
            ARRAY_L = [30 60 180];

            COLORI = lines(3);
            DISPLAY_LINE = "$L = %d nm$"; 

            FILE_IN_LETTURA = sprintf("tabelle\\Delta_i_on_Vds_%d_mV.csv" , Vds_mV);

            temp = readmatrix(FILE_IN_LETTURA);
            DELTA_I_ON = temp(: , 2:end);
            
            figure
            figure
            figure

            indice_dispositivo = 0;
            indice_figura  = 0;
            for W = ARRAY_W
                indice_figura = indice_figura + 1;
                figure(indice_figura);

                for L = ARRAY_L
                    indice_dispositivo = indice_dispositivo + 1;
                    
                    dati = DELTA_I_ON(indice_dispositivo , :);
                    
                    if any(isnan(dati))
                        continue
                    end

                    plot(X , dati , "DisplayName", sprintf(DISPLAY_LINE , L) , "Color", COLORI(ARRAY_L == L , :) , LineStyle="-" , Marker="^");
                    hold on

                end

                title(sprintf("%sMOS - $W = %d\\mu m$", TIPO, W) , Interpreter="latex" , FontSize=11);
                xlim([0 3500]);
                ylabel("$\Delta I_{ON}\%$", Interpreter="latex");
                xlabel("\textit{TID} $[Mrad]$" , Interpreter="latex");
                legend(Interpreter= "latex" , Location="northeast" , FontSize=10);

                xticks(XTICK);
                xticklabels(XTICK_LABEL);
               ytickformat('percentage');

                grid on
                
                nomefile = CARTELLA + sprintf(NOME_FILE , W);

                saveas(gcf,nomefile);
                    
            end


            

        end

        function I_on = calcola_I_on(vds, dispositivo)

            if exist("id-vgs.txt","file")
                id_vgs = readmatrix("id-vgs.txt");
            elseif exist("id_vgs.txt","file")
                id_vgs = readmatrix("id_vgs.txt");
            end
            id_vgs = id_vgs(:,[2,7,12,17,22,27,32]);
            if(dispositivo(1) == 'P')
                indice_vds = 7-vds/0.15;
                if(strcmp(dispositivo, 'P1-600-30'))
                    I_on = id_vgs(202, indice_vds); %corrente a Vsg = 0,7V e Vsd passata come parametro
                else
                    I_on = id_vgs(end, indice_vds); %corrente a Vsg = 0,9V e Vsd passata come parametro
                end
            else 
                indice_vds = 1+vds/0.15;
                if(strcmp(dispositivo, 'N4-600-60') && vds == 0.9)
                    I_on = id_vgs(202, indice_vds); %corrente a Vgs = 0,7V e Vsd passata come parametro
                else
                    I_on = id_vgs(end, indice_vds); %corrente a Vgs = 0,9V e Vsd passata come parametro
                end
            end
        end
    end
end