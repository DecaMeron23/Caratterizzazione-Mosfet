import argparse
from calcolo_parametri import gm_gds
from calcolo_parametri import vth
from pathlib import Path

import matplotlib.pyplot as plt

import csv2txt
import sys
import time
import plot

def main(path_cartella , show_plot=True):

    if not Path(path_cartella).exists():
        print(f"La directory indicata non esiste: '{path_cartella}'")
        exit()

    print(f"Inizio elaborazione della cartella: '{path_cartella}'")
    print(f"Impostazioni: {"Mostra i plot" if show_plot else "Non mostrare i plot"}")
    print()
    print()
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


    plt.close("all")


def str2bool(value):
    value = value.lower()
    if value in ("true", "t"):
        return True
    if value in ("false", "f"):
        return False
    raise argparse.ArgumentTypeError("Valore booleano atteso")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="main_statiche.py",
        description="script per l'analisi delle misure statiche di un ASIC")
    parser.add_argument("path" , help= "Path assoluto dell'ASIC da analizzare")
    parser.add_argument(
        "-p" , "--plot",
        action="store_true",
        help="opzione che fa visualizzare i plot"
    )
    args = parser.parse_args()

    main(path_cartella=args.path , show_plot=args.plot)