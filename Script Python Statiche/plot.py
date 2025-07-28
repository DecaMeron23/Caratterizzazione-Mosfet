import matplotlib as mpl
import matplotlib.pyplot as plt
import funzioni_ausiliarie.estrazione_dati as estrazione_dati
import funzioni_ausiliarie.titolo_plot as titolo_plot
import calcolo_parametri.gm_gds as gm_gds
import os

# --- Funzione per impostare lo stile globale dei plot ---

def setup_plot_style():
    mpl.rcParams.update({
        "figure.figsize": (9, 6),
        "axes.grid": True,
        "grid.linestyle": "--",
        "grid.alpha": 0.5,
        "axes.titlesize": 14,
        "axes.labelsize": 12,
        "xtick.labelsize": 10,
        "ytick.labelsize": 10,
        "legend.fontsize": 12,
        "font.family": "sans-serif",
        "font.sans-serif": ["DejaVu Sans"],
        "lines.linewidth": 2,
        "lines.markersize": 6,
    })

# --- Funzioni di plot

def plot_id_vds(file_id_vds):
    setup_plot_style()
    [id ,vds , vgs] = estrazione_dati.estrazione_dati_id_vds(file_id_vds)
    titolo , _ , _ , canale_dispositivo  = titolo_plot.titolo_plot(os.path.dirname(file_id_vds))
    
    nome_vgs, nome_id, nome_vds = nomi_assi_id_vgs_vds(canale_dispositivo)

    plt.plot(vds, id*1e3, label=[fr"${nome_vgs} = {vgs_i}$ mV" for vgs_i in vgs])
    plt.xlabel(f"${nome_vds}$ [V]")
    plt.ylabel(f"${nome_id}$ [mA]")
    plt.title(titolo)
    plt.legend()
    
    return plt


def plot_id_vgs(file_id_vgs):
    setup_plot_style()
    # Estrazione dati
    [id ,vgs , vds] = estrazione_dati.estrazione_dati_id_vgs(file_id_vgs)

    # Estrazione informazioni
    titolo , _ , _ , canale_dispositivo  = titolo_plot.titolo_plot(os.path.dirname(file_id_vgs))
    
    # Nomi assi
    nome_vgs, nome_id, nome_vds = nomi_assi_id_vgs_vds(canale_dispositivo)

    plt.plot(vgs, id*1e3, label=[fr"${nome_vds} = {vgs_i}$ mV" for vgs_i in vds])
    plt.xlabel(f"${nome_vgs}$ [V]")
    plt.ylabel(f"${nome_id}$ [mA]")
    plt.title(titolo)
    plt.legend()
    
    return plt

def plot_gm_vgs(file_id_vgs):
    setup_plot_style()
    # Estrazione dei valori
    id , vgs , vds = estrazione_dati.estrazione_dati_id_vgs(file_id_vgs)
    gm = gm_gds.gm_gds(id=id , vgs_vds=vgs)

    # Estranzione informazioni
    titolo , _ , _ , canale_dispositivo  = titolo_plot.titolo_plot(os.path.dirname(file_id_vgs))

    nome_vgs, _ , nome_vds = nomi_assi_id_vgs_vds(canale_dispositivo)
    nome_gm = r"g_{m}"
    plt.plot(vgs, gm, label=[fr"${nome_vds} = {vgs_i}$ mV" for vgs_i in vds])
    plt.xlabel(f"${nome_vgs}$ [V]")
    plt.ylabel(rf"${nome_gm}$ [A/V]")
    plt.title(titolo)
    plt.legend()
    return plt
    
def plot_gds_vds(file_id_vds):
    setup_plot_style()
    # Estrazione dei valori
    id , vds , vgs = estrazione_dati.estrazione_dati_id_vds(file_id_vds)
    gds = gm_gds.gm_gds(id=id , vgs_vds=vds)

    # Estranzione informazioni
    titolo , _ , _ , canale_dispositivo  = titolo_plot.titolo_plot(os.path.dirname(file_id_vds))

    nome_vgs, _ , nome_vds = nomi_assi_id_vgs_vds(canale_dispositivo)
    nome_gds = r"g_{DS}"
    plt.plot(vds, gds, label=[fr"${nome_vgs} = {vgs_i}$ mV" for vgs_i in vgs])
    plt.xlabel(f"${nome_vds}$ [V]")
    plt.ylabel(rf"${nome_gds}$ [A/V]")
    plt.title(titolo)
    plt.legend()
    return plt
    
# Funzioni di supporto

def nomi_assi_id_vgs_vds(canale_dispositivo):   
    if(canale_dispositivo == 'P'):
        nome_vgs = r"|V_{GS}|"
        nome_id = r"|I_D|"
        nome_vds = r"|V_{DS}|"
    elif(canale_dispositivo == 'N'):
        nome_vgs = r"V_{GS}"
        nome_id = r"I_D"
        nome_vds = r"V_{DS}"
    return nome_vgs,nome_id,nome_vds


plot = plot_gds_vds("/home/emilio/Documenti/github/Caratterizzazione-Mosfet/Misure statiche/N6/Chip6NMOS/N6-200-180/id-vds.txt")
plot.show()
