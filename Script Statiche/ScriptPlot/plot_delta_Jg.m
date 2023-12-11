function plot_delta_Jg(cartella)
%% Posizionarsi nella cartella di un dispositivo con i diversi irraggiamenti
% Funzione che per ogni dispositivo prende le diverse Jg a diversi
% irraggiamenti e li mette nello stesso plot.
    if nargin == 0
        cartella = pwd;
    else
        cd(cartella);
    end

    cartella = char(cartella);

    if(contains(cartella , "P1"))
        type = "P1";
    elseif(contains(cartella , "N4"))
        type = "N4";
    end

    type = char(type);

    dispositivi = {'100/0.030', '100/0.060', '100/0.180' , '200/0.030', '200/0.060', '200/0.180' , '600/0.030', '600/0.060', '600/0.180'};
    
    if(~exist("plot\"))
        mkdir plot;
    end

    cartelleDispostivo = getFileCartella("MOS");
    
    %se è vuota terminiamo
    if(isempty(cartelleDispostivo))
        disp("Nessun dispositivo trovato...");
        return;
    end

    cartelleDispostivo  = sortCartelleIrraggiamento(cartelleDispostivo);

    grado = {};

    array_figure = gobjects(1, 9);
    for i = 1: length(array_figure)
        array_figure(i) = figure;
    end

    %per ogni irraggiamento
    for i = cartelleDispostivo
        cartella_irraggiamento = char(string(i));
        grado{end+1} = gradoIrraggiamento(cartella_irraggiamento);
        array_figure = jg_figure(cartella_irraggiamento , grado , array_figure , type);
    end

    cd plot\

    if(~exist("fig" , "dir"))
        mkdir fig
    end

    if(~exist("png" , "dir"))
        mkdir png
    end

    if(~exist("eps" , "dir"))
        mkdir eps
    end


    for i = 1 : length(array_figure)
        figure(array_figure(i));
        nomefile = char(dispositivi(i));
        nomefile = "Jg_"+ nomefile(1:3) + "-" + nomefile(5:end);
    
        title(type(1)+"MOS " + string(dispositivi(i)));

        set(gca, 'FontSize', 12);

        legend(grado , Location="southeast");

        if(type(1) == 'N')
            xlabel("$V_{gs} [V]$" , Interpreter="latex" );
        elseif(type(1) == 'P')
            xlabel("$|V_{gs}| [V]$" , Interpreter="latex");
        end

        ylabel("$|J_g| [A / cm^2]$" , Interpreter="latex");   

        grid on

        cd fig
        saveas(gcf , nomefile + ".fig");
        cd ..\png
        saveas(gcf , nomefile + ".png" , "png");
        cd ..\eps
        saveas(gcf , nomefile + ".eps", "eps");
        cd ..
    end
    cd ..

    close all;
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


% funzione che data la cartella restituisce il grado di irraggiamento se è
% 0 resituisce "pre".
function grado = gradoIrraggiamento(nomeCartella)

        nomeCartella = extractAfter(nomeCartella ,"_");
        if isempty(nomeCartella)
            nomeCartella = "Pre";
        elseif(~contains(nomeCartella , "Grad"))
            nomeCartella = extractBefore(nomeCartella, "M");
            nomeCartella = nomeCartella + "Mrad";
        else
            nomeCartella = extractBefore(nomeCartella, "G");
            nomeCartella = nomeCartella + "Grad";
        end

        grado = nomeCartella;
        
        disp(grado);
end

% funzione che per uno specifico irraggiamento fa i plot
function  array_figure = jg_figure(cartella_irraggiamento , grado , array_figure , type)
    
    cd(cartella_irraggiamento);
    
    cartelleDispositivi = getFileCartella(type+ "-");
    cartelleDispositivi = sortFolder(cartelleDispositivi);
    
    for i = 1: length(cartelleDispositivi)
        dispositivo_attuale = char(string(cartelleDispositivi(i)));
        cd(dispositivo_attuale)
        [mod_Jg , Vgs] = EstrazioneDati.estrazione_dati_jg_vgs("id_vgs.txt" , type(1) , dispositivo_attuale);
        figura = array_figure(i);
        figure(figura);
        hold on
        semilogy(Vgs , mod_Jg);
        %legend(grado);
        set(gca, 'YScale', 'log');
        hold off
        cd ..
    end
    cd ..
end

% funzione che ordina il cell array delle cartelle in base alla dimensione: prima
% 100-30 poi 100-60, 100-180 poi con i 200 e i 600 (l'ultimo è il 600-180)
function folderSort = sortFolder(fileVth)

    folderSort = {};

    for i = fileVth
        file = string(i);
        file = char(file);
        [~ , W , L] = titoloPlot(file); % se file è cosi: P1-600-180 ci ritorna W = 600 e L = 0.18

        if (W == 100)
            if(L == 0.03)
                folderSort{1} = file;
            elseif(L == 0.06)
                folderSort{2} = file;
            elseif(L == 0.18)
                folderSort{3} = file;
            end
        elseif(W == 200)
            if(L == 0.03)
                folderSort{4} = file;
            elseif(L == 0.06)
                folderSort{5} = file;
            elseif(L == 0.18)
                folderSort{6} = file;
            end
        elseif(W == 600)
            if(L == 0.03)
                folderSort{7} = file;
            elseif(L == 0.06)
                folderSort{8} = file;
            elseif(L == 0.18)
                folderSort{9} = file;
            end
        end
    end
end
