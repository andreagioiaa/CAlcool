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

## 🛠️ Come Compilare l'App (Build)

### Compilare per Android (.apk)
Per generare il file di installazione per Android in modo semplice:

- **Metodo Rapido (Windows):** Fai doppio clic sul file `build_apk.bat` situato nella cartella principale del progetto. Questo script eseguirà la build e aprirà in automatico la cartella contenente l'APK al termine.
- **Metodo Manuale:** Apri il terminale nella cartella del progetto (`CAlcool`) ed esegui:
   ```bash
   flutter build apk --release
   ```
Al termine, il file pronto per l'installazione si troverà al percorso:
`build/app/outputs/flutter-apk/app-release.apk`

### Compilare per iOS (Senza macOS o dispositivi Apple tramite Codemagic)
Per creare l'app per iPhone/iPad è solitamente necessario un computer Mac con Xcode. Se utilizzi Windows, puoi aggirare questa limitazione usando [Codemagic](https://codemagic.io), un servizio Cloud CI/CD che compila il codice per te su server macOS remoti.

> [!TIP]
> **Nessun dispositivo Apple richiesto:** Non hai bisogno di possedere un Mac o un iPhone per effettuare la build su Codemagic. Puoi compilare il progetto nel cloud e inviare direttamente il pacchetto al tuo amico per farglielo installare sul suo dispositivo.

Ecco i passi da seguire da zero:

1. **Prepara il Codice (GitHub):** 
   - Carica l'intera cartella di questo progetto su un tuo repository (pubblico o privato) su GitHub o GitLab.
2. **Configura Codemagic:**
   - Vai su [codemagic.io](https://codemagic.io) e accedi col tuo account GitHub.
   - Clicca su **"Add application"** (Aggiungi applicazione) e seleziona il tuo repository di CAlcool.
   - Scegli **Flutter App** come tipo di progetto.
3. **Impostazioni di Build:**
   - Nella sezione *Build for platforms*, deseleziona Android e web, lasciando la spunta solo su **iOS**.
   - Nella sezione *Build arguments*, assicurati che sia selezionata la modalità **Release**.
4. **Firma dell'App (Code Signing):**
   - *Nota bene:* Per installare fisicamente l'app su un iPhone reale, Apple richiede un account Sviluppatore. Se non lo hai e vuoi solo testarla sul simulatore di Xcode su un Mac di un amico, seleziona "Simulator" come target per farti generare un pacchetto **.zip** (o **.app**).
   - Se possiedi un account Apple Developer (anche di un amico), carica i certificati di *Provisioning Profile* nella sezione *Distribution* -> *iOS code signing* per generare un file **.ipa** installabile.
5. **Avvia la Compilazione:**
   - Salva le impostazioni cliccando **"Save changes"**.
   - Clicca sul pulsante in alto a destra **"Start new build"**.
6. **Scarica il Risultato:**
   - Codemagic impiegherà alcuni minuti per noleggiare un Mac virtuale e compilare il tuo codice.
   - Al termine, troverai il file `.ipa` (o il file `.zip` della build) nella sezione *Artifacts* sulla sinistra, pronto per essere scaricato!

---

> **DISCLAIMER MEDICO:** *Questa app fornisce stime matematiche basate su formule standard. Non ha alcuna valenza medico-legale e non sostituisce un etilometro reale. Non guidare mai dopo aver bevuto.*
