%% Posizionarsi nella cartella dell'ASIC, a un certo grado di irraggiamento, con all'interno tutte le cartelle dei dispositivi
%% Impostare a 1 la variabile PLOT_ON se si vogliono vedere tutti i plot che elabora lo script
%% Impostare a 1 se la variabile preIrreggiamento se il dispositivo non è ancora stato irraggiato
%% per ogni cartella serve avere i fle .txt delle misurazioni
%% inizializzazione
clear; clc;

 % abilitare i plot di verifica (si = 1, no = 0)  
PLOT_ON = 1;

% indichiamo se il dispositivo è pre irraggiamento
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
    if ((dispositivo(1) == 'N' || dispositivo(1) == 'P') && (dispositivo(3) == '-')&&  ...
            ~strcmp(dispositivo,'N4-600-30')  &&  ~strcmp(dispositivo(end-1:end),'nf'))

        if dispositivo(1) == 'N' 
            vth = Id_Vgs_N(dispositivo , SPAN , GRADO , PLOT_ON);
        elseif dispositivo(1) == 'P'
            vth = Id_Vgs_P(dispositivo , SPAN , GRADO , PLOT_ON);
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