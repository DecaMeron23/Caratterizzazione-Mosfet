## Esecuzione degli script:
### main_statiche.py

Per eseguire lo script main_statiche.py è necessario spostarsi nella cartella `/python_statiche` e in seguito creare l'ambiente virtuale, se lo si ha gia fatto passare prossimo punto:
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

#### Attivazione l'ambiente virtuale
Per attivare l'ambiente virtuale si usa il comando:
- su Windows `.venv\Scripts\activate.bat`
- su Linux o Mac `source .venv/bin/activate`

#### Uso di main_statiche
dopo aver attivato il `venv` si può procedere ad analizzare i dati per farlo lanciare il comando:
```bash
python main_statiche.py [path] [booleano]
```
dove:
- `[path]`: è il path completo (non relativo) alla cartella del dispositivo da elaborare, ad esempio: `"/home/emilio/Documenti/github/Caratterizzazione-Mosfet/Misure statiche/P1/Chip1PMOS_1Grad"`.
**Inserire le virgolette se il path contiene degli spazi** (come nell'esempio)
- `[booleano]`: Questo parametro è opzionale e normalmente è posto a `True`. Serve ad indicare se si vogliono vedere i plot durante l'elaborazione dei file

Quindi un esempio di esecuzione dello script è:
```
python main_statiche.py "/home/emilio/Documenti/github/Caratterizzazione-Mosfet/Misure statiche/N6/Chip6NMOS" false
```

## Struttura necessaria delle directory per operare:
Gli script python ipotizzano che le directory e i file sono disposti e nominati in un modo preciso.
Per un ASIC è necessario che si mantenga questa struttura (in questo esempi l'ASIC utilizzato è il N5):

    Chip5NMOS
    |
    ├── N5-200-180
    │   ├── id-vds.csv
    │   ├── id-vgs-2.csv
    │   └── id-vgs.csv
    |
    ├── N5-600-180
    │   ├── id-vds.csv
    │   ├── id-vgs-2.csv
    │   └── id-vgs.csv
    |
    ├── N5-600-30
    │   ├── id-vds.csv
    │   ├── id-vgs-2.csv
    │   └── id-vgs.csv
    |
    └── N5-600-60-nf
        ├── id-vds.csv
        ├── id-vgs-2.csv
        └── id-vgs.csv

Se c'è questa struttura gli script funzionano correttamente.
Se un dispositivo non funziona, ma si vogliono tenere lo stesso i valori, è necessario identificarlo con il postfisso `-nf` (ad esempio: `N5-600-60-nf` )in questo verranno esclusi questi dispositivi da alcune operazioni.