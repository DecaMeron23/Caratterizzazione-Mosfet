classdef Vth
    % Vth: Questa classe dispone di tutte le funzioni che calcolano la Vth
    % (oppure delta_vth) in particolare sono presenti le funzioni:
    % calcolo_vth la quale esegue il calcolo di tutte vth con i diversi
    % metodi (è presente anche la funzione che calcola per tutti i diversi
    % irraggiamenti), RM, RM con gli estremi della RM preirraggiamento, il fit lineare, SDLM e TCM
    % Inolte è presente la funzione EstraiVth.
    
    methods (Static)
        
        % EstraiVth: questa funzione viene utilizzata per estrarre dai file .txt
        % dei diversi dispositivi, le diverse vth, in modo tale da raggrupparle in
        % un unico file "Vth.xls"
        % utilizzo, posizionarsi all'interno della cartella Vth (contenuta
        % all'interno delle cartelle degli ASIC con uno specifico irraggiamento, ad
        % esempio : "Chip4NMOS_5Mrad") contenente i diversi file delle vth, dopo
        % ciò avviare la funzione.
        % A fine esecuzione si crerà una cartella "tabelle" contenente il file
        % Vth.xls
        function EstraiVth()
            directory = dir;
            file = {directory.name};
            
            if ~(exist("tabelle" , "dir"))
                mkdir tabelle
            end
            vth_file = {};
            for i = 3 : length(file)
                
                if contains(string(file(i)), ".txt")
                    vth_file{end+1} = string(file(i));
                end
            end
            
            vth_file = sortVthFile(vth_file);
            
            dispositivi = ["100/30" "100/60" "100/180" "200/30" "200/60" "200/180" "600/30" "600/60" "600/180"];
            
            % carichiamo i file
            for i = 1: length(vth_file)
                if ~isnumeric(vth_file{1, i})
                    matrice(i , :) = readmatrix(string(vth_file(i)))';
                end
            end
            
            tabella = array2table( matrice , VariableNames= ["Fit Lin" ,"TCM" , "SDLM" , "RM " , "RM_FIT_PRE" ]);
            tabella = addvars(tabella, dispositivi' , 'Before', 1 , 'NewVariableNames', 'Dispositivi');
            
            
            cd tabelle
            if exist("Vth.xls" , "file")
                delete Vth.xls
            end
            writetable(tabella , "Vth" , FileType="spreadsheet");
            cd ..
        end
        
        % Questa funzione calcola tutte le vth di un asic per ogni irraggiamento
        % Come Utilizzare: Posizionarsi nella cartella contenente tutti i diversi
        % irraggiamenti ed avviare la funzione
        function calcolo_Vth_irraggiamenti()
            directory = dir;
            file = {directory.name};
            
            cartelle_irraggiamenti = {};
            
            for i = 3 : length(file)
                file_string = string(file(i));
                
                if contains(file_string , "Chip")
                    cartelle_irraggiamenti{end + 1} = file_string;
                end
            end
            
            for i = 1: length(cartelle_irraggiamenti)
                disp(i + "/" + length(cartelle_irraggiamenti) + ")"+ "Inizio:" + string(cartelle_irraggiamenti(i)));
                cd(string(cartelle_irraggiamenti(i)))
                Vth.Calcolo_Vth()
                cd ..
            end
        end
        
        % Posizionarsi nella cartella dell'ASIC, a un certo grado di irraggiamento, con all'interno tutte le cartelle dei dispositivi
        function calcolo_vth()
            
            % abilitare i plot di verifica (si = 1, no = 0)
            PLOT_ON = 0;
            
            % indichiamo se il dispositivo è pre irraggiamento
            preIrraggiamento = 0;
            
            if preIrraggiamento == 1
                SPAN = 20;
                GRADO = 6;
            elseif preIrraggiamento == 0
                SPAN = 5;
                GRADO = 6;
            end
            
            % trovo la directory in cui ci troviamo
            fp = dir();
            % Lista dei file nella cartella
            fileInFolder = {fp.name};
            % verifichiamo se ci sono dei file nella cartella ( . e .. esclusi)
            if length(fileInFolder) <= 2
                error("Cartella vuota...")
            end
            
            
            for i = 3 : length(fileInFolder)
                dispositivo = char(fileInFolder(i));
                if ((dispositivo(1) == 'N' || dispositivo(1) == 'P') && (dispositivo(3) == '-')&&  ...
                        ~contains(dispositivo,'nf'))
                    
                    disp(dispositivo + ":");
                    
                    if ~PLOT_ON
                        set(0, 'DefaultFigureVisible', 'off');
                    end
                    
                    vth_FIT = Vth.FIT_LIN(dispositivo , PLOT_ON)*1e3;
                    vth_TCM= Vth.TCM(dispositivo , GRADO , PLOT_ON)*1e3;
                    vth_SDLM = Vth.SDLM (dispositivo , GRADO , PLOT_ON)*1e3;
                    vth_RM = Vth.RM(dispositivo , PLOT_ON)*1e3;
                    vth_RM_fitEstratti = Vth.RM_Estremi_PreIrraggiamento(dispositivo , PLOT_ON)*1e3;
                    
                    if ~PLOT_ON
                        set(0, 'DefaultFigureVisible', 'on');
                    end
                    
                    formato = '%5.1f';
                    
                    
                    vth_FIT = string(sprintf(formato, vth_FIT));
                    vth_TCM = string(sprintf(formato, vth_TCM));
                    vth_SDLM = string(sprintf(formato, vth_SDLM));
                    vth_RM = string(sprintf(formato, vth_RM));
                    vth_RM_fitEstratti = string(sprintf(formato, vth_RM_fitEstratti));
                    
                    vth = [vth_FIT , vth_TCM , vth_SDLM , vth_RM , vth_RM_fitEstratti];
                    
                    %% Save File
                    %Rinonimo le intestazioni
                    
                    vth = array2table(vth);
                    vth = renamevars(vth , ["vth1" , "vth2" "vth3" , "vth4" , "vth5"] , ["Lin_fit_Id", "Vth_TCM", "Vth_SDLM" ,"Vth_RM" , "Vth_RM_Fit_Pre"]);
                    
                    Cartella = "Vth";
                    
                    if ~exist(Cartella , "dir")
                        mkdir(Cartella);
                    end
                    
                    cd(Cartella);
                    
                    
                    %Salvo File nella cartella
                    writetable( vth, "Vth_" + dispositivo + ".txt",  "Delimiter", "\t");
                    
                    cd ..
                    
                end
            end
            
        end
        
        % Funzione vht RM
        function [vth , estremi_fit]= RM(dispositivo , PLOT_ON , DISP_ON)
            
            if(nargin == 2)
                DISP_ON = 1;
            end
            
            dispositivo = char(dispositivo);
            
            cd (string(dispositivo))
            
            try
                [tipo, vgs, rm_data] = Vth.Estrai_Dati_RM(dispositivo);
            catch
                return
            end
            
            %settiamo l'R^2 migliore a 0
            R_migliore = 0;
            
            % per colpa di chi ha inventato i floatingpoint 0.3 non è uguale a
            % 0.3 e devo scrivere più codice...
            [~, indice1] = min(abs(vgs - 0.1));
            [~, indice2] = min(abs(vgs - (0.75)));
            % dalla posizione in cui è a 0.3V fino a (0.9-0.15)V
            for i = indice1:indice2
                
                % prendiamo l'intervallo
                x = vgs(i : i+30);
                y = rm_data(i : i+30);
                
                modello_Fit = fitlm(x , y);
                
                R_attuale = modello_Fit.Rsquared.Ordinary;
                
                % se questo fit è migliore lo salviamo
                if(R_attuale > R_migliore)
                    R_migliore = R_attuale;
                    modello_migliore = modello_Fit;
                    intervallo = [vgs(i) , vgs(i+30)];
                end
            end
            
            estremi_fit = intervallo;
            
            % troviamo la vth
            coefficenti = modello_migliore.Coefficients.Estimate;
            if DISP_ON
                disp("RM: il coefficente R^2 migliore è " + R_migliore);
            end
            vth = -coefficenti(1) / coefficenti(2);
            
            x_new = [vth-0.2 , 0.9];
            y_fit = predict(modello_migliore , x_new');
            figure
            set(gca , "FontSize" , 12)
            titolo = titoloPlot(dispositivo);
            hold on
            plot(vgs , rm_data)
            plot(x_new , y_fit)
            xlim([0 , 0.9])
            %ylim([-0.15, 0.15])
            title("RM - " + titolo , FontSize=10);
            xline(vth , "--");
            yline(0, "-.");
            xline(intervallo(1) , '--');
            xline(intervallo(2) , '--');
            plot(vth,  0 , "*" ,color = "r" , MarkerSize=20);
            
            if tipo == 'P'
                xlabelb_txt = "$V_{SG} [V]$";
            elseif tipo == 'N'
                xlabelb_txt = "$V_{GS} [V]$";
            end
            
            
            xlabel( xlabelb_txt, "Interpreter","latex" , FontSize=15);
            ylabel("$\frac{I_D}{g_m^(\frac{1}{2})} [\sqrt{\frac{A^3}{V}}]$" , Interpreter="latex" , FontSize=15);
            legend( "$I_D$", "Ratio Method", Interpreter = "latex" , Location = "northwest");
            hold off
            
            if ~exist("fig\" , "dir")
                mkdir("fig\")
            end
            
            cd fig\
            
            saveas(gca , "RM.fig")
            
            cd ..\..
            
            if ~PLOT_ON
                close all
            end
            
        end
        
        % Funzione RM con estremi già indicati
        function [vth , R , delta_vth] = RM_Estremi_PreIrraggiamento(dispositivo , PLOT_ON)
            
            dispositivo = char(dispositivo);
            
            [estremo_sx , estremo_dx , vth_pre] = Vth.getEstremi_RM(dispositivo);
            
            cd(dispositivo);
            
            
            
            try
                [tipo, vgs, rm_data] = Vth.Estrai_Dati_RM(dispositivo);
            catch
                return
            end
            
            [~, indice_sx] = (min(abs(vgs - estremo_sx)));
            [~,indice_dx] = (min(abs(vgs - estremo_dx)));
            
            
            % prendiamo l'intervallo
            x = vgs( indice_sx: indice_dx);
            y = rm_data(indice_sx : indice_dx);
            
            modello = fitlm(x , y);
            
            R = modello.Rsquared.Ordinary;
            
            disp("RM_Estremi_PreIrraggiamento: il coefficente R^2 è " + R);
            
            coefficenti = modello.Coefficients.Estimate;
            
            vth = round(-coefficenti(1) / coefficenti(2),1);
            
            x_new = [vth-0.2 , 0.9];
            y_fit = predict(modello , x_new');
            figure
            set(gca , "FontSize" , 12)
            titolo = titoloPlot(dispositivo);
            hold on
            plot(vgs , rm_data)
            plot(x_new , y_fit)
            xlim([0 , 0.9])
            %ylim([-0.15, 0.15])
            title("RM - " + titolo , FontSize=10);
            xline(vth , "--");
            yline(0, "-.");
            xline(estremo_sx , '--');
            xline(estremo_dx , '--');
            plot(vth,  0 , "*" ,color = "r" , MarkerSize=20);
            
            if tipo == 'P'
                xlabelb_txt = "$V_{SG} [V]$";
            elseif tipo == 'N'
                xlabelb_txt = "$V_{GS} [V]$";
            end
            
            
            xlabel( xlabelb_txt, "Interpreter","latex" , FontSize=15);
            ylabel("$\frac{I_D}{g_m^(\frac{1}{2})} [\sqrt{\frac{A^3}{V}}]$" , Interpreter="latex" , FontSize=15);
            legend( "$I_D$", "Ratio Method", Interpreter = "latex" , Location = "northwest");
            hold off
            
            if ~exist("fig\" , "dir")
                mkdir("fig\")
            end
            
            cd fig\
            
            saveas(gca , "RM_Estremi_preIrraggiamento.fig")
            
            cd ..\..
            
            if ~PLOT_ON
                close all
            end
            
            delta_vth = vth - vth_pre;
            
        end
        
        % Funzione per il calcolo della vth con il metodo fit lineare della
        % caratteristica id-vgs
        function vth = FIT_LIN(dispositivo , PLOT_ON)
            
            dispositivo = char(dispositivo);
            
            cd (string(dispositivo))
            
            tipo = dispositivo(1);
            
            % Nomi dei file contenenti il le Id, al variare di Vds, e Vgs
            file = "id-vgs.txt";
            
            if(exist("id_vgs.txt" , "file"))
                file = "id_vgs.txt";
            end
            
            %se il file non esiste ritorna una tabella vuota
            if(~exist(file ,"file"))
                vth = 0;
                cd ..;
                return;
            end
            
            % Carico i file
            id_Vgs_completo = readmatrix(file);
            % file composto da {Vg + (Id , Ig , Is , Iavdd , Igrd) * vd}
            
            % estraggo le Vg (sono uguali per entrambi i file)
            vgs = id_Vgs_completo(: , 1);
            
            if tipo == 'P'
                %predo le id_vgs per Vsd minima (150mV)
                id = id_Vgs_completo(: , end - 9);
                
                %calcoliamo i valori di Vsg
                vgs = 0.9 - vgs;
            else
                %predo le id_vgs per Vsd minima (150mV)
                id = id_Vgs_completo(: , 7);
            end
            
            %settiamo l'R^2 migliore a 0
            R_migliore = 0;
            
            % per colpa di chi ha inventato i floatingpoint 0.3 non è uguale a
            % 0.3 e devo scrivere più codice...
            [~, indice1] = min(abs(vgs - 0.3));
            [~, indice2] = min(abs(vgs - (0.75)));
            % dalla posizione in cui è a 0.3V fino a (0.9-0.15)V
            for i = indice1:indice2
                
                % prendiamo l'intervallo
                x = vgs(i : i+30);
                y = id(i : i+30);
                
                modello_Fit = fitlm(x , y);
                
                R_attuale = modello_Fit.Rsquared.Ordinary;
                
                % se questo fit è migliore lo salviamo
                if(R_attuale > R_migliore)
                    R_migliore = R_attuale;
                    modello_migliore = modello_Fit;
                    intervallo = [vgs(i) , vgs(i+30)];
                end
            end
            
            disp("FIT_LIN: coefficente R^2 migliore è "+ R_migliore);
            
            % troviamo la vth
            coefficenti = modello_migliore.Coefficients.Estimate;
            
            vth = -coefficenti(1) / coefficenti(2);
            
            %plot di verifica del fit a Vsd = 150mV
            x_new = [vth-0.2 , 0.9];
            y_fit = predict(modello_migliore ,x_new' );
            figure
            set(gca , "FontSize" , 12)
            titolo = titoloPlot(dispositivo);
            hold on
            plot(vgs , id)
            plot(x_new , y_fit)
            title("Fit lineare - " + titolo , FontSize=10);
            xlim([0.2 , 0.9])
            xline(intervallo(1) , "--")
            xline(intervallo(2) , "--")
            yline(0 , "-.");
            xline(vth , "--");
            plot(vth ,  0 , "*" ,color = "r" , MarkerSize=20);
            
            if tipo == 'P'
                xlabelb_txt = "$V_{SG} [V]$";
            elseif tipo == 'N'
                xlabelb_txt = "$V_{GS} [V]$";
            end
            
            
            xlabel( xlabelb_txt, "Interpreter","latex" , FontSize=15);
            ylabel("$I_D [A]$" , Interpreter="latex" , FontSize=15);
            legend( "$I_D$", "fit lineare", Interpreter = "latex" , Location = "northwest");
            hold off
            
            %salvo il plot
            if(~exist("fig\" , "dir"))
                mkdir("fig\")
            end
            
            cd fig\
            
            saveas(gca , "FIT.fig");
            
            
            if ~PLOT_ON
                close all
            end
            
            cd ..\..
            
        end
        
        %funzione per il calcolo della vth con il metodo SDLM
        function vth = SDLM(dispositivo , GRADO , PLOT_ON)
            
            dispositivo = char(dispositivo);
            
            cd (string(dispositivo))
            
            tipo = dispositivo(1);
            
            % Nomi dei file contenenti il le Id, al variare di Vds, e Vgs
            file = "id-vgs.txt";
            
            if exist("id_vgs.txt" , "file")
                file = "id_vgs.txt";
            end
            
            %se il file non esiste ritorna una tabella vuota
            if ~exist(file ,"file")
                vth = 0;
                cd ..;
                return;
            end
            
            % Carico i file
            id_Vgs_completo = readmatrix(file);
            
            % estraggo le Vg (sono uguali per entrambi i tipi)
            vgs = id_Vgs_completo(: , 1);
            
            if tipo == 'P'
                
                %predo le id_vsg per Vsd massima (900mV)
                id = id_Vgs_completo(:,2);
                
                %calcoliamo i valori di Vsg
                vgs = 0.9 - vgs;
            elseif tipo == 'N'
                id = id_Vgs_completo(:, end - 4);
            end
            
            
            %calcoliamo il logaritmo di Id
            log_Id = log(abs(id));
            
            %Eseguiamo lo smooth
            log_Id = smooth(log_Id);
            %Deriviamo log(id) rispetto Vsg
            derivata_SDLM = gradient(log_Id) ./ gradient(vgs);
            %Eseguiamo lo smooth della derivata
            derivata_SDLM = smooth(derivata_SDLM );
            %Deriviamo la seconda volta
            derivata_2_SDLM = gradient(derivata_SDLM) ./ gradient(vgs);
            % per bassi valori di Vsg (da -0.3 a -0.2) sostituiamo i valori ponendoli a 200
            derivata_2_SDLM = [ones(20, 1)*200; derivata_2_SDLM(21:end)];
            %Smooth della derivata seconda
            derivata_2_SDLM = smooth(derivata_2_SDLM );
            % prendiamo l'indice del minimo valore della derivata seconda
            [ ~ , SDLM_Indice] = min(derivata_2_SDLM(1 : 180));
            % estraiamo la Vth
            vth_SDLM_noFit = vgs(SDLM_Indice);
            
            %Calcolo del minimo della funzione polinomiale che interpola i punti
            % in un intorno di Vth calcolata con SDLM a Vgs = 900 mV e di raggio 100 mV
            
            
            %prendiamo gli indici dell'intervallo +-100mV con centro Vth
            indici_intervallo = SDLM_Indice-20 : SDLM_Indice+20;
            %creaiamo dei valori vsg nell'intervallo calcolato con un
            %incremento di 0.1mV
            intervallo_alta_ris = vgs(indici_intervallo(1)) : 0.0001 : vgs(indici_intervallo(end));
            %Troviamo il valori dei coefficenti della funzione polinomiale
            coefficienti = polyfit(vgs(indici_intervallo), derivata_2_SDLM(indici_intervallo), GRADO);
            %calcoliamo le y della funzione polinomiale trovata
            grafico = polyval(coefficienti, intervallo_alta_ris);
            %estraiamo il minimo della polinomiale
            [min_grafico, ind_grafico] = min(grafico);
            %estraiamo il valore della Vth dalla polinomiale
            vth = intervallo_alta_ris(ind_grafico);
            
            
            %Plot di verifica
            if PLOT_ON
                figure
                hold on
                set(gca , "FontSize" , 12)
                titolo = titoloPlot(dispositivo);
                title("SDLM - " + titolo , FontSize=10);
                
                if tipo == 'P'
                    xlabeltxt = "$V_{SG}[V]$";
                    ylabeltxt = "$\frac{\mathrm {d}^2 \log{I_d}}{\mathrm {d} V_{SG}^2}[\frac{A}{V^2}]$";
                elseif tipo == 'N'
                    xlabeltxt = "$V_{GS}[V]$";
                    ylabeltxt = "$\frac{\mathrm {d}^2 \log{I_d}}{\mathrm {d} V_{GS}^2}[\frac{A}{V^2}]$";
                end
                
                xlabel(xlabeltxt , "Interpreter","latex", "FontSize",15);
                ylabel(ylabeltxt , "Interpreter", "latex", "FontSize", 15);
                %Plot dei dati calcolati
                plot(vgs(indici_intervallo),derivata_2_SDLM(indici_intervallo))
                %plot della vth dei dati calcolati
                xline(vth_SDLM_noFit,"--","Color","r");
                %plot della polinomiale
                plot(intervallo_alta_ris, grafico);
                %plot vth della polinomiale
                plot(vth , min_grafico , "*", color="r", MarkerSize=20)
                legend( "SDLM", "Minimo di SDLM", "Fit di grado "+ GRADO, "Minimo del fit");
                hold off
            end
            
            cd ..;
            
        end
        
        %funzione per il calcolo della vth con il metodo TCM
        function vth = TCM(dispositivo , GRADO , PLOT_ON)
            
            dispositivo = char(dispositivo);
            
            cd (string(dispositivo))
            
            tipo = dispositivo(1);
            
            % Nomi dei file contenenti il le Id, al variare di Vds, e Vgs
            file = "id-vgs.txt";
            
            if(exist("id_vgs.txt" , "file"))
                file = "id_vgs.txt";
            end
            
            %se il file non esiste ritorna una tabella vuota
            if(~exist(file ,"file"))
                vth = 0;
                cd ..;
                return;
            end
            
            % Carico i file
            id_Vgs_completo = readmatrix(file);
            % file composto da {Vg + (Id , Ig , Is , Iavdd , Igrd) * vd}
            
            % estraggo le Vg (sono uguali per entrambi i file)
            vgs = id_Vgs_completo(: , 1);
            
            if tipo == 'P'
                %predo le id_vgs per Vsd minima (150mV)
                id = id_Vgs_completo(: , end - 9);
                
                %calcoliamo i valori di Vsg
                vgs = 0.9 - vgs;
            else
                %predo le id_vgs per Vds minima (150mV)
                id = id_Vgs_completo(: , 7);
            end
            
            
            gm = gm_gds(id, vgs);
            gm = abs(gm);
            
            
            % Derivata della gm rispetto Vsg
            derivata_TCM = gradient(gm) ./ gradient(vgs);
            % Smooth della derivata
            derivata_TCM = smooth(derivata_TCM);
            % indice del valore massimo di di TCM per Vgs <= 700mV (700mV in posizione 201)
            [ ~ , indice_TCM] = max(derivata_TCM(1:201));
            
            vth_TCM_noFit = vgs(indice_TCM);
            
            
            % Calcolo del massimo della funzione polinomiale che interpola i punti
            % in un intorno di Vth calcolata con TCM a Vgs = 10 mV e di raggio 100 mV
            
            %prendiamo gli indici dell'intervallo +-100mV con centro Vth
            indici_intervallo = indice_TCM-20 : indice_TCM+20;
            %creaiamo dei valori vsg nell'intervallo calcolato con un
            %incremento di 0.1mV
            intervallo_alta_ris = vgs(indici_intervallo(1)) : 0.0001 : vgs(indici_intervallo(end));
            %Troviamo il valori dei coefficenti della funzione polinomiale
            coefficienti = polyfit(vgs(indici_intervallo), derivata_TCM(indici_intervallo), GRADO);
            % calcoliamo le y della funzione polinomiale trovata
            grafico = polyval(coefficienti, intervallo_alta_ris);
            % massimo della polinomiale
            [max_grafico, ind_grafico] = max(grafico);
            % Estraiamo la Vth dalla polinomiale
            vth = intervallo_alta_ris(ind_grafico);
            % se Vsd = 150mv teniamo gli intervalli per fare il grafico
            % dopo il for
            
            
            % Plot di verifica
            if PLOT_ON
                figure
                hold on
                set(gca , "FontSize" , 12)
                titolo = titoloPlot(dispositivo);
                title("TCM - " + titolo , FontSize= 10)
                % plot dati calcolati
                plot(vgs(indici_intervallo),derivata_TCM(indici_intervallo));
                % plot Vth calcolato senza il fit
                xline(vth_TCM_noFit,"--","Color","red");
                % plot della polinomiale
                plot(intervallo_alta_ris,grafico);
                % plot Vth calcolata con la polinomiale
                plot(vth , max_grafico, '*', color="r", MarkerSize=20);
                
                if tipo == 'P'
                    xlabeltxt = "$V_{SG}[V]$";
                    ylabeltxt = "$\frac{\mathrm {d} g_m}{\mathrm {d} V_{SG}}[\frac{A}{V^2}]$";
                elseif tipo == 'N'
                    xlabeltxt = "$V_{GS}[V]$";
                    ylabeltxt = "$\frac{\mathrm {d} g_m}{\mathrm {d} V_{GS}}[\frac{A}{V^2}]$";
                end
                
                xlabel(xlabeltxt , Interpreter="latex", FontSize=15);
                ylabel(ylabeltxt , Interpreter="latex", FontSize=15);
                legend("TCM","Massimo di TCM","Fit di grado "+ GRADO, "Massimo del fit")
            end
            
            cd ..;
            
        end
        
    end

    methods (Access = private , Static)
        %Funzione per RM_Estremi_preIrraggiamento quale trova gli estremi
        %su cui fare il fit
        function [estremo_sx , estremo_dx , vth] = getEstremi_RM(dispositivo)
            
            numero = dispositivo(2);
            tipo = dispositivo(1);
            cartella = "Chip" + numero + tipo + "MOS";
            
            cartella_attuale = pwd;
            
            cd ..;
            cd(cartella);
            
            [vth , estremi] = Vth.RM(dispositivo , 0 , 0);
            
            estremo_sx = estremi(1);
            estremo_dx = estremi(2);
            
            cd(cartella_attuale);
            
        end
        
        %Funzione per il metodo RM la quale estrae i dati che serve per RM
        function [tipo, vgs, rm_data] = Estrai_Dati_RM(dispositivo)
            tipo = dispositivo(1);
            
            % Nomi dei file contenenti il le Id, al variare di Vds, e Vgs
            file = "id-vgs.txt";
            
            if(exist("id_vgs.txt" , "file"))
                file = "id_vgs.txt";
            end
            
            %se il file non esiste ritorna una tabella vuota
            if(~exist(file ,"file"))
                vth = 0;
                cd ..;
                error("file non esiste");
            end
            
            % Carico i file
            id_Vgs_completo = readmatrix(file);
            % file composto da {Vg + (Id , Ig , Is , Iavdd , Igrd) * vd}
            
            % estraggo le Vg (sono uguali per entrambi i file)
            vgs = id_Vgs_completo(: , 1);
            
            if tipo == 'P'
                %predo le id_vgs per Vsd minima (150mV)
                id = id_Vgs_completo(: , end - 9);
                
                %calcoliamo i valori di Vsg
                vgs = 0.9 - vgs(:);
            else
                %predo le id_vgs per Vds minima (150mV)
                id = id_Vgs_completo(: , 7);
            end
            
            gm = abs(gm_gds(id, vgs));
            rm_data = id./sqrt(gm);
        end
        
        
        % funzione che ordina il cell array dei file Vth in base alla dimensione: prima
        % 100-30 poi 100-60, 100-180 poi con i 200 e i 600 (l'ultimo è il 600-180)
        function fileVth_sort = sortVthFile(fileVth)
            
            fileVth_sort = {};
            
            for i = fileVth
                file = string(i);
                file = char(file);
                file_noEst = file(1:(end-4)); %togliamo l'estensione.
                
                [~ , W , L] = titoloPlot(file_noEst); % se file è cosi: Vth_P1-600-180 ci ritorna W = 600 e L = 0.18
                
                if (W == 100)
                    if(L == 0.03)
                        fileVth_sort{1} = file;
                    elseif(L == 0.06)
                        fileVth_sort{2} = file;
                    elseif(L == 0.18)
                        fileVth_sort{3} = file;
                    end
                elseif(W == 200)
                    if(L == 0.03)
                        fileVth_sort{4} = file;
                    elseif(L == 0.06)
                        fileVth_sort{5} = file;
                    elseif(L == 0.18)
                        fileVth_sort{6} = file;
                    end
                elseif(W == 600)
                    if(L == 0.03)
                        fileVth_sort{7} = file;
                    elseif(L == 0.06)
                        fileVth_sort{8} = file;
                    elseif(L == 0.18)
                        fileVth_sort{9} = file;
                    end
                end
            end
        end
    end
end
