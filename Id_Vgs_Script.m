clc
clear

id_Vgs_completo = readmatrix("id-vgs.txt"); % Carico il file
colonne_vg_id = [1 , 2:5:36]; 
id_Vgs = id_Vgs_completo(: , colonne_vg_id); % seleziono solo le colonne con vg e id (al variare di Vds)
clear colonne_vg_id id_Vgs_completo;

% Valori di Vds in mV
Vds = 0:150:900;

device_type = "N";

% matrice id_Vgs: prima colonna valori di Vg da colonna 2 a colonna 8
% (totale 7 colonne) valore di id con vd da 0 a 0.9 con step (per colonna)
% di 0.15V

%% Calcoliamo Gm

gm = zeros(size(id_Vgs,1),7);  % crea una matrice di zeri [righe = numero rilevazioni] e 7 colonne
for i=1:7
    gm(:,i) = gradient(id_Vgs(:,i+1) , abs(id_Vgs(1,1) - id_Vgs(2,1))); % i+1 per prendere id
end

figure
plot(id_Vgs(:,1),gm(:,1:7).*1e3)
ylabel('$g_m$ [mS]','interpreter','latex')
xlabel('$V_{gs}$ [V]','interpreter','latex')
title('$g_m$','interpreter','latex')
legend('Vds=0','Vds=150mV','Vds=300mV','Vds=450mV','Vds=600mV','Vds=750mV','Vds=900mV','Location','northwest')

%% Calculate threshold - Ratio Method (RM)

RM_data = abs(id_Vgs(:,2:end)) ./ sqrt(abs(gm(:,:)));

if(device_type=='P')
    RM_data = flipud(RM_data);
end

dati_da_prendere = boolean((id_Vgs(:,1)>=0.6)&(id_Vgs(:,1)<=0.9));

rm_data_fit_y = RM_data(dati_da_prendere, : ); % selezioniamo i Vgs che servono per il fit (#modifica: "2:end" --> ":")
rm_data_fit_x = id_Vgs(dati_da_prendere, 1); % selezioniamo le Vgs >= 0.6

numero_di_vds = length(Vds);

for i=1:numero_di_vds
    RM_fitLineare(i,:) = polyfit(rm_data_fit_x,rm_data_fit_y(:,i),1); % facciamo il fit lineare di grado 1 di rm_data_fit_x e y
end

clear numero_di_vds dati_da_prendere rm_data_fit_y rm_data_fit_x;

%Now matrix P contains the fit of the linear region of the curve; Column 1
%contains the slope, column 2 contains the y-axis intercept

%Solve for y = 0 to find the x-axis intercept
vth_RM = -RM_fitLineare(:,2) ./RM_fitLineare (:,1);

% Plot
figure
plot(id_Vgs(:,1),RM_data(:,1:end))
ylabel('$\frac{I_d}{\sqrt{g_m}}$ [A$\cdot V$]','interpreter','latex')
xlabel('$V_gs$ [V]','interpreter','latex')
title('$\frac{I_d}{\sqrt{g_m}}/V_{gs}$','interpreter','latex')

legend('Vds=0','Vds=150mV','Vds=300mV','Vds=450mV','Vds=600mV','Vds=750mV','Vds=900mV','Location','northwest')

%% Calculate threshold - Transconductance Change Method (TCM)
%Find the maximum point of the gm derivative

% inizializzazione dei dati
TCM_data = zeros(size(gm,1),7);
vth_TCM = zeros(length(Vds) , 1 );

if(device_type=='P')
    gm_copy=flipud(gm);
else
    gm_copy=gm;
end

for i=1:7  % #modifica: per valori grandi di Vds -> tutti i valori di Vds
    TCM_data(:,i) = gradient(gm_copy(:,i))./gradient(id_Vgs(:,1));
end

a = 1;
b = (1/4) * ones(1,4);

TCM_data_smooth = filter(b, a, TCM_data); % Filter -> Smooth delle alte frequenze dei dati grezzi

[ TCM_Max , TCM_Indice]= max(TCM_data_smooth); % "TCM_Max" valore massimo, "TCM_Indice" indice del valore massimo
for i=1:7
    vth_TCM(i, 1)= id_Vgs(TCM_Indice(i), 1); % Vth_TCM è la Vgs corrispondente al massimo della derivata dGm/dVgs
end

clear a b gm_copy;

%% Calculate threshold - Second Difference of the Logarithm of the drain current Minimum (SDLM) method

% inizzializzazione parametri
SDLM_derivata = zeros(length(id_Vgs(: , 1)) , length(Vds));
SDLM_derivata_2 = zeros(length(id_Vgs(: , 1 )) , length(Vds));
vth_SDLM = zeros(length(Vds),1);
SDLM_derivata_2_smooth = zeros(length(id_Vgs(: , 1 )) , length(Vds));

if device_type == 'P'
    for i=1:7
        SDLM_derivata(:, i) = gradient (log(flipud(abs(id_Vgs(:, i+1)))) ./gradient(id_Vgs(:, 1)));
    end
else
    for i=1:7
        SDLM_derivata(:, i) = gradient (log(abs(id_Vgs(:, i+1)))) ./gradient(id_Vgs(:, 1));
    end
end
    
for i=1:7
    SDLM_derivata_2(:, i) = gradient(SDLM_derivata(:, i)) ./gradient(id_Vgs(:, 1));
end

spuriousRemoved=[ones(20,7)*200; SDLM_derivata_2(21:end,:)]; % per bassi valori di Vgs sostituiamo i valori  

for i=1:7
    SDLM_derivata_2_smooth(:, i) = smooth(spuriousRemoved(:,i));
end

[SDLM_Min, SDLM_Indice] = min(SDLM_derivata_2_smooth); % #modifica: SDLM_derivata_2 --> SDLM_derivata_2_smooth

for i=1:7
    vth_SDLM(i, 1) = id_Vgs(SDLM_Indice(i), 1);
end

clear SDLM_derivata i;
