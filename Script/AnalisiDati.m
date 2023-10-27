%% inizializzazione
clear; clc;

% trovo la directory in cui ci troviamo
fp = dir();
% Lista dei file nella cartella
fileInFolder = {fp.name};
% verifichiamo se ci sono dei file nella cartella ( . e .. esclusi)
if length(fileInFolder) <= 2
    error("Cartella vuota...")
end

% prendo il nome completo della cartella (es: "C:\Dispositivi\N1_100-30")
nameFolder = fp.folder;


for i = 3 : length(fileInFolder)
    [~ , cartella] = fileparts(nameFolder);
    dispositivo = char(fileInFolder(i));
    if (dispositivo(1) == 'P' || dispositivo(1) == 'N') && dispositivo(3) == '-' && ~strcmp(dispositivo,'N4-600-30')

        vth = Id_Vgs_Script(dispositivo);
      
        %% Save File
        %Rinonimo le intestazioni
        vth = renamevars(vth , ["Var1", "Var2", "Var3"] , ["Vd" , "Vth_TCM", "Vth_SDLM"]);
        
        Cartella = "Vth";
       
         mkdir(Cartella);  
         cd(Cartella);
         
        
        %Salvo File nella cartella
        writetable( vth, "Vth_" + dispositivo + ".txt",  "Delimiter", "\t");

        cd ..
     end
end