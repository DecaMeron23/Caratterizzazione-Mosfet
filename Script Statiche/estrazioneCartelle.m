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

    % funzione che prende tutte le cartelle dei diversi dispositivi
    % ordinate per dimensione prima le W (100, 200, 600) e poi L(30, 60, 180)
    function [cartelle]= getCartelleDispositivi(rimuovi_nf)

        if nargin == 0
            rimuovi_nf = false;
        end

        [~, nomeDispositivo, ~] = fileparts(pwd);
        
        temp = char(extractBefore(nomeDispositivo , "MOS"));
        tipologia = temp(end);
        numero_chip = temp(end-1);

        nomeDispositivo ="" + tipologia + numero_chip;
       
         % impostiamo che il tipo dispositivo è un array di caratteri
        nomeDispositivo = char(nomeDispositivo);
        
        % cartelle del dispositivo che ci interessa
        cartelle = estrazioneCartelle.getFileCartella(nomeDispositivo);
        
        cartelle = estrazioneCartelle.sortCartelleDispositivo(cartelle);

    
        %rimuoviamo i dispositivi non funzionanti
        if rimuovi_nf
            cartelle_new = {};
            for i = 1:length(cartelle)
                cartella_attuale = string(cartelle(i));
                if ~contains(cartella_attuale , "nf")
                    cartelle_new{end+1} = cartella_attuale;
                end
            end
            cartelle = cartelle_new;
        end
    end


    %funzione che ordina le cartelle per dimensione dispositivo
    function cartelle_ordinate = sortCartelleDispositivo(cartelle)
        

        for i = 1: length(cartelle)
            cartella_attuale = string(cartelle(i));
            elementi = split(cartella_attuale , "-");
            W = str2double(elementi(2));
            L = str2double(elementi(3));

            if (W == 100)
                if(L == 30)
                    cartelle_ordinate{1} = cartella_attuale;
                elseif(L == 60)
                    cartelle_ordinate{2} = cartella_attuale;
                elseif(L == 180)
                    cartelle_ordinate{3} = cartella_attuale;
                end
            elseif(W == 200)
                if(L == 30)
                    cartelle_ordinate{4} = cartella_attuale;
                elseif(L == 60)
                    cartelle_ordinate{5} = cartella_attuale;
                elseif(L == 180)
                    cartelle_ordinate{6} = cartella_attuale;
                end
            elseif(W == 600)
                if(L == 30)
                    cartelle_ordinate{7} = cartella_attuale;
                elseif(L == 60)
                    cartelle_ordinate{8} = cartella_attuale;
                elseif(L == 180)
                    cartelle_ordinate{9} = cartella_attuale;
                end
            end


        end
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
            elseif(contains(folder , "annealing"))
                cartelle_sort{9} = folder;
            else
                cartelle_sort{1} = folder;
            end
    
        end
    end


    % funzione che serve per scorrere all'interno delle cartelle delle
    % misure statiche ed ogni volta che si è all'interno si esegue la
    % funzione f
    function esegui_per_ogni_irraggiamento(f)
        
        [cartelle , ~ ] = estrazioneCartelle.getCartelle();
        
        n_max = length(cartelle);
        if(n_max <= 0)
            warning("Nessuna cartella trovata");
        end
        for i = 1:n_max

            cartella_attuale = string(cartelle(i));

            disp("[" + i +"/"+ n_max+"]"+cartella_attuale);
            cd(cartella_attuale);
            f();
            cd ..
        end

    end
    % funzione che serve per scorrere all'interno di tutte le cartelle ad
    % una certa dose di irraggiamento, nella quale poi eseguirà la funzione
    % f
    function esegui_per_ogni_dispositivo(f , no_nf)
        
         if nargin == 1
            no_nf = false;
        end
        
        cartelle = estrazioneCartelle.getCartelleDispositivi(no_nf);
        
        n_max = length(cartelle);

        if(n_max <= 0)
            warning("Nessuna cartella trovata");
        end
        for i = 1:n_max
            
            cartella_attuale = string(cartelle(i));

            disp("[" + i +"/"+ n_max+"]"+cartella_attuale);
            cd(cartella_attuale);
            f();
            cd ..
        end

    end

    end
end