% Calcolo Delle Vth con i metodo RM , TCM e SDLM

%% inizializzazione
clear; clc;

fp = dir();
fileInFolder = {fp.name};
if length(fileInFolder) <= 2
    error("Cartella vuota...")
end



NameFolder = fp.folder;
[~ , Dispositivo] = fileparts(NameFolder);


%nome del dispositivo
device_type = Dispositivo(1);

File1 = "id-vgs.txt";
File2 = "id-vgs-2.txt";

if ~exist(File1) && ~exist(File2)
    error(File1  + " e " + File2 + " non esiste")
end

% Carico i file
id_Vgs_completo_1 = readmatrix(File1); 
id_Vgs_completo_2 = readmatrix(File2);    
% file composto da {Vg + (Id , Ig , Is , Iavdd , Igrd) * vd}
% numero di colonne totali
NUMERO_COLONNE_1 = length(id_Vgs_completo_1(1, :));
NUMERO_COLONNE_2 = length(id_Vgs_completo_2(1, :));
%seleziono gli indici di colonna contenenti Id (nel primo file non prendo
%vd = 0)
colonne_vg_id_1 = 7:5:NUMERO_COLONNE_1;
colonne_vg_id_2 = 7:5:NUMERO_COLONNE_2;
% estraggo le colonne con Id
Id_1 = id_Vgs_completo_1(: , colonne_vg_id_1);
Id_2 = id_Vgs_completo_2(: , colonne_vg_id_2);
% estraggo le Vg (sono uguali per entrambi i file)
Vg = id_Vgs_completo_1(: , 1);
%faccio il merge dei file
Id = [Id_2 , Id_1];

% Valori di Vds in mV
Vds = [10:10:100, 150:150:900];

% pulisco il Workspace
clear Id_1 Id_2 NUMERO_COLONNE_1 NUMERO_COLONNE_2 id_Vgs_completo_1 id_Vgs_completo_2 File1 File2 fp fileInFolder;



%% Calcoliamo Gm

gm1 = zeros(size(Id));
gm2 = gm1;

for i=1:length(Vds)
    gm1(:,i) = gradient(Id(:,i))./gradient(Vg);
end

gm2(1,:) = gm1(1,:);

for i=1:length(Vds)
    gm2(2:end,i) = gradient(Id(1:end-1,i))./gradient(Vg(2:end));
end

gm = (gm1+gm2)/2;

for i=1:length(Vds)
    gm(:,i) = smooth(gm(:,i));
end

figure
plot(Vg , gm .* 1e3)

% nome assi
ylabel('$g_m$ [mS]','interpreter','latex')
xlabel('$V_{gs}$ [V]','interpreter','latex')

% titolo del plot
title(device_type + " - $g_m$",'interpreter','latex')

% creo la legenda
for i = 1: length(Vds)
    legend_text(i) = "Vds = " + (Vds(i))+ " mV"; 
end

if device_type == "N"
    legend(legend_text,'Location','northwest')
else
    if device_type == "P"
    legend(legend_text,'Location','southeast') 
    end
end

clear incremento_Vg legend_text

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
TCM_data = zeros(length(Id(:, 1)), length(Vds));
Vth_data_TCM = zeros(length(Vds) , 1 );

% se il dispositivo è un p specchiamo verticalmente la gm 
if(device_type=='P')
    gm = flipud(gm); % giusto fare flipud della gm? perchè poi noi andiamo a cercare il massimo 
end

for i=1:length(Vds)
    TCM_data(:,i) = gradient(gm(:,i))./gradient(Vg);
end

% Smooth della derivata
for i=1:length(Vds)
    TCM_data(: , i) = smooth(TCM_data(: , i));
end

[TCM_Max, TCM_Indice] = max(TCM_data(1:201,:)); % valore e indice massimo di di TCM per Vgs<=700mV

for i=1:length(Vds)
    Vth_data_TCM(i, 1) = Vg(TCM_Indice(i));
end

%Calcolo del massimo della funzione polinomiale che interpola i punti 
% in un intorno di Vth calcolata con TCM a Vgs = 10 mV e di raggio 100 mV
grado = 6; % grado della polinomiale
coefficienti = zeros(length(Vds), grado+1);
for i = 1:length(Vds)
    indici_intervallo = TCM_Indice(i)-20 : TCM_Indice(i)+20;
    intervallo_alta_ris = Vg(indici_intervallo(1)):0.0001:Vg(indici_intervallo(end));
    coefficienti(i,:) = polyfit(Vg(indici_intervallo), TCM_data(indici_intervallo,i), grado);
    grafico(:,i) = polyval(coefficienti(i,:), intervallo_alta_ris);
    % se Vds = 10mv (i == 1) teniamo gli intervalli per fare il grafico
    % dopo il for
    if(i == 1)
        intervallo_vds_10mv = indici_intervallo;
        intervallo_vds_10mv_alta_ris = intervallo_alta_ris;
    end
end
[max_grafico, ind_grafico] = max(grafico); %massimo della polinomiale

for i=1:length(Vds)
    Vth_TCM(i) = intervallo_vds_10mv_alta_ris(ind_grafico(i));
end

figure
hold on
title("TCM")
plot(Vg(intervallo_vds_10mv),TCM_data(intervallo_vds_10mv,1)); %grafico dati
xline(Vth_data_TCM(1),"--","Color","r");  %Vth dati
plot(intervallo_vds_10mv_alta_ris,grafico(:, 1)); %grafico polinomiale
plot(Vth_TCM(1) , max_grafico(1) , "o") %minimo della polinomiale (Vth)
legend("SDLM","Massimo di TCM","Fit di grado "+grado, "Massimo del fit")

clear a b gm indici_intervallo;

%% Calculate threshold - Second Difference of the Logarithm of the drain current Minimum (SDLM) method

% inizzializzazione parametri
% vth_SDLM = zeros(length(Vds),1);
% log_Id_smooth = zeros(size(Id));
% SDLM_derivata_Smooth = log_Id_smooth;
% SDLM_derivata_2_smooth = log_Id_smooth;

% se il dispositivo è un p specchiamo verticalmente il log(Id) 
if device_type == 'P'
    log_Id = log(flipud(abs(Id)));
else
    log_Id = log(abs(Id));
end

%Eseguiamo lo smooth
for i=1:length(Vds)
    log_Id_smooth(: , i) = smooth(log_Id(: , i));
end

%Deriviamo rispetto Vgs
for i = 1:length(Vds) 
    SDLM_derivata(: , i) = gradient(log_Id_smooth(: , i)) ./ gradient(Vg);
end

%Eseguiamo lo smooth della derivata
for i=1:length(Vds)
    SDLM_derivata(: , i) = smooth(SDLM_derivata(: , i));
end

%Deriviamo la seconda volta
for i= 1:length(Vds)
    SDLM_derivata_2(: , i) = gradient(SDLM_derivata(:,i)) ./ gradient(Vg);
end

% per bassi valori di Vgs (da -0.3 a -0.2) sostituiamo i valori 
spuriousRemoved = [ones(20,length(Vds))*200; SDLM_derivata_2(21:end,:)]; 

%Smooth della derivata seconda
for i=1:length(Vds)
    SDLM_derivata_2(:, i) = smooth(spuriousRemoved(:,i));
end

[SDLM_Min, SDLM_Indice] = min(SDLM_derivata_2); % #modifica: SDLM_derivata_2 --> SDLM_derivata_2_smooth

for i=1:length(Vds)
    Vth_data_SDLM(i, 1) = Vg(SDLM_Indice(i));
end

%Calcolo del minimo della funzione polinomiale che interpola i punti 
% in un intorno di Vth calcolata con SDLM a Vgs = 900 mV e di raggio 100 mV
grado = 6; % grado della polinomiale
coefficienti = zeros(length(Vds), grado+1);
for i = 1:length(Vds)
    indici_intervallo = SDLM_Indice(i)-20 : SDLM_Indice(i)+20;
    intervallo_alta_ris = Vg(indici_intervallo(1)):0.0001:Vg(indici_intervallo(end));
    coefficienti(i,:) = polyfit(Vg(indici_intervallo), SDLM_derivata_2(indici_intervallo,i), grado);
    grafico(:,i) = polyval(coefficienti(i,:), intervallo_alta_ris);
end
[min_grafico, ind_grafico] = min(grafico); %minimo della polinomiale

for i=1:length(Vds)
    Vth_SDLM(i) = intervallo_alta_ris(ind_grafico(i));
end

figure
hold on
title("SDLM")
plot(Vg(indici_intervallo),SDLM_derivata_2(indici_intervallo,end)) %grafico dati
xline(Vth_data_SDLM(end),"--","Color","r"); %Vth dati
plot(intervallo_alta_ris, grafico(:, end)); %grafico polinomiale
plot(Vth_SDLM(end) , min_grafico(end) , "o") %minimo della polinomiale (Vth)
legend( "SDLM", "Minimo di SDLM", "Fit di grado "+grado, "Minimo del fit");
clear spuriousRemoved;

%% Save File
% verticalizzo Vds
Vds_verticale = Vds';
%creo una matrice contenente le Vth calcolate
Vth =  array2table([Vds_verticale , round(Vth_TCM' , 6) , round(Vth_SDLM' , 6)]);
%Rinonimo le intestazioni
Vth = renamevars(Vth , ["Var1", "Var2", "Var3"] , ["Vd" , "Vth_TCM", "Vth_SDLM"]);

% cd ..
% 
%  if ~exist("~\Vth")
%     mkdir("Vth");
%  end
%  cd Vth;

%Salvo File nella cartella
writetable( Vth, "Vth_"+ Dispositivo + ".txt",  "Delimiter", "\t");

% ci muoviamo nella prossima cartella da analizzare