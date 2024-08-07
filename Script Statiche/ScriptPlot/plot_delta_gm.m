function plot_delta_gm(vds , tipologia , dispositivo , varargin) % vds = 0.45 , tipologia = "P" , dispositivo = "200-30"
    % posizionarsi nella cartella contenente i file delta_gm
    % Plot variazioni 
    grado = [0 5 50 100 200 600 1000 3000 3500];
    valori_vds = 0.15:0.15:0.9;
    file = "Delta_gm_" + dispositivo + ".xls";
    delta = readmatrix(file);
    delta = delta(:, 2:end);
    indice_vds = (valori_vds == vds);
    delta = delta(indice_vds , :);

    %figure;
    elementi = split(dispositivo , "-");
    W = elementi(1);   
    L= str2double(elementi(2)) / 1000;
    L = sprintf('%.3f', L);
    dim_dispositivo = "$" + W +"-"+ L + "$";
    titolo = tipologia+"MOS" + dim_dispositivo;
    plot(grado , delta , Marker="diamond" , LineWidth=1 , DisplayName=dim_dispositivo);    
    ytickformat('percentage');
    title(titolo, Interpreter="latex" , FontSize=12);
    ylabel("$ \% \Delta g_m$" , Interpreter="latex" , FontSize=12);
    xlabel("Dose Assorbita $[Mrad]$" , Interpreter="latex" , FontSize=12);
    % Impostazione degli xtick
    xticks(0:500:3500);
    % Impostazione delle etichette degli xtick
    xticklabels({"0" , "500", "1000" , "1500" , "2000" , "2500" , "3000" , "annealing"});
    
    if  nargin > 3
        if varargin{1}
            yline(0 , "--");
        end
    end
    grid on
end