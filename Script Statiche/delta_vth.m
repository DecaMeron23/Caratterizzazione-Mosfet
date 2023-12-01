%% posizionarsi nella cartella dei chip (misurazioni statiche) e 
%% digitare il nome della funzione con parametro il nome del chip (P1, N1)

function delta_vth(dispositivo)
% trovo la directory in cui ci troviamo
directory = dir();
% Lista dei file nella cartella
lista_dispositivi = {directory.name};
% verifichiamo se ci sono dei file nella cartella ( . e .. esclusi)
if length(lista_dispositivi) <= 2
    error("Cartella dei dispositivi vuota...")
end




end