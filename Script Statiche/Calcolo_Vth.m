%% Posizionarsi nella cartella dell'ASIC, a un certo grado di irraggiamento, con all'interno tutte le cartelle dei dispositivi
%% Impostare a 1 la variabile PLOT_ON se si vogliono vedere tutti i plot che elabora lo script
%% Impostare a 1 se la variabile preIrreggiamento se il dispositivo non è ancora stato irraggiato
%% per ogni cartella serve avere i fle .txt delle misurazioni
%% inizializzazione
clear; clc;

 % abilitare i plot di verifica (si = 1, no = 0)  
PLOT_ON = 0;

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
            ~contains(dispositivo,'nf'))

        vth_FIT = FIT_LIN(dispositivo , PLOT_ON)*1000;
        vth_TCM= TCM(dispositivo , GRADO , PLOT_ON)*1000;
        vth_SDLM = SDLM (dispositivo , GRADO , PLOT_ON)*1000;
      
        formato = '%3.1f';

        vth_FIT = string(sprintf(formato, vth_FIT));
        vth_TCM = string(sprintf(formato, vth_TCM));
        vth_SDLM = string(sprintf(formato, vth_SDLM));

        vth = [vth_FIT , vth_TCM , vth_SDLM];
        
        %% Save File
        %Rinonimo le intestazioni

        vth = array2table(vth);
        vth = renamevars(vth , ["vth1" , "vth2" "vth3"] , ["Lin_fit_Id", "Vth_TCM", "Vth_SDLM"]);
        
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