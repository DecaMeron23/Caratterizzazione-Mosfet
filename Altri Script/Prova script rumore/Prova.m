% trovo la directory in cui ci troviamo
directory = dir();
% Lista dei file nella cartella
lista_misurazioni = {directory.name};
% verifichiamo se ci sono dei file nella cartella ( . e .. esclusi)
if length(lista_misurazioni) <= 2
    error("Cartella dei dispositivi vuota...")
end

for j = 1:length(lista_correnti)
            corrente = char(lista_correnti(j));
            if length(corrente) >= 2 && strcmp(corrente(end-1:end), 'uA') %considero solo le cartelle delle correnti
                cd(corrente)
                directory = dir();
                lista_misurazioni = {directory.name};
                if length(lista_correnti) <= 2
                    error("Cartella delle misurazioni vuota...")
                end

                noise = '';
                fondo = '';
                fdt = '';
                for k = 1:length(lista_misurazioni)
                    misurazione = char(lista_misurazioni(k));
                    if length(misurazione) >= 8 %se il nome del file è piu' corto di otto caratteri non posso fare la successive comparazioni
                        if strcmp(misurazione(1:8), 'noise_P1') || strcmp(misurazione(1:8), 'noise_N1')
                            noise  = misurazione;
                        elseif strcmp(misurazione(1:8), 'fondo_P1') || strcmp(misurazione(1:8), 'fondo_N1')
                            fondo  = misurazione;
                        elseif strcmp(misurazione(1:6), 'fdt_P1') || strcmp(misurazione(1:8), 'fdt_N1')
                            fdt  = misurazione;
                        end
                    end
                    if ~strcmp(noise, '') && ~strcmp(fondo, '') && ~strcmp(fdt, '')
                        Analisi_rumore(fondo, noise, fdt);
                    end
                end

                 cd ..;
            end
        end