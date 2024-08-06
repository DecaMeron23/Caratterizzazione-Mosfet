classdef estrazioneCartelle

    methods (Static)
    %% funzione che prende tutte le cartelle dei diversi irraggiamenti ordinate per grado
    function [cartelle, tipologia]= getCartelle()
    
        [~, nomeDispositivo, ~] = fileparts(pwd);
        
        tipologia = upper(nomeDispositivo(1));
        nomeDispositivo = "Chip" + nomeDispositivo(2) + upper(nomeDispositivo(1))+"MOS";
        
         % impostiamo che il tipo dispositivo è un array di caratteri
        nomeDispositivo = char(nomeDispositivo);
        
        % cartelle del dispositivo che ci interessa
        cartelle = estrazioneCartelle.getFileCartella(nomeDispositivo);
        
        cartelle = estrazioneCartelle.sortCartelleIrraggiamento(cartelle);
    
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
            elseif(contains(folder , "3Grad"))
                cartelle_sort{8} = folder;
            else
                cartelle_sort{1} = folder;
            end
    
        end
    end

    end
end