%% mettersi nella dirctory con i dispositivi di un certo chip 

PLOT_ON = 0;

% trovo la directory in cui ci troviamo
directory = dir();
% Lista dei file nella cartella
lista_dispositivi = {directory.name};
% verifichiamo se ci sono dei file nella cartella ( . e .. esclusi)
if length(lista_dispositivi) <= 2
    error("Cartella dei dispositivi vuota...")
end

dispositivi_funzionanti = [];

for i = 1 : length(lista_dispositivi)
    dispositivo = char(lista_dispositivi(i));
    if strcmp(dispositivo(1), 'N') || strcmp(dispositivo(1), 'P') && ~strcmp(dispositivo(end-1:end), 'nf')
        dispositivi_funzionanti = [dispositivi_funzionanti; string(dispositivo)];
        for j = 1:4
            Vth_TCM(length(dispositivi_funzionanti),j) = TCM_P(dispositivo , j*2 , PLOT_ON);
            Vth_SDLM(length(dispositivi_funzionanti),j) = SDLM_P(dispositivo , j*2 , PLOT_ON);
        end
     end
end

vth = [dispositivi_funzionanti Vth_SDLM Vth_TCM];
vth = renamevars(vth , ["Var1", "Var2", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "var9"] , ...
    ["Dispositivi" ,"SDLM grado 2", "SDLM grado 4", "SDLM grado 6", ...
    "TCM grado 8", "TCM grado 2", "TCM grado 4", "TCM grado 6", "TCM grado 8"]);
writetable( vth, "Confronto_Vth.txt",  "Delimiter", "\t");

