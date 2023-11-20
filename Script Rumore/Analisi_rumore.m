function Analisi_rumore(fondo,noise,fdt)
    nome_misurazione = fondo(6:end);
    cartella_misurazione = string(unique({dir().folder}));

    if strcmp(fondo(16), '_')
        cartella_finale = ['..\..\rumore_finale\' fondo(7:15)];
    else 
        cartella_finale = ['..\..\rumore_finale\' fondo(7:16)];
    end

    const = 4 * 300 * 25 * 1.38E-23; %densità spettrale di potenza di rumore di una resisenza da 25 Ohm
    noise = readmatrix(noise);
    fondo = readmatrix(fondo);
    fdt = readmatrix(fdt);
    altezza = length(noise(:,1));
    ris = zeros(altezza,2);
    ris(:,1) = noise(:,1);
    for i = 1 : altezza
        r = sqrt((sqrt(noise(i,2)^2 - fondo(i,2)^2)/10^(fdt(i,2)/20))^2 -const)*1E9;
        if imag(r) ~= 0
            r = "";
        end
        ris(i,2) = r;
    end

    %%salvo il documento
    if ~exist(cartella_finale , "dir")
            mkdir(cartella_finale);  
    end
    cd(cartella_finale);
    writematrix(ris,['noise_finale' nome_misurazione],'delimiter', ' ')
    cd(cartella_misurazione);
end