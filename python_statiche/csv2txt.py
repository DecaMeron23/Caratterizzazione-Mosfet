import pandas as pd
import numpy as np
import os
from pathlib import Path
from funzioni_ausiliarie import ricerca_file

def csv2txt(file:Path | str):
    """
    Converte un file CSV in un file TXT formattato.
    ---------
    file: str
        Percorso del file CSV di input da convertire.
    Restituisce
    -----------
    None
        La funzione scrive i dati elaborati in un file TXT con lo stesso nome base del file di input.
    Note
    ----
    - Il file TXT di output verrà salvato nella stessa directory del file CSV di input.
    """
    try:
        # Leggi il file CSV
        pd_data = pd.read_csv(file, header=6 , encoding="utf-8")
    except Exception as e:
        print(f"Errore nella lettura del file CSV '{file}': {e}")
        print(f"Controllare se il file è chiamato nel corretto modo ad esempio: \"id-vds.csv\" oppure \"id-vgs_2.csv\"")
        exit()
    file_name = os.path.basename(file)
    type_file = file_name[4]  # 5° carattere
    
    # Estrai e ordina i valori di vg
    vg_values = pd_data.iloc[:, 1].to_numpy()
    vg_values = np.unique(vg_values)
    num_vg = len(vg_values)

    # Calcolo numero righe per ogni vg
    num_rows = len(pd_data) // num_vg
    # Ottieni i nomi delle colonne dal DataFrame
    num_col = len(pd_data.columns) - 2

    data = pd_data.to_numpy()

    tensione_variabile = data[0:num_rows , 0]

    data = data[: , 2:]
    # faccio il reshape della matrice con num_rows (normalmente: 181) righe e num_vg x 5 colonne [es: id,ig,is,iavdd,ignd] 
    
    data = data.reshape(num_vg, num_rows, num_col)
    data = np.hstack([data[i] for i in range(num_vg)])
    
    # Determina il nome della cartella corrente
    nome_cartella = os.path.basename(os.path.dirname(file))


    if nome_cartella[0] == 'N':
        vgs = vg_values
    elif nome_cartella[0] == 'P':
        vgs = np.flipud(0.9 - vg_values)

    # Costruzione dei nomi delle colonne
    name_table = [f"v{type_file}"]
    for vg_i in vgs:
        name_table.extend([
            f"id_v{'d' if type_file == 'g' else 'g'} = {vg_i}V",
            f"ig_v{'d' if type_file == 'g' else 'g'} = {vg_i}V",
            f"is_v{'d' if type_file == 'g' else 'g'} = {vg_i}V",
            f"iavdd_v{'d' if type_file == 'g' else 'g'} = {vg_i}V",
            f"ignd_v{'d' if type_file == 'g' else 'g'} = {vg_i}V"
        ])

    tensione_variabile = tensione_variabile.reshape(-1,1)
    # Crea il DataFrame e salva come file di testo con tabulazione
    df_final = pd.DataFrame(np.hstack((tensione_variabile, data)), columns=name_table)
    output_file = os.path.splitext(file)[0] + ".txt"
    df_final.to_csv(output_file, sep="\t", index=False , float_format="%.7g")


def csv2txt_chip(path_cartella: Path | str):
    print("Conversione dei file csv...")

    pattern = Path(path_cartella).name[5] + Path(path_cartella).name[4] + "-*"
    cartelle = ricerca_file.get_cartelle(path_cartella , contenenti_misure=True , pattern= pattern)
    
    for idx, c in enumerate(cartelle):
        verifica_e_rinomina(c)
        errore = False
        print(f"\t - Elaborazione di {c.name}" , end="")
        
        try:
            csv2txt(Path(c) / "id-vds.csv")
        except Exception as e:
            errore = True
            print(f"\n\t\t Errore durante la conversione file 'id-vds.csv'\n\t\t -> err: {e}")
        
        try:
            csv2txt(Path(c) / "id-vgs.csv")
        except Exception as e:
            errore = True
            print(f"\n\t\t Errore durante la conversione file 'id-vgs.csv'\n\t\t -> err: {e}")
        
        try:
            csv2txt(Path(c) / "id-vgs-2.csv")
        except Exception as e:
            errore = True
            print(f"\n\t\t Errore durante la conversione file 'id-vgs-2.csv'\n\t\t -> err: {e}")
            
            
        infoAvanzamento = f"{idx+1}/{len(cartelle)}"
        
        if errore:
            print(f"\n\t -> Completata! {infoAvanzamento}")
        else:
            print(f"\t Completata! {infoAvanzamento}")

    print("Fine della conversione dei file csv")

# Funzioni Ausiliarie

def verifica_e_rinomina(cartella: Path | str):
    '''
    Funzione che prede tutti i file .csv e verifica se hanno il '-' al posto di '_'
    '''
    for file in os.listdir(cartella):
        if file.endswith(".csv") and "_" in file:
            new_file = file.replace("_", "-")
            os.rename(os.path.join(cartella, file), os.path.join(cartella, new_file))

