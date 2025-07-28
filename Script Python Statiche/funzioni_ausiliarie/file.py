from pathlib import Path
import fnmatch

def get_cartelle(base_path, pattern="*"):
    """
    Restituisce una lista di cartelle nel path specificato che rispettano il pattern.

    :param base_path: str o Path - directory in cui cercare
    :param pattern: str - pattern da confrontare (es: 'N5-*')
    :return: lista di Path
    """
    base_path = Path(base_path)
    return [p for p in base_path.iterdir() if p.is_dir() and fnmatch.fnmatch(p.name, pattern)]
