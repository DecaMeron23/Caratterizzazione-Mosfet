from pathlib import Path

def titolo_plot(nome_cartella):
    """
    Restituisce:
    - titolo: stringa per il titolo del plot (es. 'NMOS 100/0.030')
    - W: larghezza del canale in µm (es. 100)
    - L: lunghezza del canale in µm (es. 0.03)
    - tipo: tipo del dispositivo ('N' o 'P')
    """

    nome = Path(nome_cartella).name
    tipo = nome[0]
    tokens = nome.split("-")

    try:
        tipo_transistor = f"{tipo}MOS"
        larghezza = float(tokens[1])
        lunghezza = float(tokens[2]) / 1000  # da nm a µm
        titolo = f"{tipo_transistor} {int(larghezza)}/{lunghezza:.3f}"
        return titolo, larghezza, lunghezza, tipo
    except Exception as e:
        raise ValueError("Errore nel parsing del nome della cartella, assicurati che sia nel formato 'N5-600-180'") from e
