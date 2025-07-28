import numpy as np
from scipy.ndimage import uniform_filter1d

def gm_gds(id, vgs_vds):
    """
    Calcola gm o gds in base a quale vettore viene passato come vgs_vds.
    
    Parametri:
        id (np.ndarray): matrice corrente [n x m]
        vgs_vds (np.ndarray): vettore dei valori su cui calcolare la derivata [n]
        
    Ritorna:
        gm (np.ndarray): matrice delle derivate calcolate [n x m]
    """

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

    return gm