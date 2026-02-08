/*
    ============================================================================
    PROJECT: Legacy ERP Data Migration - Discovery & Extraction Phase
    AUTHOR: Marco Foca Carchedi
    CONTEXT: Migrazione Dati verso nuovo ERP
    DESCRIPTION: 
        Questo script documenta il processo di Reverse Engineering eseguito su
        un database legacy (SQL Server) privo di documentazione tecnica.
        
        Obiettivo: Identificare la tabella corretta contenente lo storico costi,
        comprendere la struttura del magazzino e estrarre l'ultimo costo imponibile
        per la valorizzazione dello stock nel nuovo sistema.
    ============================================================================
*/

-- 1. INDAGINE SULLE TABELLE "PESANTI" (VOLUME DATI)
-- Obiettivo: Trovare le tabelle transazionali principali (Movimenti o Anagrafiche estese)
-- Tecnica: Interrogazione delle DMV (Dynamic Management Views) per evitare count(*) lenti
SELECT TOP 20
    t.name AS NomeTabella,
    SUM(p.rows) AS NumeroRighe
FROM 
    sys.tables t
INNER JOIN 
    sys.partitions p ON t.object_id = p.object_id
WHERE 
    p.index_id < 2 -- Consideriamo solo Heap o Clustered Index
GROUP BY 
    t.name
ORDER BY 
    NumeroRighe DESC;

-- 2. RICERCA MIRATA TRAMITE METADATI
-- Obiettivo: Localizzare colonne contenenti informazioni finanziarie ("Costo", "Imponibile")
-- Tecnica: Scansione di sys.columns per pattern matching
SELECT 
    t.name AS Tabella,
    c.name AS Colonna
FROM 
    sys.tables t
INNER JOIN 
    sys.columns c ON t.object_id = c.object_id
WHERE 
    c.name LIKE '%costo%' 
    OR c.name LIKE '%imponibile%'
ORDER BY 
    Tabella;

-- 3. ANALISI STRUTTURALE DELLA TABELLA TARGET
-- Una volta individuata la tabella 'mag_mat_costi', ne esploriamo lo schema
SELECT name AS NomeColonna
FROM sys.columns 
WHERE object_id = OBJECT_ID('mag_mat_costi');

-- 4. DATA PROFILING E DISTRIBUZIONE MAGAZZINI
-- Obiettivo: Capire la cardinalità dei dati e verificare la presenza di magazzini logici/fisici
SELECT 
    MTC_IDMAG AS [Codice Magazzino], 
    COUNT(*) AS [Numero Righe]
FROM 
    mag_mat_costi
GROUP BY 
    MTC_IDMAG
ORDER BY 
    MTC_IDMAG;

-- 5. ESTRAZIONE FINALE PER STAGING AREA
-- Obiettivo: Generare dataset per Excel/Importazione ERP
-- Filtri applicati: Magazzino 12 (Target Migrazione) e pulizia costi a zero
SELECT 
    MTC_IDMAG AS [Magazzino],
    MTC_IDMAT AS [ID Articolo], 
    -- Formattazione locale italiana per compatibilità diretta con Excel
    FORMAT(MTC_COU_IMPON, 'N4', 'it-IT') AS [Ultimo Costo Imponibile (€)], 
    FORMAT(MTC_COU_IVATO, 'N4', 'it-IT') AS [Ultimo Costo Ivato (€)], 
    CONVERT(VARCHAR(10), MTC_COU_DATA, 103) AS [Data Registrazione]
FROM 
    mag_mat_costi
WHERE 
    MTC_COU_IMPON > 0 
    AND MTC_IDMAG = 12
ORDER BY 
    MTC_COU_DATA DESC;
