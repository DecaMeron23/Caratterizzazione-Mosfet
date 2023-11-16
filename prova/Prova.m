function Prova(fondo,noise,fdt)
    const = 4.14E-19; %densità spettrale di potenza di rumore di una resisenza da 25 Ohm
    noise = readmatrix(noise);
    fondo = readmatrix(fondo);
    fdt = readmatrix(fdt);
    altezza = length(noise(:,1));
    ris = zeros(altezza,2);
    ris(:,1) = noise(:,1);
    for i = 1 : altezza
        if noise(i,2) > fondo(i,2)
            r = sqrt(noise(i,2)^2 - fondo(i,2)^2) / 10^(fdt(i,2)/20);
        else 
            r = -1;
        end
        if r > const
            r = sqrt(r^2-const^2) * 1E9;
        else 
            r = "";
        end
        ris(i,2) = r;
    end
     writematrix(ris,'noise_in.txt','delimiter', ' ')

end