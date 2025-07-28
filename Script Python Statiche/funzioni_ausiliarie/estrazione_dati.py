import numpy as np
import pandas as pd
from pathlib import Path
import os
from . import titolo_plot

def estrazione_dati_id_vgs(file, tipo = None):
    dati = pd.read_csv(file, header=1, delimiter='\t').to_numpy()
    vg = dati[:, 0]

    # se il tipo del file non è specificato lo prelevo
    if tipo is None:
        tipo=os.path.basename(os.path.dirname(file))[0]

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

    if len(colonne_id) == 7:
        vds = np.arange(150, 901, 150)
    elif len(colonne_id) == 11:
        vds = np.arange(10, 101, 10)
    else:
        raise ValueError("Formato colonne ID non riconosciuto")

    return id, vgs, vds


def estrazione_dati_id_vds(file, tipo = None):
    dati = pd.read_csv(file, header=1, delimiter='\t').to_numpy()
    vd = dati[:, 0]

    # se il tipo del file non è specificato lo prelevo
    if tipo is None:
        tipo=os.path.basename(os.path.dirname(file))[0]

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


def estrazione_dati_jg_vgs(file, tipo = None):

    dati = pd.read_csv(file, header=1, delimiter='\t').to_numpy()
    vg = dati[:, 0]

    # se il tipo del file non è specificato lo prelevo
    if tipo is None:
        tipo=os.path.basename(os.path.dirname(file))[0]

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
