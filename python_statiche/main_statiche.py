from calcolo_parametri import gm_gds
from calcolo_parametri import vth
from pathlib import Path

import matplotlib.pyplot as plt

import csv2txt
import sys
import time
import plot

def main(path_cartella , show_plot:True):

    if not Path(path_cartella).exists():
        print(f"La directory indicata non esiste:\n'{path_cartella}'")
        return

    print(f"- Inizio elaborazione della cartella:\n '{path_cartella}'\nImpostazioni: {"Mostra i plot" if show_plot else "Non mostrare i plot"}\n")
    tempo = time.time()

    ## Conversione dei file

    csv2txt.csv2txt_chip(path_cartella)

    ## Creazione dei Plot singoli
    print("\nInizio creazione plot")
    plot.elabora_plot(path_cartella , show_plot)
    print("Fine creazione plot")

    if show_plot:
        input("Premere invio per continuare (gli attuali plot verranno chiusi)...")
    plt.close("all")

    ## Creazione dei file gm e gds
    print("\nInizio creazione dei file gm e gds")
    gm_gds.crea_file_gm_gds(path_cartella)
    print("\nFine creazione dei file gm e gds")

    print("\nInizio calcolo Vth")
    vth.calcolo_vth(path_cartella , show_plot = show_plot)
    print("\nFine calcolo Vth")

    tempo -= time.time()
    print(f"- Fine elaborazione, tempo impiegato {-tempo:.2f} sec")

    if show_plot:
        input("\nPer terminare l'operazione e chiudere tutti i plot premere invio...")



if __name__ == "__main__":
    if len(sys.argv) <= 1:
        print("Inserire il path completo del chip che si vuole elaborare")
        sys.exit(1)
    elif len(sys.argv) == 2:
        main(sys.argv[1] , show_plot=True)
    elif len(sys.argv) == 3:
        main(sys.argv[1] , show_plot=(False if (sys.argv[2].lower() == "false" or sys.argv[2].lower() == "f") else True))
    else:
        print(f"Si sono inseriti troppi parametri!\n {sys.argv}")
        sys.exit(1)
