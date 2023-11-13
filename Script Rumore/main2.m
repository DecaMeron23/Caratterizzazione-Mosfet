function main2 (fondo,noise,fdt)
    rumore.noise_out(fondo,noise);
    hold off
          
    rumore.noise_in("noise_out.txt",fdt);
    hold off
end