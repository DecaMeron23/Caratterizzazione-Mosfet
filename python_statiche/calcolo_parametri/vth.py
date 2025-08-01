from pathlib import Path
from matplotlib import pyplot as plt
from sklearn.linear_model import LinearRegression
from scipy.ndimage import uniform_filter1d

from funzioni_ausiliarie import ricerca_file
from funzioni_ausiliarie import estrazione_dati

import plot
import numpy as np
import pandas as pd

def RM(path_dispositivo:str, vds_value = 150)->float:
    '''
    Metodo RM: la vth è definita come l'intercetta con la retta y = 0 del fit lineare con la curva id/sqrt(gm) al variare di Vgs con una Vds = 150mV
    Si ipotizza che siano presenti il file gm.txt
    '''

    path_dispositivo = Path(path_dispositivo)

    gm, vgs , vds = estrazione_dati.estrazione_dati_gm_vgs(path_dispositivo)

    id, _ , _ = estrazione_dati.estrazione_dati_id_vgs(path_dispositivo , secondo_file=False)

    if vds_value not in vds:
        raise ValueError(f"La Vds indicata {vds_value} non è presente nell'elenco delle vds: {vds}")

    gm = gm[: , vds == vds_value]
    id = id[: , vds == vds_value]

    with np.errstate(invalid='ignore'):
        rm = id / np.sqrt(gm)

    fit, interval = _find_best_fit(vgs, rm)
    
    with np.errstate(invalid='ignore'):
        vth = float(-fit.intercept_ / fit.coef_[0])
                   
    plot.plot_rm(rm , vgs , (fit.intercept_ , fit.coef_[0]) , interval , vth , path_dispositivo)

    return float(f"{vth:.5g}")

def FIT_LIN(path_dispositivo:str, vds_value = 150)->float:
    '''
    Metodo FIT_LIN: la vth è definita come l'intercetta con la retta y = 0 del fit lineare della corrente di drain al variare di vgs con una vds = 150mV
    Si ipotizza che siano presenti i file id-vgs.txt
    '''

    path_dispositivo = Path(path_dispositivo)

    id, vgs , vds = estrazione_dati.estrazione_dati_id_vgs(path_dispositivo)

    if vds_value not in vds:
        raise ValueError(f"La Vds indicata {vds_value} non è presente nell'elenco delle vds: {vds}")

    id = id[: , vds == vds_value]

    fit, interval = _find_best_fit(vgs, id)
    
    vth = float(-fit.intercept_ / fit.coef_[0])

    plot.plot_fit_lineare(id , vgs , (fit.intercept_ , fit.coef_[0]) , interval , vth , path_dispositivo)

    return float(f"{vth:.5g}")


def SDLM(path_dispositivo:str, vds_value = 900 , grado_fit = 6 ,  smooth_size = 5)->float:
    path_dispositivo = Path(path_dispositivo)
    id , vgs , vds = estrazione_dati.estrazione_dati_id_vgs(path_dispositivo)

    id = id[: , vds == vds_value].squeeze()
    
    log_id = np.log(abs(id))
    
    # Eseguiamo la derivata seconda con smooth
    gradient_id = _smooth_e_gradient(log_id , vgs , size=smooth_size, pre_smooth=True)    
    
    gradient_id = _smooth_e_gradient(gradient_id , vgs , size=smooth_size)   



    # Prendiamo i valori compresi tra 0V e 0.7V 
    gradient_id  = gradient_id[np.abs(vgs - 0).argmin() : np.abs(vgs - 0.7).argmin() + 1]
    vgs = vgs[np.abs(vgs - 0).argmin() : np.abs(vgs - 0.7).argmin() + 1]

    x_fit , y_fit = _fit_poly(vgs , gradient_id , grado_fit)

    vth = x_fit[y_fit.argmin()]

    plot.plot_sdlm(gradient_id , vgs , x_fit , y_fit , grado_fit , vth , path_dispositivo)
    return float(f"{vth:.5g}")


def TCM(path_dispositivo:str, vds_value = 150 , grado_fit = 6 , smooth_size = 5):
    path_dispositivo = Path(path_dispositivo)

    gm , vgs, vds = estrazione_dati.estrazione_dati_gm_vgs(path_dispositivo)

    gm = gm[ : ,vds == vds_value].squeeze()

    # Eseguiamo la derivata prima
    tcm = _smooth_e_gradient(gm , vgs , pre_smooth=False , size = smooth_size)

    indice_max = tcm.argmax()

    indice_sup = indice_max+20
    indice_inf = indice_max-20

    if indice_sup > len(tcm):
        indice_sup = len(tcm)
    if indice_inf < 0:
        indice_inf = 0

    tcm = tcm[indice_inf : indice_sup]
    vgs = vgs[indice_inf : indice_sup]

    x_fit , y_fit = _fit_poly(vgs , tcm , grado_fit)
    
    vth = x_fit[y_fit.argmax()]

    plot.plot_tcm(tcm , vgs , x_fit , y_fit , grado_fit , vth , path_dispositivo)    
    return float(f"{vth:.5g}")



## Funzioni di supporto

def _fit_poly(x, y , grado, step = 1e-4):
    '''
    Funzione che esegue il il fit polinomiale di x su y e resituisce dei dati più fini con uno step pari a step
    '''
    # Eseguiamo un fit polinomiale
    coeff = np.polyfit(x , y , grado)
    modello = np.poly1d(coeff)

    # Creiamo dati fittizzi di vgs tra 0 e 0.7 con step di 0.1mV -> 1e-4
    x_fit = np.arange(x.min() , x.max() , step)
    y_fit = modello(x_fit)
    return x_fit , y_fit 


def _find_best_fit(x, y , min_value= 0.1 , max_value = 0.75):
    '''
    Funzione che prende diversi range di 
    '''
    indice_min = np.abs(x - min_value).argmin()
    indice_max = np.abs(x - max_value).argmin()

    prima_iterazione = True

    for idx in range(indice_min , indice_max+1):

        x_temp = np.array(x[idx : idx+31]).reshape(-1,1) # il 31 è escluso
        y_temp = np.array(y[idx : idx+31]).reshape(-1,1)
        
        x_temp = np.nan_to_num(x_temp , nan=0)
        y_temp = np.nan_to_num(y_temp , nan=0)
        model = LinearRegression()
        actual_fit = model.fit(x_temp,y_temp)
        actual_score = actual_fit.score(x_temp,y_temp)

        if prima_iterazione or best_score < actual_score:
            prima_iterazione = False
            best_fit = actual_fit
            best_score = actual_score
            best_interval = (x[idx] , x[idx+30])

    return best_fit, best_interval


def _smooth_e_gradient(x , t  , size , pre_smooth = False):
    '''
    Funzione che esegue la derivata di x rispetto a t cioè dx/dt eseguendo uno smooth dopo la derivata
    '''
    if pre_smooth:
        x = uniform_filter1d(x,  size = size)

    gradient = np.gradient(x, t , axis=0)

    gradient = uniform_filter1d(gradient , size = size)
    
    return gradient


def _calcola_vth_e_salva(path_dispositivo , path_cartella , show_plot):
    d = Path(path_dispositivo)
    nome_file = Path(path_cartella) / f"{d.name}.txt"
    header = ["Lin_fit_Id", "Vth_TCM", "Vth_SDLM", "Vth_RM"]
    
    vth_fit_lin = FIT_LIN(d)
    plot.save_plot(plt.gcf() , d / "plot" , "plot_vth_fit_lin" , show_plot)

    vth_TCM = TCM(d)
    plot.save_plot(plt.gcf() , d / "plot" , "plot_vth_tcm" , show_plot)

    vth_SDLM = SDLM(d)
    plot.save_plot(plt.gcf() , d / "plot" , "plot_vth_sdlm" , show_plot)

    vth_rm = RM(d)
    plot.save_plot(plt.gcf() , d / "plot" , "plot_vth_rm" , show_plot)

    vth = np.array([vth_fit_lin , vth_TCM , vth_SDLM , vth_rm]).reshape(1,-1) * 1e3
    df_vth = pd.DataFrame(columns=header , data=vth)
    df_vth.to_csv(nome_file , sep = '\t' , index=False , float_format="%.2f")



## Funzione Principale



def calcolo_vth(path_cartella:str , show_plot = True , nome_cartella_vth = "vth"):
    directory_dispositivi = ricerca_file.get_cartelle(base_path=path_cartella , contenenti_misure=True , no_nf=True)
    
    # Creaiamo la cartella dei plot
    path_cartella_vth = Path(path_cartella) / nome_cartella_vth
    path_cartella_vth.mkdir(exist_ok=True) 

    for idx, dir in enumerate(directory_dispositivi):
        (Path(dir)/"plot").mkdir(exist_ok=True)  
        _calcola_vth_e_salva(dir , path_cartella_vth , show_plot)
        if show_plot:
            plt.pause(0.1)
            plt.show(block=False)
        print(f"\t- {idx+1} elaborati su {len(directory_dispositivi)}")

