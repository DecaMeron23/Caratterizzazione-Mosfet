%funzione che estrae per ogni metodo un file con tutte le vth dei i dispositivi
function EstraiVth
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
            matrice(i , :) = readmatrix(string(vth_file(i)))' * 1e3;   
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

