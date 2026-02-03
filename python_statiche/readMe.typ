

== Esecuzione degli script:
=== main_statiche.py

Per eseguire lo script main_statiche.py è necessario spostarsi nella cartella `/python_statiche` e in seguito creare l'ambiente virtuale, se lo si ha già fatto passare prossimo punto:
- Caso "Windows" con il prompt dei comandi CMD:
```bash
python -m venv .venv
# successivamente attivare l'ambiente virtuale
.venv\Scripts\activate.bat
# infine installare le dipendenze tramite
pip install -r requirements.txt
```
- Caso "Linux o Mac" su terminale:
```bash
python -m venv .venv
# successivamente attivare l'ambiente virtuale
source .venv/bin/activate
# infine installare le dipendenze tramite
pip install -r requirements.txt
```

==== Attivazione l'ambiente virtuale
Per attivare l'ambiente virtuale si usa il comando:
- su _Windows_:
```bash
.venv\Scripts\activate.bat
```

- su _Linux_ o _Mac_ 
```bash
source .venv/bin/activate
```

==== Uso di main_statiche
dopo aver attivato il `venv` si può procedere ad analizzare i dati per farlo lanciare il comando:
```bash
python main_statiche.py [-h] [-p] path
```
_MANDATORI_:
- `path`: è il path completo (non relativo) alla cartella del dispositivo da elaborare, ad esempio: `"/home/emilio/Documenti/github/Caratterizzazione-Mosfet/Misure statiche/P1/Chip1PMOS_1Grad"`. *Inserire le virgolette se il path contiene degli spazi* (come nell'esempio precedente)

_OPZIONALI_:
- `[-p]`: Serve ad indicare che si vogliono vedere i plot durante l'elaborazione dei file
- `[-h]`: Per visualizzare il menù di help (non è necessario inserire il `path`)
Quindi un esempio di esecuzione dello script, nel caso in cui si volessero vedere i plot, è:
```bash
python main_statiche.py "/home/emilio/Documenti/github/Caratterizzazione-Mosfet/Misure statiche/N6/Chip6NMOS" -p
```
oppure per visualizzare il menù di help digitare:
```bash
python main_statiche.py -h
```

== Struttura necessaria delle directory per operare:
Gli script Python ipotizzano che le directory e i file sono disposti e nominati in un modo preciso.
Per un ASIC è necessario che si mantenga la struttura seguente (in questo esempi l'ASIC utilizzato è il N5):
```terminal
    Chip5NMOS
    |
    ├── N5-200-180
    │   ├── id-vds.csv
    │   ├── id-vgs-2.csv
    │   └── id-vgs.csv
    |
    ├── N5-600-180
    │   ├── id-vds.csv
    │   ├── id-vgs-2.csv
    │   └── id-vgs.csv
    |
    ├── N5-600-30
    │   ├── id-vds.csv
    │   ├── id-vgs-2.csv
    │   └── id-vgs.csv
    |
    └── N5-600-60-nf
        ├── id-vds.csv
        ├── id-vgs-2.csv
        └── id-vgs.csv
```
Se c'è questa struttura gli script funzionano correttamente.
Se un dispositivo non funziona, ma si vogliono tenere lo stesso i valori, è necessario identificarlo ponendo post-fisso `-nf` nel nome della cartella, ad esempio: `N5-600-60-nf`, in questo verranno esclusi solo da alcune da alcune operazioni.
