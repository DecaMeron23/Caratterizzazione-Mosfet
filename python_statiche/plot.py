'''
In questo file vengono messe tutte le funzioni che eseguono i plot
'''

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import funzioni_ausiliarie.estrazione_dati as estrazione_dati
import os

from funzioni_ausiliarie.titolo_plot import titolo_plot
from funzioni_ausiliarie.ricerca_file import get_cartelle
from calcolo_parametri.gm_gds import gm_gds
from pathlib import Path
from scipy.ndimage import uniform_filter1d

# --- Funzione per impostare lo stile globale dei plot ---

def _setup_plot_style():
    mpl.rcParams.update({
        "figure.figsize": (9, 6),
        "figure.max_open_warning": 50, 
        "axes.grid": True,
        "grid.linestyle": "--",
        "grid.alpha": 0.5,
        "axes.titlesize": 16,
        "axes.labelsize": 14,
        "xtick.labelsize": 12,
        "ytick.labelsize": 12,
        "legend.fontsize": 13,
        "font.family": "sans-serif",
        "font.sans-serif": ["DejaVu Sans"],
        "lines.linewidth": 2,
        "lines.markersize": 6,
    })
    import shutil
    if shutil.which("pdflatex") is not None:
        mpl.rcParams["text.usetex"] = True

# --- Funzioni di plot

def plot_id_vds(path_dispositivo):
    _setup_plot_style()

    [id ,vds , vgs] = estrazione_dati.estrazione_dati_id_vds(path_dispositivo)
    titolo , _ , _ , canale_dispositivo  = titolo_plot(path_dispositivo)
    
    nome_vgs, nome_id, nome_vds = _nomi_assi_id_vgs_vds(canale_dispositivo)
    plt.figure(f"{titolo} - id-vds")
    plt.plot(vds, id*1e3, label=[fr"${nome_vgs} = {vgs_i}$ mV" for vgs_i in vgs])
    plt.xlabel(f"${nome_vds}$ [V]")
    plt.ylabel(f"${nome_id}$ [mA]")
    plt.title(titolo)
    plt.legend()
    
    return plt.gcf()


def plot_id_vgs(path_dispositivo , secondo_file = False , semilog = False):
    _setup_plot_style()
    # Estrazione dati

    
    [id ,vgs , vds] = estrazione_dati.estrazione_dati_id_vgs(path_dispositivo , secondo_file = secondo_file)

    # Estrazione informazioni
    titolo , _ , _ , canale_dispositivo  = titolo_plot(path_dispositivo)
    
    # Nomi assi
    nome_vgs, nome_id, nome_vds = _nomi_assi_id_vgs_vds(canale_dispositivo)
    plt.figure(f"{titolo}{" - semilog" if semilog else ""} - id-vgs{"-2" if secondo_file else ""}")
    if semilog:
        plt.semilogy(vgs, id*1e3, label=[fr"${nome_vds} = {vgs_i}$ mV" for vgs_i in vds])
        plt.grid(which="minor")
    else:
        plt.plot(vgs, id*1e3, label=[fr"${nome_vds} = {vgs_i}$ mV" for vgs_i in vds])
    plt.xlabel(f"${nome_vgs}$ [V]")
    plt.ylabel(f"${nome_id}$ [mA]")
    plt.title(titolo)
    plt.legend()
    return plt.gcf()

def plot_gm_vgs(path_dispositivo , secondo_file = False):
    _setup_plot_style()
    # Estrazione dei valori
    id , vgs , vds = estrazione_dati.estrazione_dati_id_vgs(path_dispositivo , secondo_file = secondo_file)
    gm = gm_gds(id=id , vgs_vds=vgs)

    # Estranzione informazioni
    titolo , _ , _ , canale_dispositivo  = titolo_plot(path_dispositivo)

    nome_vgs, _ , nome_vds = _nomi_assi_id_vgs_vds(canale_dispositivo)
    nome_gm = r"g_{m}"
    plt.figure(f"{titolo} - gm-vgs{"-2" if secondo_file else ""}")
    plt.plot(vgs, gm, label=[fr"${nome_vds} = {vgs_i}$ mV" for vgs_i in vds])
    plt.xlabel(f"${nome_vgs}$ [V]")
    plt.ylabel(rf"${nome_gm}$ [A/V]")
    plt.title(titolo)
    plt.legend()
    return plt.gcf()
    
def plot_gds_vds(path_dispositivo):
    _setup_plot_style()
    # Estrazione dei valori
    id , vds , vgs = estrazione_dati.estrazione_dati_id_vds(path_dispositivo)
    gds = gm_gds(id=id , vgs_vds=vds)

    # Estranzione informazioni
    titolo , _ , _ , canale_dispositivo  = titolo_plot(path_dispositivo)

    nome_vgs, _ , nome_vds = _nomi_assi_id_vgs_vds(canale_dispositivo)
    nome_gds = r"g_{DS}"

    plt.figure(f"{titolo} - gds-vds")
    plt.plot(vds, gds, label=[fr"${nome_vgs} = {vgs_i}$ mV" for vgs_i in vgs])
    plt.xlabel(f"${nome_vds}$ [V]")
    plt.ylabel(rf"${nome_gds}$ [A/V]")
    plt.title(titolo)
    plt.legend()
    return plt.gcf()
    
def plot_gm_id_w_l(path_dispositivo):
    '''
        Si estrae a vds massima
    '''
    _setup_plot_style()
    # Estrazione dei valori
    id , vgs , vds = estrazione_dati.estrazione_dati_id_vgs(path_dispositivo , secondo_file = False)
    id = id[: , -1]
    vds = vds[-1]
    gm = gm_gds(id=id , vgs_vds=vgs)
    titolo , W , L , canale_dispositivo = titolo_plot(path_dispositivo)

    gm_id = gm / id

    id_l_w = id * (L/W)

    val_y , val_x , x , y = _intercette(id_l_w , gm_id , gm , id)

    plt.figure(f"{titolo} - gm/id id-l/w")
    plt.loglog(id_l_w , gm_id)
    plt.axhline(val_y , linestyle = "--", linewidth = 0.6 , color = "black")
    plt.axvline(val_x , linestyle = "--", linewidth = 0.6 , color = "black")
    plt.plot(x,y , linestyle = "--" , linewidth = 0.6 , color = "black")

    plt.title(titolo)

    plt.ylabel(r"$g_{m}/I_{D}$ [V$^{-1}$]")
    plt.xlabel(r"$I_{D} \cdot L/W$ [A]")

    # plt.grid(which="both" , linestyle = "--",  linewidth = 0.3)
    plt.ylim((1, 100))
    plt.xlim((1e-9, 5e-5))
    plt.grid(which="minor")
    return plt.gcf()

def plot_jg_vgs(path_chip):
    
    _setup_plot_style()
    cartelle = get_cartelle(path_chip , contenenti_misure=True , no_nf = True)

    nome_chip = Path(path_chip).name[5] + Path(path_chip).name[4]

    nome_vgs , _ ,_ = _nomi_assi_id_vgs_vds(canale_dispositivo=nome_chip[0])
    
    plt.figure(f"{nome_chip} - jg-vgs")
    for c in cartelle:
        path_file = Path(c)
        nome_dispositivo = Path(c).name
        mod_jg, vgs = estrazione_dati.estrazione_dati_jg_vgs(path_file)
        
        # Eseguiamo lo smooth
        mod_jg = uniform_filter1d(mod_jg, size=5)

        plt.semilogy(vgs , mod_jg , label = nome_dispositivo)

    plt.xlabel("$" + nome_vgs + "[V]$")
    plt.ylabel("$|J_G|[A/cm^2]$")
    plt.legend()
    plt.grid(which="minor")

    return plt.gcf()


## Funzioni di plot per le Vth (a questi gli vengono passati i valori)

def plot_rm(rm:np.array , vgs:np.array , coefficenti_retta:tuple , intervallo_fit:tuple , vth:float , path_dispositivo:Path):
    _setup_plot_style()
    titolo , _ , _ , canale_dispositivo = titolo_plot(path_dispositivo)
   
    _plot_fit_lin(vgs , rm , coefficenti_retta, intervallo_fit, vth, titolo , "RM")
    
    plt.xlim(left = 0)
    plt.ylim(bottom = -0.1)

    plt.ylabel(r"$\frac{I_D}{\sqrt{gm}}$ [$\mathrm{\sqrt{A \cdot V}}$]")
    plt.xlabel(f"${_label_vgs(canale_dispositivo)}$ [V]")
    return plt.gcf()


def plot_sdlm(sdlm:np.array , vgs:np.array , x_fit:np.array , y_fit:tuple , grado_fit:int , vth:float , path_dispositivo:Path):
    _setup_plot_style()
    titolo , _ , _ , canale_dispositivo = titolo_plot(path_dispositivo)

    plt.figure(f"{titolo} - SDLM")
    plt.plot(vgs , sdlm , label = "SDLM")
    plt.plot(x_fit , y_fit , label = f"Fit polinomiale di grado {grado_fit}")

    plt.axvline(vth , linestyle = "--" , linewidth = 0.5 ,  color = "black")
    plt.scatter(vth , y_fit.min() , zorder = 100 , color = "red" , marker="s")

    if canale_dispositivo == "N":
        ylabel = r"$\frac{\delta^2 \ln(I_D)}{\delta V_{GS}^2} \left[\frac{\ln(A)}{V^2}\right]$"
    else:
        ylabel = r"$\frac{\delta^2 \ln(I_D)}{\delta V_{SG}^2} \left[\frac{\ln(A)}{V^2}\right]$"

    plt.ylabel(ylabel)
    plt.xlabel(f"{_label_vgs(canale_dispositivo)} [V]")
    plt.legend()
    plt.title(titolo)
    return plt.gcf()

def plot_tcm(tcm:np.array , vgs:np.array , x_fit:np.array , y_fit:tuple , grado_fit:int , vth:float , path_dispositivo:Path):
    _setup_plot_style()
    titolo , _ , _ , canale_dispositivo = titolo_plot(path_dispositivo)

    plt.figure(f"{titolo} - TCM")
    plt.plot(vgs , tcm , label = "TCM")
    plt.plot(x_fit , y_fit , label = f"Fit polinomiale di grado {grado_fit}")

    plt.axvline(vth , linestyle = "--" , linewidth = 0.5 ,  color = "black")
    plt.scatter(vth , y_fit.max() , zorder = 100 , color = "red" , marker="s")

    if canale_dispositivo == "N":
        ylabel = r"$\frac{\delta g_{m}}{\delta V_{GS}} \left[\frac{A}{V^2}\right]$"
    else:
        ylabel = r"$\frac{\delta g_{m}}{\delta V_{SG}} \left[\frac{A}{V^2}\right]$"

    plt.ylabel(ylabel)
    plt.xlabel(f"{_label_vgs(canale_dispositivo)} [V]")
    plt.legend()
    plt.title(titolo)

    return plt.gcf()



def plot_fit_lineare(id:np.array , vgs:np.array , coefficenti_retta:tuple , intervallo_fit:tuple , vth:float , path_dispositivo:Path):
    _setup_plot_style()
    titolo , _ , _ , canale_dispositivo = titolo_plot(path_dispositivo)
   
    _plot_fit_lin(vgs , id , coefficenti_retta , intervallo_fit , vth , titolo , "Fit Lineare")
    
    plt.xlim(left = 0)
    plt.ylim(-0.01 , np.max(id) + 0.015)

    plt.ylabel(r"$I_D$ [A]")
    plt.xlabel(f"{_label_vgs(canale_dispositivo)} [V]")
    return plt.gcf()




# Funzioni di supporto

def _plot_fit_lin(x , y, coefficenti_retta, intervallo_fit, vth, titolo , tipologia_fit):

    plt.figure(f"{titolo} - {tipologia_fit}")
    plt.plot(x , y , label = tipologia_fit)

    # Disegna la retta con intercetta e pendenza specificate
    x_fit = np.linspace(vth-0.2, np.max(x), 100).reshape(-1, 1)
    y_fit = (coefficenti_retta[0] + coefficenti_retta[1] * x_fit).reshape(-1, 1)
    plt.plot(x_fit, y_fit , label = "Fit Lineare")

    plt.axvline(intervallo_fit[0] , linestyle = "--" , linewidth = 0.5 , color = "red")
    plt.axvline(intervallo_fit[1] , linestyle = "--" , linewidth = 0.5 , color = "red")
    plt.axvline(vth , linestyle = "--" , linewidth = 0.5 , color="black")
    
    plt.scatter(vth , 0 , zorder =100  , marker="s" , color = "r")
    plt.legend()
    plt.title(titolo)

def _label_vgs(canale_dispositivo):
    if canale_dispositivo == "N":
        label_vgs = r"$V_{GS}$"
    elif canale_dispositivo == "P":
        label_vgs = r"$|V_{GS}|$"
    else:
        raise ValueError(f"Canale dispositivo Errato: '{canale_dispositivo}'")
    return label_vgs


def _intercette(id_l_w, gm_id, gm, id):
    """
    Calcola le intercette per il grafico gm/ID vs ID/W.
    
    Parametri:
        id_l_w (np.ndarray): ID / (L * W)
        gm_id (np.ndarray): gm / ID
        gm (np.ndarray): gm
        id (np.ndarray): corrente ID
    
    Ritorna:
        val_y: valore massimo di gm/ID
        val_x: punto di intercetta su x
        x: ascisse per la retta interpolata (2 punti)
        y: ordinate per la retta interpolata (2 punti)
    """
    
    val_y = np.max(gm_id)

    if any(val < 0 for val in id):
        raise ValueError("Attenzione ci sono valori di corrente negativi... verificare se è un dispositivo funzionante")
    
    valori_giusti = gm / np.sqrt(id)
    valori_assoluti = np.abs(valori_giusti - 1)

    # Trova il primo indice più vicino a 1
    indici_valori = [np.argmin(valori_assoluti)]

    # Escludi il primo indice e cerca il secondo più vicino
    array_booleano = np.ones_like(valori_assoluti, dtype=bool)
    array_booleano[indici_valori[0]] = False
    indici_valori.append(np.argmin(valori_assoluti[array_booleano]))

    # Correggi per l'indice corretto nel vettore originale
    if indici_valori[1] >= indici_valori[0]:
        indici_valori[1] += 1

    # Regressione lineare su log-log
    coeffs = np.polyfit(np.log(id_l_w[indici_valori]), np.log(gm_id[indici_valori]), 1)

    x_fine = np.linspace(id_l_w[0], id_l_w[-1], int(1e6))
    y_fine = np.exp(np.polyval(coeffs, np.log(x_fine)))

    # Trova val_x dove y ≈ val_y
    idx_min = np.argmin(np.abs(y_fine - val_y))
    val_x = x_fine[idx_min]

    # Ricostruisci la retta per il plot (solo 2 punti estremi)
    x = np.array([id_l_w[0], id_l_w[-1]])
    y = np.exp(np.polyval(coeffs, np.log(x)))

    return val_y, val_x, x, y



def _nomi_assi_id_vgs_vds(canale_dispositivo):  
    '''
    Restituisce i nomi degli assi per VGS, ID e VDS a seconda del tipo di canale.
    Parametri:
        canale_dispositivo (str): 'N' per NMOS, 'P' per PMOS
    Ritorna:
        tuple: (nome_vgs, nome_id, nome_vds)
    '''
    if(canale_dispositivo == 'P'):
        nome_vgs = r"|V_{GS}|"
        nome_id = r"|I_D|"
        nome_vds = r"|V_{DS}|"
    elif(canale_dispositivo == 'N'):
        nome_vgs = r"V_{GS}"
        nome_id = r"I_D"
        nome_vds = r"V_{DS}"
    else: raise ValueError(f"Valore non valido: canale_dispositivo = {canale_dispositivo}")
    return nome_vgs,nome_id,nome_vds

def save_plot(fig, dir , name , show_plot):
    fig_path = Path(dir) / f"{name}.png"
    fig.savefig(fig_path, dpi=300, bbox_inches='tight')
    if not show_plot:
        plt.close(fig)



def elabora_plot(path, show_plot=True):
    path_cartelle = get_cartelle(path , contenenti_misure=True)
    
    for  idx,c in enumerate(path_cartelle):        
        
        c = Path(c)

        path_plot = c / "plot"
        Path(path_plot).mkdir(exist_ok=True)

        print(f"\t- Elaborazione di {c.name}", end="")


        fig = plot_id_vgs(c)
        save_plot(fig , path_plot , "plot_id_vgs" , show_plot)

        fig = plot_id_vgs(c, semilog=True)
        save_plot(fig , path_plot , "plot_id_vgs_semilog" , show_plot)

        fig = plot_gm_vgs(c)
        save_plot(fig , path_plot , "plot_gm_vgs" , show_plot)

        if "nf" not in c.name:
            fig = plot_gm_id_w_l(c)
            save_plot(fig , path_plot , "plot_gm_id_w_l" , show_plot)
        else: print(" - plot: 'plot_gm_id_w_l' non eseguito" , end="")

        fig = plot_id_vds(c)
        save_plot(fig , path_plot , "plot_id_vds" , show_plot)

        fig = plot_gds_vds(c)
        save_plot(fig , path_plot , "plot_gds_vgs" , show_plot)


        fig = plot_id_vgs(c , secondo_file=True)
        save_plot(fig , path_plot , "plot_id_vgs_2" , show_plot)

        fig = plot_id_vgs(c, semilog=True , secondo_file=True)
        save_plot(fig , path_plot , "plot_id_vgs_semilog_2" , show_plot)

        fig = plot_gm_vgs(c , secondo_file=True)
        save_plot(fig , path_plot , "plot_gm_vgs_2" , show_plot)

        if show_plot:
            plt.show(block=False)
            plt.pause(0.1)

        print(f" - Completata! {idx+1} / {len(path_cartelle)}")


    path_plot = Path(path) / "plot"
    path_plot.mkdir(exist_ok=True)
    fig = plot_jg_vgs(path)
    save_plot(fig , path_plot , "plot_mod_jg_vgs" , show_plot)

    if show_plot:
        plt.show(block=False)
        plt.pause(0.1)



if __name__ == "__main__":    
    plot = plot_jg_vgs("/home/emilio/Documenti/github/Caratterizzazione-Mosfet/Misure statiche/N6/Chip6NMOS")
    plot.show()
