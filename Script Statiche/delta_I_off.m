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

                    if ~exist("id-vgs.txt","file") && ~exist("id_vgs.txt","file")
                        delta(j , i) = NaN;
                    else
                        I_off = calcola_I_off(valori_vds(j), char(cartella_dispositivo));
                        
                        if(i == 1)
                                I_off_pre(j , 1) = I_off;
                                delta( j , 1) = 0;
                            else
                                delta(j , i) = abs((I_off - I_off_pre(j,1))); 
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
    tabelleRaggruppateDispositivo()
    
    cd ..
end

function tabelleRaggruppateDispositivo()
    ARRAY_VDS_mV = 150:150:900;
    
    for VDS_mV = ARRAY_VDS_mV
        tabellaRaggruppataDispositivo_Vds(VDS_mV)
        plotDeltaIoff_Vds(VDS_mV);
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


    X_LABEL = "\textit{TID} $[Mrad]$";
    Y_LABEL = "$\Delta I_{off} [A]$";

    cd tabelle\
    
    temp = readmatrix(NOME_FILE_LETTURA);
    % escludiamo il nome del dispositivo
    dati = temp(: , 2:end);

    indice_dispositivo = 0; 
    for W = ARRAY_W
        figure
        for L = ARRAY_L
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

        legend(Interpreter="latex" , FontSize=12 , Location="best");
        ylabel(Y_LABEL);
        xlabel(X_LABEL);
        xlim([0 3500]);


        title(sprintf(TITOLO , TIPO_DISPOSITIVO , W));

        grid on

        ax = gca;
        ax.XTick = X_TICKS; 
        % Imposta le etichette degli x-ticks
        ax.XTickLabel = X_TICKS_LABEL;
        
        saveas(gcf , NOME_FIGURA);

        cd ..\..
        cd tabelle\ 
    end

    cd ..
    close all


end

function I_off = calcola_I_off(vds, dispositivo)

    if exist("id-vgs.txt","file")
        id_vgs = readmatrix("id-vgs.txt");
    elseif exist("id_vgs.txt","file")
        id_vgs = readmatrix("id_vgs.txt");
    end

    id_vgs = id_vgs(1,[2,7,12,17,22,27,32]);

    L_dispositivo = str2double(string(dispositivo(8:end)))*1e-9;
    N_finger = str2double(string(dispositivo(4:6))) / 2.5;

    if(dispositivo(1) == 'P')
        indice_vds = 7-vds/0.15;
    else 
        indice_vds = 1+vds/0.15;
    end
    I_off = id_vgs(indice_vds)*L_dispositivo/N_finger;
end
