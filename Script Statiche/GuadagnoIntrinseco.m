%% Descrizione calcoli
% Questo Script serve a calcolare il guadagno intrinseco, ovvero il massimo
% guadagno ottenibile da un MOS, è dato dal rapporto di gm/gds in questo
% sript utilizziamo:
% - la gm a Vds = 0.9V
% - la gds si dovrà calcolare prendendo le I_d a Vds (o Vsd) pari a 0.9 e 
% 0.75 V e poi fare il rapporto delta I_d / 0.15V
%
% In seguito si fa il rapporto delle colonne gm e gds. e per finire i plot
% vengono fatti al variare di Ic0, coefficente di inversione, calcolato
% come: Ic0 = (Id_Vds_0.9 / Iz* ) * (L/W)
% con Iz* = 470nA nei NMOS e 370nA nei PMOS

%% Come Utilizzare lo script
% Posizionarsi nella cartella del dispositivo del quale si vuole fare
% l'analisi, per esempio all'interno della cartella "N4-100-30", dopo ciò
% avviare lo script

%% Codice
% Inizzializzazione
clear
clc
set(0,'DefaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 14)
set(0,'defaulttextInterpreter','latex')
rng('default');


% Definizione costanti
Iz_P = 370e-9; %[A]
Iz_N = 470e-9; %[A]
delta_Vds = 0.15; %[V] 

% Estrazione delle informazioni principali (ad esempio dimensioni e tipologia) 
path = pwd;
pathParts = strsplit(path, filesep);
cartella = pathParts{end};

[~ , W , L , type ] = titoloPlot(cartella); % W e L sono in um

if type ~= "P" && type ~= "N"
    error("Non sono risucito a definire che tipologia è: " + type);
end

% Prelievo gm a 0.9V

if ~exist("gm.txt" , "file")
    error("Il file gm.txt non esiste");
end

temp = readmatrix("gm.txt");

vgs = temp(: , 1); 
gm = temp(: , end); % Sia nei P che nei N la gm a |Vds| massima è nell'ultima colonna 

% Calcoliamo la gds
id_vgs = "id_vgs.txt"; 
if ~exist(id_vgs , "file") % controlliamo se esiste il file
    if exist("id-vgs.txt" , "file")
        id_vgs = "id-vgs.txt";
    else
        error("Il file id_vgs.txt non esiste");
    end
end

[~ , temp , ~] = EstrazioneDati.estrazione_dati_vgs(id_vgs , type);

id_vds_750mV = temp( : , end-1);
id_vds_900mV = temp( : , end);

gds = (id_vds_900mV - id_vds_750mV) / delta_Vds;

% Calcolo coefficente di inversione IC0

if type == "P"
    Iz = Iz_P;
elseif type == "N"
    Iz = Iz_N;
end

ic0 = (id_vds_900mV / Iz) * (L / W);

% Calcolo guadagno intrinseco

g = gm ./ gds; % Divisione elemento per elemento

% Esecuione plot

loglog(ic0 , g);

title("Guadagno intrinseco")
ylabel("guadagno intrinseco")
xlabel("coefficente di inversione")

xlim([1e-2 , 1e2]);
ylim([1e-1  1e3]);

