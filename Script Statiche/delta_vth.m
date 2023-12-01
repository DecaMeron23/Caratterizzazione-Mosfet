%% posizionarsi nella cartella dei chip (misurazioni statiche) e 
%% digitare il nome della funzione con parametro il nome del chip (P1, N1)

function delta_vth(dispositivo)
    
    % impostiamo che il tipo dispositivo è un array di caratteri
    dispositivo = char(dispositivo);
    
    % trovo la directory in cui ci troviamo
    directory = dir();
    % Lista dei file nella cartella
    lista_dispositivi = {directory.name};
    % verifichiamo se ci sono dei file nella cartella ( . e .. esclusi)
    if length(lista_dispositivi) <= 2
        error("Cartella dei dispositivi vuota...")
    end
    
    % sarà per esempio "Chip1PMOS"
    nomeDispositivo = "Chip"+ dispositivo(2) + upper(dispositivo(1)) + "MOS";
    
    % scorriamo tutte le cartelle (escludiamo . e ..) e teniamo solo le
    % cartelle del dispositivo che ci interessa
    cartelleDispostivo = {};
    for cartella = lista_dispositivi(3:end)
       if(contains(cartella , nomeDispositivo))
           cartelleDispostivo{end + 1} = cartella;
       end
    end

    % scorriamo tutte le cartelle del dispositivo e facciamo le nostre
    % operazioni
    for cartella = cartelleDispostivo

         cartella = string(cartella);

         grado = gradoIrraggiamento(cartella);
         
         cd(cartella);
                
         cd ..

    end


end

% funzione che data la cartella restituisce il grado di irraggiamento se è
% 0 resituisce "pre".
function grado = gradoIrraggiamento(nomeCartella)

        nomeCartella = extractAfter(nomeCartella ,"_");
        if ismissing(nomeCartella)
            nomeCartella = "Pre";
        else
            nomeCartella= extractBefore(nomeCartella, "M");
        end

        grado = nomeCartella;
        
        disp(grado);


end