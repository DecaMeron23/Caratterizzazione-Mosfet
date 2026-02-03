import numpy as np
import pandas as pd
from pathlib import Path
import os
from . import titolo_plot

def estrazione_dati_id_vgs(path_dispositivo, tipo = None , secondo_file = False):
    file = Path(path_dispositivo) / f"id-vgs{"-2" if secondo_file else ""}.txt"
    dati = pd.read_csv(file, delimiter='\t').to_numpy()
    vg = dati[:, 0]

    # se il tipo del file non è specificato lo prelevo
    if tipo is None:
        tipo=Path(path_dispositivo).name[0]

    if tipo == 'P':
        vgs = -(vg - 0.9)
    elif tipo == 'N':
        vgs = vg
    else:
        raise ValueError("Tipo deve essere 'P' o 'N'")

    colonne_id = np.arange(1, dati.shape[1], 5)
    id = dati[:, colonne_id]

    if tipo == 'P':
        id = np.fliplr(np.abs(id))

    id = id[:, 1:]  # escludiamo lo zero

    if secondo_file:
        vds = np.arange(10, 101, 10)
    else:
        vds = np.arange(150, 901, 150)

    return id, vgs, vds


def estrazione_dati_id_vds(path_dispositivo, tipo = None):
    file = Path(path_dispositivo) / "id-vds.txt"

    dati = pd.read_csv(file, delimiter='\t').to_numpy()
    vd = dati[:, 0]

    # se il tipo del file non è specificato lo prelevo
    if tipo is None:
        tipo=Path(path_dispositivo).name[0]

    if tipo == 'P':
        vds = np.abs(vd - 0.9)
    elif tipo == 'N':
        vds = vd
    else:
        raise ValueError("Tipo deve essere 'P' o 'N'")

    colonne_id = np.arange(1, dati.shape[1], 5)
    id = dati[:, colonne_id]

    if tipo == 'P':
        id = np.fliplr(np.abs(id))

    id = id[:, 1:]  # escludiamo lo zero

    if len(colonne_id) == 7:
        vgs = np.arange(150, 901, 150)
    elif len(colonne_id) == 11:
        vgs = np.arange(10, 101, 10)
    else:
        raise ValueError("Formato colonne ID non riconosciuto")

    return id, vds, vgs


def estrazione_dati_jg_vgs(path_dispositivo, tipo = None):
    file = Path(path_dispositivo) / "id-vgs.txt"
    dati = pd.read_csv(file, delimiter='\t').to_numpy()
    vg = dati[:, 0]

    # se il tipo del file non è specificato lo prelevo
    if tipo is None:
        tipo=Path(path_dispositivo).name[0]

    if tipo == 'P':
        vgs = -(vg - 0.9)
        colonna_ig_vds0 = 32
    elif tipo == 'N':
        vgs = vg
        colonna_ig_vds0 = 2
    else:
        raise ValueError("Tipo deve essere 'P' o 'N'")

    mod_ig = np.abs(dati[:, colonna_ig_vds0])

    _, W, L , _ = titolo_plot.titolo_plot(Path(file).parent)
    W *= 1e-4
    L *= 1e-4

    mod_jg = mod_ig / (W * L)

    return mod_jg, vgs

def estrazione_dati_gm_vgs(path_dispositivo:str | Path):
    file = Path(path_dispositivo) / "gm.txt"
    gm, vgs, vds = _estrazione_gm_gds(file)
    return gm, vgs, vds

def estrazione_dati_gds_vds(path_dispositivo:str):
    file = Path(path_dispositivo) / "gds.txt"

    gds , vds , vgs = _estrazione_gm_gds(file)

    return gds, vds, vgs

def _estrazione_gm_gds(file):
    dati = pd.read_csv(file, delimiter='\t').to_numpy()
    tensione_principale = dati[:, 0]

    gm_gds = dati[:, 1:]  # escludiamo lo zero

    if not gm_gds.shape[1] == 6:
        raise ValueError(f"Il file non corrisponde a quello ipotizzato: sono presenti {gm_gds.shape()[1]} colonne mentre se ne aspettavano 6")

    tensione_secondaria = np.arange(150, 901, 150)

    return gm_gds, tensione_principale, tensione_secondaria
