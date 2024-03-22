# Descrizione Funzioni e Scrip Matlab

In questa cartella sono presenti tutti gli script funzionali, quindi che eseguono operazioni di calcolo, conversione file ecc.
Mentre nella cartella ScriptPlot sono presenti tutte le funzioni che generano i plot.

#### Lista delle funzioni (o classi) Principali:
- Vth
- csv2txt
- EstrazioneDati
- estrazioneCartelle
- delta_gm_gds
- titoloPlot

#### Vth
Questa classe dispone di tutte le funzioni che calcolano/maneggiano le V<sub>th</sub> (oppure &Delta;V<sub>th</sub>) in particolare sono presenti le funzioni:

- **calcolo_vth** la quale esegue il calcolo di tutte V<sub>th</sub> con i diversi metodi. Per eseguirla posizionarsi all'interno di un ASIC di uno specifico irraggiamento, *ad esempio: "Chip4NMOS_50Mrad*"
- **calcolo_Vth_irraggiamenti** questa funzione provvede a calcolare, per tutti i diversi irraggiamenti le V<sub>th</sub>. In particolare per ogni irraggiamento esegue la funzione *calcolo_vth*. Per utilizzare questa funzione è necessario posizionarsi all'interno della cartella contenente tutte le directory dei diversi irraggiamenti per uno specifico dispositivo.
- **RM** calcola la V<sub>th</sub> con il metodo: *"Ratio Method"*, gli intervalli in cui si esegue il fit sugli stessi dispositivi possono variare in base all'irraggiamento
- **RM_Estremi_PreIrraggiamento**, come la *RM*, ma per le V<sub>th</sub> post-irraggiamento utilizza per tutti lo stesso intervallo (preso dal pre-irraggiamento).  
- **FIT_LIN**
- **SDLM**  
- **TCM**
- **EstraiVth**, questa funzione serve per estrarre le V<sub>th</sub> dai singoli file .txt, che si vengono a creare all'interno della directory "Vth", più precisamente una volta posizionati nella cartella "Vth" avviare la funzione, la quale crerà una cartella "tabelle" che conterra il file "Vth.xls" contenente tutte le V<sub>th</sub> raggruppate 

#### CSV2TXT
Questa classe implementa 2 funzioni di cui solo una viene utilizzata, **chip** la quale deve essere chiamata quando si è all'interno della cartella contenente tutte le misure di ASIC ad un certo grado di irraggiamento, l'obbiettivo di questa funzione è di trasformare i file ".csv" generati durante l'estrazioni in laboratori, in file .txt più comprensivi.
Inoltre quando convete i file genera anche dei plot salvandoli nelle diverse cartelle dei dispositivi    

#### EstrazioneDati
Questa classe implementa 3 funzioni:
- **estrazione_dati_vgs**, funzione che estrae i dati da un file. In input si da il nome del file ("id_vgs.txt") e il tipo di dispositivo (ad esempio: 'P').
In output restituisce la prima colonna del file, che consideriamo V<sub>gs</sub>, se il dispositivo è P restituisce V<sub>sg</sub> (dato che V<sub>s</sub> = 0.9V), come secondo output restituisce una matrice contenente le I<sub>D</sub> al variare di V<sub>DS</sub> (terzo output), se il dispositivo è P restituisce il valore assoluto di I<sub>D</sub>
- **estrazione_dati_vds** Questa funzione svolge lo stesso lavoro di *estrazione_dati_vgs* ma lo fa per le V<sub>DS</sub>
- **estrazione_dati_jg_vgs** funzione che estrae dal file *id-vgs.txt* le I<sub>g</sub> a V<sub>DS</sub> minima (0 nel caso dei N e 0.9V nei P), e restituisce la J<sub>G</sub>.