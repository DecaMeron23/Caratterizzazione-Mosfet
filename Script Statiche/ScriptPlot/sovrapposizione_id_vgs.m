function sovrapposizione_id_vgs(dispositivo) % il dispositivo in formato: "200-30"
    %% Obbiettivo: fornire un plot di come varia la caratteristica id-vgs al variare della dose 
    % posizionarsi nella cartella contenente le cartelle dei siversi
    % irragiamenti
    
    [cartelle, tipologia]= getCartelle();
    
    %inizializziamo la legenda
    legenda = ["Pre" "5Mrad" "50Mrad" "100Mrad" "200Mrad" "600Mrad" "1Grad"];
    
    for i = 1 : length(cartelle)
    
        cartella_i = string(cartelle(i));
        cd(cartella_i);
        
        % troviamo le cartelle che contengono la stringa dispositivo (mi aspetto che ce ne sia solo una)
        cartellaDispositivo = getFileCartella(dispositivo);
    
        % entriamo nella cartella
        cd(string(cartellaDispositivo(1)));

        file = "id-vgs.txt";
        if (~exist(file,  "file"))
            file = "id_vgs.txt";
        end

        %estraiamo i dati
        [vgs , id , ~] = EstrazioneDati.estrazione_dati_vgs(file , tipologia);
    
        % prendiamo a max vgs per i P max vsg
        id = id(: , end)*1e6;
    
        %semilogy(vgs , id , LineWidth=1);  
        plot(vgs , id  ,LineWidth=1);
        

        hold on

        cd ../..
    end
    
    xlim([0.3 , 1]);

    dispositivo = char(dispositivo);
    W = dispositivo(1:3);
    L = "0.0"+dispositivo(5:end);

    ylabel("$I_{d}[A]$" , Interpreter="latex" , FontSize=12);
    xlabel("$v_{gs}[V]$" , Interpreter="latex" , FontSize= 12);
    title("Dispositivo $"+ W + "/"+ L +"$" , Interpreter="latex" , FontSize= 12);
    legend(legenda);
    hold off

end

%% funzione che prende tutte le cartelle dei diversi irraggiamenti ordinate per grado
function [cartelle, tipologia]= getCartelle()


[~, nomeDispositivo, ~] = fileparts(pwd);

tipologia = upper(nomeDispositivo(1));
nomeDispositivo = "Chip" + nomeDispositivo(2) + upper(nomeDispositivo(1))+"MOS";

 % impostiamo che il tipo dispositivo è un array di caratteri
nomeDispositivo = char(nomeDispositivo);

% cartelle del dispositivo che ci interessa
cartelle = getFileCartella(nomeDispositivo);

cartelle = sortCartelleIrraggiamento(cartelle);

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