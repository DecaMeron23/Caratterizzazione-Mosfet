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


for i = 3 : length(fileInFolder)
    dispositivo = char(fileInFolder(i));
    if ((dispositivo(1) == 'N' || dispositivo(1) == 'P') && dispositivo(3) == '-' &&  ...
            ~strcmp(dispositivo,'N4-600-30')  &&  ~strcmp(dispositivo,'P1-100-180_nf'))

        if dispositivo(1) == 'N' 
            vth = Id_Vgs_N(dispositivo);
        elseif dispositivo(1) == 'P'
            vth = Id_Vgs_P(dispositivo);
        end
      
        %% Save File
        %Rinonimo le intestazioni
        vth = renamevars(vth , ["Var1", "Var2", "Var3", "Var4"] , ["Vd" ,"Lin_fit_Id", "Vth_TCM", "Vth_SDLM"]);
        
        Cartella = "Vth";
       
        if ~exist(Cartella , "dir")
            mkdir(Cartella);  
        end
        
        cd(Cartella);
         
        
        %Salvo File nella cartella
        writetable( vth, "Vth_" + dispositivo + ".txt",  "Delimiter", "\t");

        cd ..
        
     end
end

clear;