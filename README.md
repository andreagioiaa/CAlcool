# CAlcool 🍺

CAlcool è un'applicazione mobile sviluppata in Flutter per il calcolo algoritmico del Tasso Alcolemico (BAC - Blood Alcohol Concentration) in maniera completamente "Offline-First". L'app garantisce il 100% di privacy poiché non effettua alcuna connessione a server esterni o database in cloud. Tutti i dati rimangono salvati esclusivamente in locale sul dispositivo dell'utente.

## 🚀 Funzionalità Principali

### 1. Calcolo del Tasso Alcolemico (BAC)
- Utilizza le formule scientifiche di **Watson** e **Widmark**.
- Ricalcolo dinamico che tiene conto di età, peso, altezza e sesso dell'utente.
- Calcolo in tempo reale del picco alcolemico e stima del tempo necessario per tornare a un tasso di **0.5 g/l** (limite di guida in molti Paesi) e a **0.0 g/l** (totale smaltimento).

### 2. Gestione Intelligente del Cibo (Assorbimento Bidirezionale)
- L'assorbimento dell'alcol viene mitigato se si assume del cibo, rallentando il picco alcolemico.
- **Ricalcolo Bidirezionale**: L'algoritmo valuta la distanza temporale assoluta tra il cibo e la bevanda.
  - **Pasto Completo**: Se assunto entro 3 ore (prima o dopo la bevuta), riduce l'impatto alcolemico del 25%.
  - **Spuntino**: Se assunto entro 1 ora (prima o dopo la bevuta), riduce l'impatto del 10%.

### 3. Timeline Cronologica (Storico Inserimenti)
- Una Timeline interattiva e scrollabile presente direttamente nella Dashboard.
- Mostra in ordine cronologico (dal più recente) tutti gli inserimenti della giornata corrente.
- Distingue visivamente tra **Bevande** (con dettagli di millilitri e percentuale alcolica) e **Pasti**, indicando l'orario esatto di assunzione per prevenire doppioni.

### 4. Preset Bevande (Fast Input)
- Un comodo menù con template pronti all'uso per inserimenti fulminei senza dover compilare manualmente i dati ogni volta.
- 6 preset inclusi: *Birra Piccola, Birra Media, Calice Vino, Shot, Cocktail Soft, Cocktail Strong*.
- Possibilità di inserire comunque bevande personalizzate.

### 5. Monitoraggio Statistiche e Costi
- Possibilità di aggiungere il costo di ogni singola consumazione.
- Sezione dedicata alle **Statistiche** per tracciare quante bevande sono state consumate e la spesa totale accumulata nel tempo.

### 6. Profilo Utente Modificabile
- Il profilo può essere aggiornato in qualsiasi momento (es. variazioni di peso o di età) e i calcoli del tasso alcolemico si aggiorneranno di conseguenza per le nuove consumazioni.

### 7. Backup ed Esportazione Dati (Mobile)
- Essendo l'app offline, è presente una comoda funzione di esportazione di tutti i salvataggi in formato **JSON**.
- Consente di esportare e importare lo storico su dispositivi iOS/Android per backup manuale senza dipendere dal cloud.

### 8. Design Neumorfico ed Ergonomia
- Interfaccia Utente curata con stile **Neumorfico** per un effetto visivo moderno, elegante e "soft-touch".
- Supporto nativo alla Dark Mode, modificabile direttamente dalle impostazioni.
- Tab-bar di navigazione rapida.

---

> **DISCLAIMER MEDICO:** *Questa app fornisce stime matematiche basate su formule standard. Non ha alcuna valenza medico-legale e non sostituisce un etilometro reale. Non guidare mai dopo aver bevuto.*
