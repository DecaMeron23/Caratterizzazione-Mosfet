%% Descrizione calcoli
% Questa funzione serve a calcolare il guadagno intrinseco, ovvero il massimo
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
function GuadagnoIntrinseco()
    
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
    cartelle_dispositivi = estrazioneCartelle.getFileCartella(type); % le cartelle dovrebbero essere in ordine per W
    %prendiamo solo le cartelle (e non i file)
    cartelle_dispositivi = estrazioneCartelle.getSoloCartelle(cartelle_dispositivi);
    % ordiniamo le cartelle secondo L (30 60 180)
    cartelle_dispositivi = ordinaCartelle(cartelle_dispositivi);

    legenda = [];
    for i = 1:length(cartelle_dispositivi)
        cartella = string(cartelle_dispositivi(i));

        if ~contains(cartella , "nf")% se è un dispositivo funzionante continuiamo    
            cd(cartella); % ci muoviamo nella cartella
            try
                [g , ic0] = guadagnoIntrinseco_singolo();
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
            
            saveFigure(W);
            
            if i ~= length(cartelle_dispositivi)
                figure % facciamo una nuova figura
                legenda = [];
            end
        end
    
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

function saveFigure(W)
    if(~exist("plot\" , "dir"))
        mkdir plot\
    end
    cd plot\
    nome_file = "Guadagno_Intrinseco_W-" + W + ".png";
    saveas(gcf, nome_file);
    cd ..
end