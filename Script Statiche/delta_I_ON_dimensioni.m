%% posizionarsi nella cartella del chip con il relativo irraggimento (es: Chip1PMOS_5Mrad)
%% delta I_on al variare di W o di L 

% trovo la directory in cui ci troviamo
directory = dir();
% Lista dei file nella cartella
lista_dispositivi = {directory.name};
% verifichiamo se ci sono dei file nella cartella ( . e .. esclusi)
if length(lista_dispositivi) <= 2
    error("Cartella dei dispositivi vuota...")
end

L = [30 60 180];
W = [100 200 600];
I_ON_W = zeros(3);

%% delta I_ON in funzione di L con parametro W


for i = 1:length(lista_dispositivi)
    dispositivo = char(lista_dispositivi(i));
    if (strcmp(dispositivo(1), 'P') || strcmp(dispositivo(1), 'N')) &&  ~strcmp(dispositivo(end-1:end), 'nf') 
        
        I_ON = abs(estrai_I_ON(dispositivo))*1e3;

        switch dispositivo(4:end)
            case '100-30'
                I_ON_W(1,1)=I_ON;
            
            case '100-60'
                 I_ON_W(2,1)=I_ON;

            case '100-180'
                 I_ON_W(3,1)=I_ON;

            case '200-30'
                 I_ON_W(1,2)=I_ON;
            
            case '200-60'
                 I_ON_W(2,2)=I_ON;

            case '200-180'
                 I_ON_W(3,2)=I_ON;

            case '600-30'
                 I_ON_W(1,3)=I_ON;
            
            case '600-60'
                 I_ON_W(2,3)=I_ON;

            case '600-180'
                 I_ON_W(3,3)=I_ON;
                
        end

    end
end

I_ON_L = transpose(I_ON_W);

hold on
plot(L, I_ON_W, Marker = "*", LineStyle="-", MarkerSize=8);
xlabel("$L[nm]$", Interpreter="latex", FontSize=15)
ylabel("$|I_{ON}|[mA]$", Interpreter="latex", FontSize=15);
legend("$W=" + W + "\mu m$", Interpreter="latex", FontSize=15);
hold off;

figure
hold on
plot(W, I_ON_L, Marker = "*", LineStyle="-", MarkerSize=8);
xlabel("$W [\mu m]$", Interpreter="latex", FontSize=15)
ylabel("$|I_{ON}|[mA]$", Interpreter="latex", FontSize=15);
legend("$L=" + L + "nm$", Interpreter="latex", FontSize=15, Location="southeast");
hold off;




function I_ON = estrai_I_ON(dispositivo)

    cd (string(dispositivo))
    
    % Nomi dei file contenenti il le Id, al variare di Vds, e Vgs
    file = "id-vgs.txt";
    
    if(exist("id_vgs.txt" , "file"))
        file = "id_vgs.txt";
    end

    id_Vgs = readmatrix(file);

    if strcmp(dispositivo(1),'P')
        I_ON = id_Vgs(end , 27); % Id a Vsd = 150 mV e Vsg = 900 mV
    else
        I_ON = id_Vgs(end , 7); % Id a Vds = 150 mV e Vgs = 900 mV
    end
    cd ..;
end



