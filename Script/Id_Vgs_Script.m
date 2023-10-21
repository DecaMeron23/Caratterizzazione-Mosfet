clear; clc;

File = "id-vgs.txt"; % nome del file da caricare

% Valori di Vds
if File == "id-vgs-2.txt"
    Vds = 0:0.01:0.1;
else
    if File == "id-vgs.txt"
        Vds = 0:0.15:0.9;
    end
end

fp = dir("*.txt");
NameFolder = fp.folder;
[~ , Dispositivo] = fileparts(NameFolder);

id_Vgs_completo = readmatrix(File); % Carico il file

% file composto da {Vg + (Id , Ig , Is , Iavdd , Igrd) * vd}
NUMERO_COLONNE = length(id_Vgs_completo(1 , :));
colonne_vg_id = 2:5:NUMERO_COLONNE;
Id = id_Vgs_completo(: , colonne_vg_id); % seleziono solo le colonne con Id (al variare di Vds)
Vg = id_Vgs_completo(: , 1); %seleziono le Vg
clear colonne_vg_id id_Vgs_completo;

device_type = Dispositivo(1);

%% Calcoliamo Gm

gm = zeros(length(Vg),7);  % crea una matrice di zeri [righe = numero rilevazioni] e 7 colonne

incremento_Vg = abs(Vg(1) - Vg(2));

for i=1:7
    gm(:,i) = gradient(Id(:,i) , incremento_Vg);
end

figure
plot(Vg , gm .* 1e3)
ylabel('$g_m$ [mS]','interpreter','latex')
xlabel('$V_{gs}$ [V]','interpreter','latex')
title('$g_m$','interpreter','latex')
legend('Vds=0','Vds=150mV','Vds=300mV','Vds=450mV','Vds=600mV','Vds=750mV','Vds=900mV','Location','northwest')

clear incremento_Vg

%% Calculate threshold - Ratio Method (RM)

RM_data = abs(Id) ./ sqrt(abs(gm));
RM_fitLineare = zeros(length(Vds), 2);


if(device_type=='P')
    RM_data = flipud(RM_data);
end

dati_da_prendere = boolean((Vg >=0.6)&(Vg<=0.9));

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
title('$\frac{I_d}{\sqrt{g_m}}/V_{gs}$','interpreter','latex')

legend('Vds=0','Vds=150mV','Vds=300mV','Vds=450mV','Vds=600mV','Vds=750mV','Vds=900mV','Location','northwest')

clear GRADO dati_da_prendere RM_data_fit_y RM_data_fit_x SLOPE INTERCEPT;

%% Calculate threshold - Transconductance Change Method (TCM)
%Find the maximum point of the gm derivative

% inizializzazione dei dati
TCM_data = zeros(length(Id(:, 1)), length(Vds));
vth_TCM = zeros(length(Vds) , 1 );

if(device_type=='P')
    gm_copy=flipud(gm);
else
    gm_copy=gm;
end

for i=1:length(Vds)  % #modifica: per valori grandi di Vds -> tutti i valori di Vds
    TCM_data(:,i) = gradient(gm_copy(:,i))./gradient(Vg(:,1));
end

a = 1;
b = (1/4) * ones(1,4);

TCM_data_smooth = filter(b, a, TCM_data); % Filter -> Smooth delle alte frequenze dei dati grezzi

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

spuriousRemoved=[ones(20,7)*200; SDLM_derivata_2(21:end,:)]; % per bassi valori di Vgs (da -0.3 a -0.2) sostituiamo i valori 

for i=1:length(Vds)
    SDLM_derivata_2_smooth(:, i) = smooth(spuriousRemoved(:,i));
end

[SDLM_Min, SDLM_Indice] = min(SDLM_derivata_2_smooth); % #modifica: SDLM_derivata_2 --> SDLM_derivata_2_smooth

for i=1:length(Vds)
    vth_SDLM(i, 1) = Vg(SDLM_Indice(i));
end

clear SDLM_derivata spuriousRemoved;

%% Save File

Vth =  array2table([ Vds', (round(vth_RM , 6)) , round(vth_TCM, 6) , round(vth_SDLM, 6)]);

Vth = renamevars(Vth , ["Var1", "Var2", "Var3", "Var4"] , ["Vd" , "Vth_RM", "Vth_TCM", "Vth_SDLM"]);

writetable( Vth, NameFolder + "\Vth.txt",  "Delimiter","\t");

clear Vth