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


def crea_file_gm_gds(path_cartella):
    directory_dispositivi = get_cartelle(base_path=path_cartella , contenenti_misure=True)
    
    def elabora_salva_gm_gds(dir , tipologia:str):
        if "vgs" in tipologia:
            id , tenisone_primaria , tensione_secondaria = estrazione_dati.estrazione_dati_id_vgs(Path(dir)/f"id-{tipologia}.txt")
        elif "vds" in tipologia:
            id , tenisone_primaria , tensione_secondaria = estrazione_dati.estrazione_dati_id_vds(Path(dir)/f"id-{tipologia}.txt")
        else:
            raise ValueError(f"Tipologia '{tipologia}' non riconosciuta in elabora_salva_gm_gds.")
        
        dati_calcolati = gm_gds(id=id, vgs_vds=tenisone_primaria)
        
        nome_tensione_secondaria = f"G{"m" if "vgs" in tipologia else "ds"}_V{"d" if "vgs" in tipologia else "g"}s="
        header = np.hstack((f"{tipologia[:3].capitalize()}", [f"{nome_tensione_secondaria}{vds_i/1000:.2f}V" for vds_i in tensione_secondaria]))
        df_dati_calcolati = pd.DataFrame(data=np.hstack((tenisone_primaria.reshape(-1, 1) , dati_calcolati)) , columns=header)
        nome_file = Path(dir) / f"{"gds" if "vds" == tipologia else ("gm_2" if "vgs-2" == tipologia else "gm")}.txt"
        df_dati_calcolati.to_csv(nome_file, sep='\t', index=False , float_format="%.7g")
    
    
    for idx, dir in enumerate(directory_dispositivi):
        
        elabora_salva_gm_gds(dir , "vgs")
        elabora_salva_gm_gds(dir , "vds")
        elabora_salva_gm_gds(dir , "vgs-2")

        print(f"\t- {idx+1} elaborati su {len(directory_dispositivi)}")
