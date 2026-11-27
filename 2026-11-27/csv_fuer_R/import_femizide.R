# ============================================================
#  Femizide in Österreich 2016–2020
#  CSV-Import für R / RStudio
#  Quelle: IKF-Studie 2023 (Haller/Eberhardt/Temel)
# ============================================================
#
#  In RStudio:  Session > Set Working Directory > To Source File Location
#  (Der Ordner "csv_fuer_R" muss im selben Ordner wie dieses Skript liegen.)
# ------------------------------------------------------------

# --- Pakete -------------------------------------------------
# Falls nicht installiert:
# install.packages(c("readr", "dplyr", "ggplot2"))

library(readr)
library(dplyr)

ordner <- "csv_fuer_R"

# --- Gesamttabelle (long/tidy) ------------------------------
daten <- read_csv(
  file.path(ordner, "06_alle_daten.csv"),
  locale = locale(encoding = "UTF-8"),
  show_col_types = FALSE
)

print(daten)
table(daten$bereich)

# --- Einzelne Tabellen --------------------------------------
staatsbuergerschaft <- read_csv(
  file.path(ordner, "01_staatsbuergerschaft.csv"),
  show_col_types = FALSE
)

alter <- read_csv(
  file.path(ordner, "02_alter.csv"),
  show_col_types = FALSE
)

beziehung_tat <- read_csv(
  file.path(ordner, "03_beziehung_tat.csv"),
  show_col_types = FALSE
)

motive_risiko <- read_csv(
  file.path(ordner, "04_motive_risiko.csv"),
  show_col_types = FALSE
)

herkunft <- read_csv(
  file.path(ordner, "05_herkunftslaender.csv"),
  show_col_types = FALSE
)

# --- Beispiel: Staatsbürgerschaft der Femizid-Opfer ---------
opfer_staaten <- staatsbuergerschaft |>
  filter(
    population == "Femizid-Opfer (n=100)",
    kategorie != "Gesamt"
  )

print(opfer_staaten)

# Einfaches Balkendiagramm (Basis-R, ohne ggplot2)
bp <- barplot(
  opfer_staaten$haeufigkeit,
  names.arg = opfer_staaten$kategorie,
  las = 2,
  col = "#8B1E3F",
  main = "Staatsbürgerschaft der Femizid-Opfer (2016–2020)",
  ylab = "Anzahl"
)

text(
  bp,
  opfer_staaten$haeufigkeit,
  labels = paste0(opfer_staaten$haeufigkeit, " (", opfer_staaten$prozent, " %)"),
  pos = 3,
  cex = 0.8
)

# --- Beispiel: Altersverteilung -----------------------------
opfer_alter <- alter |>
  filter(
    population == "Femizid-Opfer (n=100)",
    altersgruppe != "Gesamt",
    altersgruppe != "k.A."
  )

barplot(
  opfer_alter$prozent,
  names.arg = opfer_alter$altersgruppe,
  las = 2,
  col = "#2F5597",
  main = "Alter der Femizid-Opfer (n=100)",
  ylab = "Prozent"
)

# --- Beispiel: Täter nach Staatsbürgerschaft ----------------
taeter_staaten <- staatsbuergerschaft |>
  filter(
    population == "Femizid-Täter (n=93)",
    kategorie != "Gesamt"
  )

print(taeter_staaten)
