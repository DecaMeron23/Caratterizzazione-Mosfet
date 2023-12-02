%% posizionarsi nella cartella dei chip (misurazioni statiche) e 
%% digitare il nome della funzione con parametro il nome del chip (P1, N1)

function delta_vth(dispositivo)
    
    % impostiamo che il tipo dispositivo è un array di caratteri
    dispositivo = char(dispositivo);
   
    % sarà per esempio "Chip1PMOS"
    nomeDispositivo = "Chip"+ dispositivo(2) + upper(dispositivo(1)) + "MOS";
    
    % cartelle del dispositivo che ci interessa
    cartelleDispostivo = getFileCartella(nomeDispositivo);

    %se è vuota terminiamo
    if(isempty(cartelleDispostivo))
        disp("Dispositivo " + nomeDispositivo + " non trovato...");
        return;
    end

    cartelleDispostivo  = sortCartelleIrraggiamento(cartelleDispostivo);
    

    delta_FIT = {};
    delta_TCM = {};
    delta_SDLM = {};
    % scorriamo tutte le cartelle del dispositivo e facciamo le nostre
    % operazioni
    for i = 1:length(cartelleDispostivo)

         folder = string(cartelleDispostivo(i));
         grado = gradoIrraggiamento(folder);
            
         folder = folder + "\Vth\";
         if(exist(folder , "dir"))
            cd(folder);
                fileVth = getFileCartella("Vth");
                % estraiamo i dati
                delta_FIT{end+1} = estraiVth(fileVth , "FIT");
                delta_TCM{end+1} = estraiVth(fileVth , "TCM");
                delta_SDLM{end+1} = estriVth(fileVth , "SDLM");
                
                %facciamo i delta
                if (length(delta_FIT) > 1) % se non sono i pre
                    delta_FIT{end+1} = cell2mat(delta_FIT{end}) - cell2mat(delta_FIT{1}) ;
                    delta_TCM{end+1} = ;
                    delta_SDLM{end+1} =;
                end
            cd ..\..
         else
             disp("Per l'irraggiamento a " + grado + " non c'è la cartella Vth");
         end
         

    end


end

% funzione che data la cartella restituisce il grado di irraggiamento se è
% 0 resituisce "pre".
function grado = gradoIrraggiamento(nomeCartella)

        nomeCartella = extractAfter(nomeCartella ,"_");
        if ismissing(nomeCartella)
            nomeCartella = "Pre";
        else
            nomeCartella = extractBefore(nomeCartella, "M");
            nomeCartella = nomeCartella + "Mrad";
        end

        grado = nomeCartella;
        
        disp(grado);
end

% Funzione che prende tutti i file nella cartella, si può inserire un
% parametro opzionale che sarà una striga che devono contenere i file
% restituiti (so che non mi sono spiegato... però spero che scriverò il codice in modo da farlo capire)
function fileInFolder = getFileCartella(varargin)

            directory = dir();
            fileInFolder = {directory.name};
            fileInFolder(1:2) = []; % rimuovo . e ..

            if(~isempty(varargin))
                fileInFolder_controllati = {};
                regola = string(varargin{1});
                for file_i = fileInFolder
                    file = string(file_i);
                    if(contains(file , regola))
                        fileInFolder_controllati{end+1} = file;
                    end
                end
                fileInFolder = fileInFolder_controllati;
            end
end

% sortiamo le cartelle con l'ordine pre 10M 50M 100M 200M 600M 1G
function  cartelle_sort = sortCartelleIrraggiamento(cartelle)

    cartelle_sort = {};
    for i = cartelle
        folder = string(i);
        if(contains(folder , "5Mrad"))
            cartelle_sort{2} = folder;
        elseif(contains(folder , "50Mrad"))
            cartelle_sort{3} = folder;
        elseif(contains(folder , "100Mrad"))
            cartelle_sort{4} = folder;
        elseif(contains(folder , "200Mrad"))
            cartelle_sort{5} = folder;
        elseif(contains(folder , "600Mrad"))
            cartelle_sort{6} = folder;
        elseif(contains(folder , "1Grad"))
            cartelle_sort{7} = folder;
        else
            cartelle_sort{1} = folder;
        end

    end
end

% funzione che prende un cell arry, di file .txt che conterranno le Vth per
% ogni dispositivo, e una stringa che indica che tipo di metodo si deve
% utilizzare.
% restituisce un array dei valori delle Vth in ordine per dimensione prima
% 100-30 poi 100-60 100-180 poi con i 200 e i 600 (l'ultimo è il 600-180)
function Vth =  estraiVth(fileVth , tipo_estrazione)
    
    if(strcmp(tipo_estrazione , "FIT"))
        posizione = [1 , 2]; % posizione intesa come riga colonna
    elseif(strcmp(tipo_estrazione , "TCM"))
        posizione = [1 , 3];
    elseif(strcmp(tipo_estrazione , "SDLM"))
        posizione = [6 , 4];
    end


    Vth = zero(9 , 1); % creaimo l'array di 9 righe

    fileVth = sortVthFile(fileVth);

    for i = 1:length(fileVth) 
        % se non c'è la Vth per quel dispositivo la settiamo a 0
        if(ismissing(fileVth{i}))
            Vth(i) = 0;
        else
            file = char(fileVth{i});
            
            Vth_Dispositivo = readmatrix(file);
            
            Vth(i) = Vth_Dispositivo(posizione(1) , posizione(2));
        end
    end

end

% funzione che ordina il cell array dei file Vth in base alla dimensione: prima
% 100-30 poi 100-60, 100-180 poi con i 200 e i 600 (l'ultimo è il 600-180)
function fileVth_sort = sortVthFile(fileVth)

    fileVth_sort = {};

    for i = fileVth
        file = char(i);
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