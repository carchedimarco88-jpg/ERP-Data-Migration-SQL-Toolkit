# ERP-Data-Migration-SQL-Toolkit
SQL &amp; R Toolkit for ERP Migration. Automazione del data cleaning, mappatura anagrafiche e recupero info su costi (Reverse Engineering) su database non documentati.

# Legacy ERP Migration: SQL Reverse Engineering Toolkit

**Author:** Marco Foca Carchedi  
**Tech Stack:** T-SQL (SQL Server), SSMS, Excel

## Project Overview
Durante un progetto di migrazione dati verso un nuovo sistema ERP aziendale, mi sono trovato a gestire un database legacy privo di documentazione tecnica (Data Dictionary assente).
La sfida critica era identificare, validare ed estrarre i dati relativi all'**"Ultimo Costo Imponibile"** per migliaia di referenze, dato fondamentale per la corretta valorizzazione fiscale del magazzino nel nuovo sistema.

## The Challenge
* **Mancanza di documentazione:** Nomi tabelle e colonne criptici (es. `MTC_COU_IMPON`).
* **Rischio Finanziario:** Un errore nell'estrazione del costo avrebbe comportato perdite economiche o errori di bilancio.
* **Volume Dati:** Necessità di filtrare solo i magazzini attivi e i costi validi.

## The Solution (My Approach)
Ho creato un approccio strutturato di **Reverse Engineering** basato sui metadati di SQL Server, invece di procedere per tentativi. Questo repository contiene lo script `SQL_Reverse_Engineering_Log.sql` che documenta i 5 step del processo:

1.  **Volume Analysis:** Utilizzo delle `sys.tables` e `sys.partitions` per identificare le tabelle "fact" (quelle con più righe) ignorando le tabelle di configurazione vuote.
2.  **Metadata Search:** Scansione delle `sys.columns` per trovare keyword finanziarie ("Costo", "Imponibile") all'interno dell'intero schema.
3.  **Schema Inspection:** Analisi specifica della tabella target individuata (`mag_mat_costi`).
4.  **Data Profiling:** Aggregazione per `MagazzinoID` per comprendere la distribuzione fisica dei dati.
5.  **Final Extraction:** Creazione della query di estrazione con formattazione locale (`FORMAT`, `it-IT`) pronta per la validazione in Excel da parte del controllo di gestione.

## Key Results
* Identificazione corretta della tabella costi in < 30 minuti.
* Estrazione e bonifica di un dataset pronto per l'importazione nel nuovo ERP.
* Validazione del 100% dei costi critici prima del Go-Live.
