%% Posizionarsi all'interno dell'asic con le diverse cartelle 
%% dei irraggiamenti
directory = dir;
file = {directory.name};

cartelle_irraggiamenti = {};

for i = 3 : length(file)
    file_string = string(file(i));

    if contains(file_string , "Chip")
        cartelle_irraggiamenti{end + 1} = file_string;
    end
end

for i = 1: length(cartelle_irraggiamenti)
    disp(i + "/" + length(cartelle_irraggiamenti) + ")"+ "Inizio:" + string(cartelle_irraggiamenti(i)));
    cd(string(cartelle_irraggiamenti(i)))
    Calcolo_Vth
    cd ..
end