% Calcolo Delle Vth con i metodo RM , TCM e SDLM

%% inizializzazione
clear; clc;

% trovo la directory in cui ci troviamo
fp = dir();
% Lista dei file nella cartella
fileInFolder = {fp.name};
% verifichiamo se ci sono dei file nella cartella ( . e .. esclusi)
if length(fileInFolder) <= 2
    error("Cartella vuota...")
end

% prendo il nome completo della cartella (es: "C:\Dispositivi\N1_100-30")
nameFolder = fp.folder;
% prendo solo il nome della cartella (es: "N1_100-30")
[~ , dispositivo] = fileparts(nameFolder);


% Tipo del dispositivo
device_type = dispositivo(1);

% Nomi dei file contenenti il le Id, al variare di Vds, e Vgs
file1 = "id-vgs.txt";
file2 = "id-vgs-2.txt";

% Carico i file
id_Vgs_completo_1 = readmatrix(file1); 
id_Vgs_completo_2 = readmatrix(file2);    
% file composto da {Vg + (Id , Ig , Is , Iavdd , Igrd) * vd}
% numero di colonne totali
NUM_COLONNE_TOT_1 = length(id_Vgs_completo_1(1, :));
NUM_COLONNE_TOT_2 = length(id_Vgs_completo_2(1, :));
%seleziono gli indici di colonna contenenti Id (non prendiamo le Vd = 0)
colonne_vg_id_1 = 7:5:NUM_COLONNE_TOT_1;
colonne_vg_id_2 = 7:5:NUM_COLONNE_TOT_2;
% estraggo le colonne con Id
id_1 = id_Vgs_completo_1(: , colonne_vg_id_1);
id_2 = id_Vgs_completo_2(: , colonne_vg_id_2);
% estraggo le Vg (sono uguali per entrambi i file)
vg = id_Vgs_completo_1(: , 1);
%se il dispositivo è un P abbiamo che Vs = 0.9 v e Vg varia da 1.2V a 0V
if device_type == 'P'
    vg = 0.9 - vg;
end

%faccio il merge dei file
id = [id_2 , id_1];

% if device_type == "P"
%     id = fliplr(id);
% end

% Valori di Vds in mV
vds = [10:10:100, 150:150:900];

% pulisco il Workspace
clear id_1 id_2 NUM_COLONNE_TOT_1 NUM_COLONNE_TOT_2 id_Vgs_completo_1 id_Vgs_completo_2 file1 file2 fp fileInFolder colonne_vg_id_2 colonne_vg_id_1;

%% Calcoliamo Gm

gm1 = zeros(size(id));
gm2 = gm1;

for i=1:length(vds)
    gm1(:,i) = gradient(id(:,i))./gradient(vg);
end

gm2(1,:) = gm1(1,:);

for i=1:length(vds)
    gm2(2:end,i) = gradient(id(1:end-1,i))./gradient(vg(2:end));
end

gm = (gm1+gm2)/2;

for i=1:length(vds)
    gm(:,i) = smooth(gm(:,i));
end

figure
plot(vg , gm .* 1e3)

% nome assi
ylabel('$g_m$ [mS]','interpreter','latex')
xlabel('$V_{gs}$ [V]','interpreter','latex')

% titolo del plot
title(device_type + " - $g_m$",'interpreter','latex')

% creo la legenda
for i = 1: length(vds)
    legend_text(i) = "Vds = " + (vds(i))+ " mV"; 
end

if device_type == "N"
    legend(legend_text,'Location','northwest')
else
    if device_type == "P"
    legend(legend_text,'Location','southwest') 
    end
end

clear incremento_Vg legend_text gm1 gm2

% %% Calculate threshold - Ratio Method (RM)
% 
% RM_data = abs(Id) ./ sqrt(abs(gm));
% RM_fitLineare = zeros(length(Vds), 2);
% 
% if device_type == "P"
%     RM_data = flipud(RM_data); % è giusto far il flipud dei dati? le Vth
%     % si sballano tutti
%     puntiFit = [1 1.2];
%     % puntiFit = [0 0.3];
% else
%     if device_type == "N"
%         puntiFit = [0.6 0.9];
%     end
% end
% dati_da_prendere = (Vg >= puntiFit(1) ) & (Vg <= puntiFit(2));
% RM_data_fit_y = RM_data(dati_da_prendere, : ); % selezioniamo i Vgs che servono per il fit (#modifica: "2:end" --> ":")
% RM_data_fit_x = Vg(dati_da_prendere); % selezioniamo le Vgs >= 0.6 e <= 0.9
% 
% % definizione gado del polnomio del fit
% GRADO = 1;
% 
% for i=1:length(Vds)
%     RM_fitLineare(i,:) = polyfit(RM_data_fit_x, RM_data_fit_y(:,i), GRADO); % facciamo il fit lineare di grado 1 di rm_data_fit_x e y
% end
% 
% %Now matrix P contains the fit of the linear region of the curve; Column 1
% %contains the slope, column 2 contains the y-axis intercept
% % Dichiarazione Costanti
% SLOPE = 1;
% INTERCEPT = 2;
% 
% %Solve for y = 0 to find the x-axis intercept
% vth_RM = -RM_fitLineare(:,INTERCEPT) ./ RM_fitLineare (:,SLOPE);
% 
% % Plot
% figure
% plot(Vg, RM_data);
% ylabel('$\frac{I_d}{\sqrt{g_m}}$ [A$\cdot V$]','interpreter','latex')
% xlabel('$V_{gs}$ [V]','interpreter','latex')
% title(device_type + " - $\frac{I_d}{\sqrt{g_m}}/V_{gs}$",'interpreter','latex')
% 
% % creo la legenda
% 
% for i = 1: length(Vds)
%     legend_text(i) = "Vds = " + (Vds(i))+ " mV"; 
% end
% 
% legend(legend_text,'Location','northwest')
% 
% clear legend_text GRADO dati_da_prendere RM_data_fit_y RM_data_fit_x SLOPE INTERCEPT;

%% Calculate threshold - Transconductance Change Method (TCM)
%Find the maximum point of the gm derivative
%valido per basse Vds

% inizializzazione dei dati
TCM_data = zeros(length(id(:, 1)), length(vds));

% se il dispositivo è un p specchiamo verticalmente la gm 
if(device_type=='P')
    gm = flipud(gm);
end

for i=1:length(vds)
    TCM_data(:,i) = gradient(gm(:,i))./gradient(vg);
end

% Smooth della derivata
for i=1:length(vds)
    TCM_data(: , i) = smooth(TCM_data(: , i));
end

[TCM_Max, TCM_Indice] = max(TCM_data(1:201,:)); % valore e indice massimo di di TCM per Vgs<=700mV

for i=1:length(vds)
    vth_TCM_noFit(i, 1) = vg(TCM_Indice(i));
end

%Calcolo del massimo della funzione polinomiale che interpola i punti 
% in un intorno di Vth calcolata con TCM a Vgs = 10 mV e di raggio 100 mV
grado = 6; % grado della polinomiale
coefficienti = zeros(length(vds), grado+1);
for i = 1:length(vds)
    indici_intervallo = TCM_Indice(i)-20 : TCM_Indice(i)+20;
    intervallo_alta_ris = vg(indici_intervallo(1)) : 0.0001 : vg(indici_intervallo(end));
    coefficienti(i,:) = polyfit(vg(indici_intervallo), TCM_data(indici_intervallo,i), grado);
    grafico(:,i) = polyval(coefficienti(i,:), intervallo_alta_ris);
    % se Vds = 10mv (i == 1) teniamo gli intervalli per fare il grafico
    % dopo il for
    if(i == 1)
        intervallo_vds_10mv = indici_intervallo;
        intervallo_vds_10mv_alta_ris = intervallo_alta_ris;
    end
end
%massimo della polinomiale
[max_grafico, ind_grafico] = max(grafico); 

for i=1:length(vds)
    vth_TCM(i) = intervallo_vds_10mv_alta_ris(ind_grafico(i));
end

figure
hold on
title("TCM")
plot(vg(intervallo_vds_10mv),TCM_data(intervallo_vds_10mv,1)); %grafico dati
xline(vth_TCM_noFit(1),"--","Color","red");  %Vth dati
xlabel("$V_{gs}$" , "Interpreter","latex");
ylabel("$\frac{\mathrm {d} g_m}{\mathrm {d} V_{gs}}$" , Interpreter="latex");
plot(intervallo_vds_10mv_alta_ris,grafico(:, 1)); %grafico polinomiale
plot(vth_TCM(1) , max_grafico(1) , "o") %minimo della polinomiale (Vth)
legend("TCM","Massimo di TCM","Fit di grado "+ grado, "Massimo del fit")

clear a b indici_intervallo;

%% Calculate threshold - Second Difference of the Logarithm of the drain current Minimum (SDLM) method

% inizzializzazione parametri
% vth_SDLM = zeros(length(Vds),1);
% log_Id_smooth = zeros(size(Id));
% SDLM_derivata_Smooth = log_Id_smooth;
% SDLM_derivata_2_smooth = log_Id_smooth;

% se il dispositivo è un p specchiamo verticalmente il log(Id) 
if device_type == 'P'
    log_Id = log(flipud(abs(id)));
else
    log_Id = log(abs(id));
end

%Eseguiamo lo smooth
for i=1:length(vds)
    log_Id_smooth(: , i) = smooth(log_Id(: , i));
end

%Deriviamo rispetto Vgs
for i = 1:length(vds) 
    SDLM_derivata(: , i) = gradient(log_Id_smooth(: , i)) ./ gradient(vg);
end

%Eseguiamo lo smooth della derivata
for i=1:length(vds)
    SDLM_derivata(: , i) = smooth(SDLM_derivata(: , i));
end

%Deriviamo la seconda volta
for i= 1:length(vds)
    SDLM_derivata_2(: , i) = gradient(SDLM_derivata(:,i)) ./ gradient(vg);
end

% per bassi valori di Vgs (da -0.3 a -0.2) sostituiamo i valori 
spuriousRemoved = [ones(20,length(vds))*200; SDLM_derivata_2(21:end,:)]; 

%Smooth della derivata seconda
for i=1:length(vds)
    SDLM_derivata_2(:, i) = smooth(spuriousRemoved(:,i));
end

[SDLM_Min, SDLM_Indice] = min(SDLM_derivata_2(1:201,:)); % valore e indice minimo di di SDLM per Vgs<=700mV

for i=1:length(vds)
    vth_SDLM_noFit(i, 1) = vg(SDLM_Indice(i));
end

%Calcolo del minimo della funzione polinomiale che interpola i punti 
% in un intorno di Vth calcolata con SDLM a Vgs = 900 mV e di raggio 100 mV
grado = 6; % grado della polinomiale
coefficienti = zeros(length(vds), grado+1);
for i = 1:length(vds)
    indici_intervallo = SDLM_Indice(i)-20 : SDLM_Indice(i)+20;
    intervallo_alta_ris = vg(indici_intervallo(1)) : 0.0001 : vg(indici_intervallo(end));
    coefficienti(i,:) = polyfit(vg(indici_intervallo), SDLM_derivata_2(indici_intervallo,i), grado);
    grafico(:,i) = polyval(coefficienti(i,:), intervallo_alta_ris);
    % se Vds = 900mv (i == length(Vds)) teniamo gli intervalli per fare il grafico  
    % dopo il for
    if(i == length(vds))
        indici_intervallo_vds_900mv = indici_intervallo;
        intervallo_vds_900mv_alta_ris = intervallo_alta_ris;
    end
end
[min_grafico, ind_grafico] = min(grafico); %minimo della polinomiale

for i=1:length(vds)
    vth_SDLM(i) = intervallo_vds_900mv_alta_ris(ind_grafico(i));
end

figure
hold on
title("SDLM")
xlabel("$V_{gs}$" , "Interpreter","latex");
ylabel("$\frac{\mathrm {d}^2 \log{I_d}}{\mathrm {d} V_{gs}^2}$" , Interpreter="latex");
plot(vg(indici_intervallo_vds_900mv),SDLM_derivata_2(indici_intervallo_vds_900mv,end)) %grafico dati
xline(vth_SDLM_noFit(end),"--","Color","r"); %Vth dati
plot(intervallo_vds_900mv_alta_ris, grafico(:, end)); %grafico polinomiale
plot(vth_SDLM(end) , min_grafico(end) , "o") %minimo della polinomiale (Vth)
legend( "SDLM", "Minimo di SDLM", "Fit di grado "+ grado, "Minimo del fit");
clear spuriousRemoved;

%% Save File
% verticalizzo Vds
vds_verticale = vds';
%creo una matrice contenente le Vth calcolate
vth =  array2table([vds_verticale , round(vth_TCM' , 6) , round(vth_SDLM' , 6)]);
%Rinonimo le intestazioni
vth = renamevars(vth , ["Var1", "Var2", "Var3"] , ["Vd" , "Vth_TCM", "Vth_SDLM"]);

Cartella = "Vth";

cd ..

 % if ~exist(("~\" + Cartella))
    mkdir(Cartella);
 % end
 cd(Cartella);
 

%Salvo File nella cartella
writetable( vth, "Vth_"+ dispositivo + ".txt",  "Delimiter", "\t");

cd ..;
% ci muoviamo nella prossima cartella da analizzare