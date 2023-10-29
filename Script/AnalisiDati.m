%% inizializzazione
clear; clc;

% indichiamo se il dispositivo è pre irraggiato
preIrraggiamento = 0;

if preIrraggiamento == 1
    SPAN = 20;
    GRADO = 6;
elseif preIrraggiamento == 0
    SPAN = 5;
    GRADO = 6;
end

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
            ~strcmp(dispositivo,'N3-600-30')  &&  ~strcmp(dispositivo,'P1-100-180_nf'))

        if dispositivo(1) == 'N' 
            vth = Id_Vgs_N(dispositivo , SPAN , GRADO);
        elseif dispositivo(1) == 'P'
            vth = Id_Vgs_P(dispositivo , SPAN , GRADO);
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