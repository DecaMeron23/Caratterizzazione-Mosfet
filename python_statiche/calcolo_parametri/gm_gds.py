import numpy as np
import pandas as pd

from pathlib import Path
from scipy.ndimage import uniform_filter1d
from funzioni_ausiliarie.ricerca_file import get_cartelle
from funzioni_ausiliarie import estrazione_dati



def gm_gds(id, vgs_vds):
    """
    Calcola gm o gds in base a quale vettore viene passato come vgs_vds.
    
    Parametri:
        id (np.ndarray): matrice corrente [n x m]
        vgs_vds (np.ndarray): vettore dei valori su cui calcolare la derivata [n]
        
    Ritorna:
        gm (np.ndarray): matrice delle derivate calcolate [n x m]
    """

    # Rendo id sempre 2D per il calcolo
    id_is_1d = False
    if id.ndim == 1:
        id = id[:, np.newaxis]
        id_is_1d = True


    gm1 = np.zeros_like(id)
    gm2 = np.zeros_like(id)

    for i in range(id.shape[1]):
        gm1[:, i] = np.gradient(id[:, i], vgs_vds)

    gm2[0, :] = gm1[0, :]

    for i in range(id.shape[1]):
        gm2[1:, i] = np.gradient(id[:-1, i], vgs_vds[1:])

    gm = (gm1 + gm2) / 2

    # smoothing: applichiamo una media mobile
    for i in range(gm.shape[1]):
        gm[:, i] = uniform_filter1d(gm[:, i], size=5)
    
    # Se id era 1D ritorno solo la prima colonna
    if id_is_1d:
        return gm[:, 0]
    return gm


def crea_file_gm_gds(path_cartella: str | Path):
    # Creazione del patter, es: N5-*
    pattern = Path(path_cartella).name[5] + Path(path_cartella).name[4] + "-*"
    
    # Ricerca delle cartelle che corrispondono al pattern
    directory_dispositivi = get_cartelle(base_path=path_cartella , contenenti_misure=True , pattern= pattern)
    
    
    for idx, dir in enumerate(directory_dispositivi):
        errore = False
        
        print(f"\t - Elaborazione di {dir.name}" , end="")
        try:
            _elabora_salva_gm_gds(dir , "vgs")
        except Exception as e:
            errore = True
            print(f"\n\t\t Errore durante elaborazione 'gm_vgs'\n\t\t -> err: {e}", end = "")
        
        try:        
            _elabora_salva_gm_gds(dir , "vds")
        except Exception as e:
            errore = True
            print(f"\n\t\t Errore durante elaborazione 'gds_vds'\n\t\t -> err: {e}", end = "")
        
        try:
            _elabora_salva_gm_gds(dir , "vgs-2")
        except Exception as e:
            errore = True
            print(f"\n\t\t Errore durante elaborazione 'gm_vgs_2'\n\t\t -> err: {e}", end = "")


        infoAvanzamento = f"{idx+1}/{len(directory_dispositivi)}"
        if errore:
            print(f"\n\t -> Completata! {infoAvanzamento}")
        else:
            print(f" - Completata! {infoAvanzamento}")


def _elabora_salva_gm_gds(dir :str | Path , tipologia:str):
    dir = Path(dir)
    
    isVgs = "vgs" in tipologia
    isVds = "vds" in tipologia
    isVgs_2 = "vgs-2" in tipologia
    
    if (not (isVgs or isVds or isVgs_2)): # Verifico che almeno uno dei precedenti sia vero
        raise ValueError(f"Tipologia '{tipologia}' non rigonosciuta")
    
    if isVgs:
        id , tenisone_primaria , tensione_secondaria = estrazione_dati.estrazione_dati_id_vgs(dir , secondo_file= isVgs_2)
    elif isVds:
        id , tenisone_primaria , tensione_secondaria = estrazione_dati.estrazione_dati_id_vds(dir)

    dati_calcolati = gm_gds(id=id, vgs_vds=tenisone_primaria)
    
    nome_tensione_secondaria = f"G{"m" if isVgs else "ds"}_V{"d" if isVgs else "g"}s="
    
    headerTensioneSecondaria = [f"{nome_tensione_secondaria}{vds_i/1000:.2f}V" for vds_i in tensione_secondaria]
    header = np.hstack((f"{tipologia[:3].capitalize()}", headerTensioneSecondaria))
    
    # Creo il dataframe
    df_dati_calcolati = pd.DataFrame(data=np.hstack((tenisone_primaria.reshape(-1, 1) , dati_calcolati)) , columns=header)
    
    nome_file = dir / f"{"gds" if isVds else ("gm_2" if isVgs_2 else "gm")}.txt"
    
    # Salvo il file in fomrato .txt
    df_dati_calcolati.to_csv(nome_file, sep='\t', index=False , float_format="%.7g")
