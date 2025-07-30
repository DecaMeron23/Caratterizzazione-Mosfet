from pathlib import Path
import fnmatch

def get_cartelle(base_path, pattern="*" , contenenti_misure = False , no_nf = False):
    """
    Restituisce una lista di cartelle nel path specificato che rispettano il pattern.

    :param base_path: str o Path - directory in cui cercare
    :param pattern: str - pattern da confrontare (es: 'N5-*')
    :param contenenti_misure: boolean - Se sono cartelle del tipo 'N5-200-180'
    :param no_nf: boolean - esclude i dispostitivi non funzionanti es: 'N5-200-180-nf'
    :return: lista di Path
    """
    base_path = Path(base_path)
    lista_cartelle = [p for p in base_path.iterdir() if p.is_dir() and fnmatch.fnmatch(p.name, pattern)]

    if contenenti_misure:
        # Esempio: solo cartelle con nome che contiene 2 trattini (es: 'N5-200-180')
        lista_cartelle = [p for p in lista_cartelle if ((p.name.count('-') >= 2 ) and (p.name[0] == 'N' or p.name[0] == 'P') and (not no_nf or "nf" not in p.name))]

    return lista_cartelle


