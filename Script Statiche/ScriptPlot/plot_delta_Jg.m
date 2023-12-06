function plot_delta_Jg(cartella)
% Funzione che per ogni dispositivo prende le diverse Jg e le mette insieme.    
    if nargin == 0
        cartella = pwd;
    end

    dispositivi = ["100-30", "100-60", "100-60" , "200-30", "200-60", "200-180" ,"600-30", "600-60", "600-180"];
    irraggiamento = ["" , "5Mrad" , "50Mrad" , "100Mrad" , "200Mrad" , "600Mrad" , "1Grad"];
    
    if(~exist("plot\"))
        mkdir plot;
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
