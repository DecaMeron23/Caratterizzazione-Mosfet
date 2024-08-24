
% Questa funzione esegue i plot di "id / Vgs - Vth" per un dispositivo
% specifico (es: dispositivo = 200-30) e un metodo di estrazione di Vth, valori accettati: ["ELR" "RM" "SDLM" "TCM"] 
function plot_id_tensione_override(dispositivo , metodo)
    
    setUpPlot();
    close all
    ARRAY_METODI = ["ELR" "TCM" "SDLM" "RM"];
    colonnaMetodo = find(ARRAY_METODI==metodo, 1);

   
    if isempty(colonnaMetodo)
        error("Metodo non trovato: %s"  , metodo)
    end

    temp = split(pwd , "\");
    chip = char(temp(end)); 

    FILE_VTH = sprintf("Vth\\Vth_%s-%s.txt" , chip , dispositivo);
    FILE_ID = sprintf("%s-%s\\id-vgs.txt" , chip , dispositivo);
    
    COLORI_PLOT = [
        68/255, 1/255, 84/255;      % Blu scuro
        59/255, 82/255, 139/255;    % Blu violaceo
        33/255, 145/255, 140/255;   % Blu-verde scuro
        94/255, 201/255, 97/255;    % Verde scuro
        170/255, 220/255, 50/255;   % Verde chiaro
        253/255, 231/255, 37/255;   % Giallo-verde chiaro
        254/255, 201/255, 64/255;   % Giallo dorato
        252/255, 141/255, 89/255;   % Arancione
        240/255, 59/255, 32/255;    % Rosso aranciato
    ];
    temp = [ 5 50 100 200 600 1000 3000];
    DISPLAY_NAME = ["Pre" , temp + "Mrad" , "Annealing"];
    VDS_MASSIMA = 900;

    DATI = nan(241 , 2*9);

    figure
    figure
    
    i = 0;

    f = @funzione;
    function funzione()
        
        %indice irraggiamento
        i = i+1;

        %estraiamo la vth secondo il metodo scelto
        temp = readmatrix(FILE_VTH);
         
        VTH = temp(1 , colonnaMetodo)*1e-3; %la mettiamo in V
        
        % estraiamo i valori di Vgs e Id 
        [VGS , ID , VDS] = EstrazioneDati.estrazione_dati_vgs(FILE_ID , chip(1));

        V_OVERRIDE = VGS - VTH;
        ID = ID( : , VDS == VDS_MASSIMA);

        indici = [(i*2)-1 , i*2];
        DATI(: , indici) = [V_OVERRIDE , ID];

        figure(1)
        plot(V_OVERRIDE , ID , "Color", COLORI_PLOT(i , :) , "DisplayName", DISPLAY_NAME(i));
        hold on

        figure(2)
        semilogy(V_OVERRIDE , ID , "Color" ,  COLORI_PLOT(i , :) , "DisplayName", DISPLAY_NAME(i));
        hold on

    end
    estrazioneCartelle.esegui_per_ogni_irraggiamento(f)

    for i = [1 , 2]
        figure(i)
        if i == 1
            legend(Location="northwest" , FontSize=10);
        else
            legend(Location="southeast" , FontSize=10);
        end
        
        [~ ,  W , L  , ~] = titoloPlot(sprintf("%s-%s" , chip , dispositivo)); 

        

        title(sprintf("%sMOS $%.0f-%.3f [\\mu m]$" , chip(1) , W , L) , Interpreter="latex");
        if chip(1) == 'P'
            YLABEL = "$|I_D|$";
            XLABEL = sprintf("$|V_{GS}| - |V_{th , %s}|$" , metodo);
        elseif chip(1) == 'N' 
            YLABEL = "$I_D$";
            XLABEL = sprintf("$V_{GS} - V_{th , %s}$" , metodo);
        end

        ylabel(sprintf("%s $[A]$" , YLABEL) , "Interpreter" , "latex");
        xlabel(sprintf("%s $[V]$" , XLABEL) , "Interpreter" , "latex");

        grid on

    end
    
    tipi_dati = ["V_OV_" , "ID_"];
    irraggiamenti = [0 5 50 100 200 600 1000 3000 3500];
    irraggiamenti = irraggiamenti + "Mrad";
    irraggiamenti(1) = "pre";
    irraggiamenti(end) = "annealing";
    
    VOV = tipi_dati(1) + irraggiamenti; 
    ID = tipi_dati(2) + irraggiamenti;

    NOMI = {}; 

    for i = 2:2:length(irraggiamenti)*2
        NOMI{i-1} = VOV(i/2);
        NOMI{i} = ID(i/2);
    end


    DATI = array2table(DATI , "VariableNames", string(NOMI));

    writetable(DATI , "Id_VOV_.xls")    

end