% Calcolo Delle Vth con i metodo RM , TCM e SDLM

%% inizializzazine
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
colonne_vg_id_2 = 2:5:NUMERO_COLONNE_2;
% estraggo le colonne con Id
Id_1 = id_Vgs_completo_1(: , colonne_vg_id_1);
Id_2 = id_Vgs_completo_2(: , colonne_vg_id_2);
% estraggo le Vg (sono uguali per entrambi i file)
Vg = id_Vgs_completo_1(: , 1);
%faccio il merge dei file
Id = [Id_2 , Id_1];

% Valori di Vds in mV
Vds = [0:10:100, 150:150:900];

% pulisco il Workspace
clear Id_1 Id_2 NUMERO_COLONNE_1 NUMERO_COLONNE_2 id_Vgs_completo_1 id_Vgs_completo_2 File1 File2 fp fileInFolder;



%% Calcoliamo Gm

gm = zeros(length(Vg),length(Vds));  % crea una matrice di zeri [righe = numero rilevazioni] e 7 colonne

incremento_Vg = abs(Vg(1) - Vg(2));

for i=1:length(Vds)
    gm(:,i) = gradient(Id(:,i) , incremento_Vg);
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

%% Calculate threshold - Ratio Method (RM)

RM_data = abs(Id) ./ sqrt(abs(gm));
RM_fitLineare = zeros(length(Vds), 2);

if device_type == "P"
    RM_data = flipud(RM_data); % è giusto far il flipud dei dati? le Vth
    % si sballano tutti
    puntiFit = [1 1.2];
    % puntiFit = [0 0.3];
else
    if device_type == "N"
        puntiFit = [0.6 0.9];
    end
end
dati_da_prendere = boolean((Vg >= puntiFit(1) ) & (Vg <= puntiFit(2)));
RM_data_fit_y = RM_data(dati_da_prendere, : ); % selezioniamo i Vgs che servono per il fit (#modifica: "2:end" --> ":")
RM_data_fit_x = Vg(dati_da_prendere); % selezioniamo le Vgs >= 0.6 e <= 0.9

% definizione gado del polnomio del fit
GRADO = 1;

for i=1:length(Vds)
    RM_fitLineare(i,:) = polyfit(RM_data_fit_x, RM_data_fit_y(:,i), GRADO); % facciamo il fit lineare di grado 1 di rm_data_fit_x e y
end

%Now matrix P contains the fit of the linear region of the curve; Column 1
%contains the slope, column 2 contains the y-axis intercept
% Dichiarazione Costanti
SLOPE = 1;
INTERCEPT = 2;

%Solve for y = 0 to find the x-axis intercept
vth_RM = -RM_fitLineare(:,INTERCEPT) ./ RM_fitLineare (:,SLOPE);

% Plot
figure
plot(Vg, RM_data);
ylabel('$\frac{I_d}{\sqrt{g_m}}$ [A$\cdot V$]','interpreter','latex')
xlabel('$V_{gs}$ [V]','interpreter','latex')
title(device_type + " - $\frac{I_d}{\sqrt{g_m}}/V_{gs}$",'interpreter','latex')

% creo la legenda

for i = 1: length(Vds)
    legend_text(i) = "Vds = " + (Vds(i))+ " mV"; 
end

legend(legend_text,'Location','northwest')

clear legend_text GRADO dati_da_prendere RM_data_fit_y RM_data_fit_x SLOPE INTERCEPT;

%% Calculate threshold - Transconductance Change Method (TCM)
%Find the maximum point of the gm derivative
%valido per basse Vds

% inizializzazione dei dati
TCM_data = zeros(length(Id(:, 1)), length(Vds));
vth_TCM = zeros(length(Vds) , 1 );

if(device_type=='P')
    % gm_copy=flipud(gm); %giusto fare flipud della gm? perchè poi noi andiamo a cercare il massimo 
    gm_copy=gm;
else
    gm_copy=gm;
end

for i=1:length(Vds)  % #modifica: per valori grandi di Vds -> tutti i valori di Vds
    TCM_data(:,i) = gradient(gm_copy(:,i))./gradient(Vg(:,1));
end

a = 1;
b = (1/4) * ones(1,4);

% TCM_data_smooth = filter(b, a, TCM_data); % Filter -> Smooth delle alte frequenze dei dati grezzi

for i=1:length(Vds)

TCM_data_smooth(: , i) = smooth(TCM_data(: , i));
end
[ TCM_Max , TCM_Indice] = max(TCM_data_smooth); % "TCM_Max" valore massimo, "TCM_Indice" indice del valore massimo
for i=1:length(Vds)
    vth_TCM(i, 1)= Vg(TCM_Indice(i)); % Vth_TCM è la Vgs corrispondente al massimo della derivata dGm/dVgs
end

clear a b gm_copy;

%% Calculate threshold - Second Difference of the Logarithm of the drain current Minimum (SDLM) method

% inizzializzazione parametri
SDLM_derivata = zeros(length(Vg(: , 1)) , length(Vds));
SDLM_derivata_2 = zeros(length(Vg(: , 1 )) , length(Vds));
vth_SDLM = zeros(length(Vds),1);
SDLM_derivata_2_smooth = zeros(length(Vg(: , 1 )) , length(Vds));

if device_type == 'P'
    for i=1:length(Vds)
        SDLM_derivata(:, i) = gradient(log(flipud(abs(Id(:, i))))) ./ gradient((Vg)); 
    end
else
    for i=1:length(Vds)
        SDLM_derivata(:, i) = gradient(log(abs(Id(:, i)))) ./gradient(Vg);
    end
end
    
for i=1:length(Vds)
    SDLM_derivata_2(:, i) = gradient(SDLM_derivata(:, i)) ./gradient(Vg(:, 1));
end

spuriousRemoved=[ones(20,length(Vds))*200; SDLM_derivata_2(21:end,:)]; % per bassi valori di Vgs (da -0.3 a -0.2) sostituiamo i valori 

for i=1:length(Vds)
    SDLM_derivata_2_smooth(:, i) = smooth(spuriousRemoved(:,i));
end

[SDLM_Min, SDLM_Indice] = min(SDLM_derivata_2_smooth); % #modifica: SDLM_derivata_2 --> SDLM_derivata_2_smooth

for i=1:length(Vds)
    vth_SDLM(i, 1) = Vg(SDLM_Indice(i));
end

clear spuriousRemoved;

%% Save File
% verticalizzo Vds
Vds_verticale = Vds';
%creo una matrice contenente le Vth calcolate
Vth =  array2table([Vds_verticale(2:end) , round(vth_RM(2:end) , 6) , round(vth_TCM(2:end), 6) , round(vth_SDLM(2:end), 6)]);
%Rinonimo le intestazioni
Vth = renamevars(Vth , ["Var1", "Var2", "Var3", "Var4"] , ["Vd" , "Vth_RM", "Vth_TCM", "Vth_SDLM"]);
%Salvo File nella cartella
writetable( Vth, "Vth.txt",  "Delimiter", "\t");
