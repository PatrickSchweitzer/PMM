# Femizide in Österreich 2016–2020 – CSV-Datensatz für R / RStudio

Quelle: Haller, Birgitt / Eberhardt, Viktoria / Temel, Brigitte (2023):
*Untersuchung Frauenmorde – eine quantitative und qualitative Analyse*.
Institut für Konfliktforschung, Wien. Beauftragt vom Bundeskanzleramt/Frauensektion,
BMI/Bundeskriminalamt und BMJ.

**Wichtig:** Es handelt sich um **aggregierte Daten** aus der Studie, nicht um
Einzelfalldaten. Die Studie veröffentlicht keine personenbezogene Liste mit
Staatsbürgerschaft und Alter pro Fall.

---

## Dateien

| Datei | Inhalt | Zeilen |
|---|---|---|
| `06_alle_daten.csv` | **Gesamttabelle (long/tidy)** – alle Daten, filterbar nach `bereich` | 150 |
| `01_staatsbuergerschaft.csv` | Staatsbürgerschaft von Opfern und Täter:innen | 36 |
| `02_alter.csv` | Altersverteilung inkl. Vergleichsbevölkerung | 36 |
| `03_beziehung_tat.csv` | Beziehung, Tatort, Gewalthandlung/Tatwaffe | 36 |
| `04_motive_risiko.csv` | Tatmotive, Hochrisikofaktoren, Gewaltgeschichte | 42 |
| `05_herkunftslaender.csv` | Länderdetails | 46 |
| `00_ueberblick.csv` | Metadaten der Studie (`feld`, `wert`) | 14 |
| `07_quellen.csv` | Quellen und Links | 6 |

**Für die meisten Auswertungen reicht `06_alle_daten.csv`.**

## Format

- Trennzeichen: **Komma**
- Dezimaltrennzeichen: **Punkt**
- Kodierung: **UTF-8** (ohne BOM)
- Erste Zeile: Spaltennamen (snake_case)
- Leere Felder = fehlende Angabe / nicht zutreffend

## Spalten in `06_alle_daten.csv`

| Spalte | Bedeutung |
|---|---|
| `bereich` | Staatsbürgerschaft, Alter, Opfer-Täter-Beziehung, Tatort, Gewalthandlung, Tatmotiv, Risikofaktor |
| `population` | Untersuchte Gruppe, z. B. `Femizid-Opfer (n=100)` |
| `kategorie` | Ausprägung, z. B. `Österreich`, `30–39`, `Würgen` |
| `haeufigkeit` | Anzahl (numerisch) |
| `prozent` | Anteil in Prozent (numerisch, Punkt als Dezimaltrennzeichen) |
| `quelle` | Tabellennummer in der Originalstudie |

---

## Import in RStudio

### Variante A: readr (empfohlen)

```r
library(readr)

daten <- read_csv(
  "csv_fuer_R/06_alle_daten.csv",
  locale = locale(encoding = "UTF-8"),
  show_col_types = FALSE
)

# Struktur ansehen
str(daten)
table(daten$bereich)
```

### Variante B: Base R

```r
daten <- read.csv(
  "csv_fuer_R/06_alle_daten.csv",
  encoding = "UTF-8",
  stringsAsFactors = FALSE
)
```

Falls die Umlaute nicht korrekt dargestellt werden:

```r
daten <- read.csv("csv_fuer_R/06_alle_daten.csv",
                  fileEncoding = "UTF-8",
                  stringsAsFactors = FALSE)
```

### Alle Dateien auf einmal einlesen

```r
library(readr)
library(purrr)

dateien <- list.files("csv_fuer_R", pattern = "\\.csv$", full.names = TRUE)

alle <- map(dateien, ~ read_csv(.x, show_col_types = FALSE))
names(alle) <- tools::file_path_sans_ext(basename(dateien))

# Zugriff z. B.:
alle$`01_staatsbuergerschaft`
```

---

## Kleines Beispiel

```r
library(readr)
library(ggplot2)

daten <- read_csv("csv_fuer_R/06_alle_daten.csv", show_col_types = FALSE)

# Staatsbürgerschaft der Femizid-Opfer
opfer <- daten |>
  filter(bereich == "Staatsbürgerschaft",
         population == "Femizid-Opfer (n=100)",
         kategorie != "Gesamt")

ggplot(opfer, aes(x = reorder(kategorie, haeufigkeit), y = haeufigkeit)) +
  geom_col(fill = "#8B1E3F") +
  coord_flip() +
  labs(title = "Staatsbürgerschaft der Femizid-Opfer (2016–2020)",
       x = NULL, y = "Anzahl") +
  theme_minimal()
```

---

## Zitierhinweis

Haller, B., Eberhardt, V. & Temel, B. (2023). *Untersuchung Frauenmorde –
eine quantitative und qualitative Analyse*. Wien: Institut für Konfliktforschung.

Original-PDF:
<https://www.bundeskanzleramt.gv.at/dam/jcr:39f7be99-11c8-4e8d-85c5-10e1a2e740f5/studie-untersuchung-frauenmorde-IKF-2023-nB.pdf>

Kurzfassung (SIAK-Journal 4/2023):
<https://www.bmi.gv.at/104/wissenschaft_und_forschung/siak-journal/siak-journal-ausgaben/jahrgang_2023/files/haller_4_2023.pdf>
