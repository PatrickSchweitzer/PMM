# Antwort: Welche Inhalte der 3. Klasse (KM5 + KM6) lassen sich mit R effizienter lösen?

Kurzfassung: R bringt im III. Jahrgang **überall dort** einen echten Gewinn,
wo es viele Werte, keine geschlossene Handformel, Wiederholung (Simulation)
oder eine Grafik braucht. Es ersetzt aber **nicht** das Verständnis der
Begriffe und **nicht** die Entscheidung, welches Modell oder welcher Test
überhaupt passt.

---

## 1. Wahrscheinlichkeitsverteilungen — diskret (Binomial, Hypergeometrisch, Poisson)

| Inhalt | klassisch (Hand/TR/Tabelle) | R-Lösung | Effizienzgewinn | Grenze |
|---|---|---|---|---|
| Binomial `P(X = k)` | Formel n über k · p^k · (1−p)^(n−k), n über k aus dem Pascalschen Dreieck/TR | `dbinom(k, size = n, prob = p)` | sehr hoch: ein Aufruf statt Fakultäten-Chaos, auch bei großem n | — |
| Binomial kumuliert `P(X ≤ k)` | Summe vieler Einzelterme **oder** Binomialtabelle (nur ausgewählte n) | `pbinom(k, size = n, prob = p)` | sehr hoch: exakt, beliebiges n, keine Tabelle | — |
| Binomial-Quantil | Tabelle ablesen, interpolieren | `qbinom(0.95, size = n, prob = p)` | sehr hoch: kein Nachschlagen/Interpolieren | — |
| Hypergeometrisch (Ziehen ohne Zurücklegen) | lange Formel mit drei Binomialkoeffizienten | `dhyper(x, m, n, k)`, `phyper()`, `qhyper()` | hoch: weniger Rechen-/Tippfehler | — |
| Poisson (seltene Ereignisse) | Formel e^−λ·λ^k / k!, e^−λ aufwändig | `dpois(k, lambda)`, `ppois()` | hoch | — |
| „Was wäre wenn" (andere p, anderes n) | jede Variante neu rechnen | Parameter ändern, neu aufrufen | **sehr hoch**: Sekunden statt Minuten | — |

```r
# Binomial: 20 % Ausschuss, 5 Teile geprüft -> P(genau 2 defekt)
dbinom(2, size = 5, prob = 0.2)      # 0.2048
pbinom(2, size = 5, prob = 0.2)      # P(X <= 2)
qbinom(0.95, size = 5, prob = 0.2)   # 95 %-Quantil

# Hypergeometrisch: Los mit 50 Teilen, 5 davon defekt, Stichprobe 5
dhyper(2, m = 5, n = 45, k = 5)

# Poisson: im Mittel 2 Fehler pro laufendem Meter, P(genau 3)
dpois(3, lambda = 2)
```

---

## 2. Wahrscheinlichkeitsverteilungen — stetig (Normal, Exponential)

| Inhalt | klassisch (Hand/TR/Tabelle) | R-Lösung | Effizienzgewinn | Grenze |
|---|---|---|---|---|
| Normal, `P(X ≤ x)` | erst z = (x−μ)/σ, dann Standardnormal**tabelle** | `pnorm(x, mean, sd)` | sehr hoch: direkter Aufruf, kein Tafel-Lesen/Interpolieren | — |
| Normal, Fläche zwischen zwei Grenzen | zwei Tabellenwerte subtrahieren | `pnorm(b) - pnorm(a)` | hoch | — |
| Anteil außerhalb der Toleranz | beide Ränder getrennt | `pnorm(usl, ..., lower.tail = FALSE)` | hoch | — |
| **Quantil / Grenze** (z. B. z = 1,96) | Tabelle rückwärts suchen | `qnorm(0.975)` | sehr hoch: exakter Wert statt Näherung | — |
| z-Transformation **verstehen** | von Hand üben | R rechnet, zeigt Zwischenwerte | gering | **Ersetzt das Verständnis nicht** |
| Exponential, Ausfallanteil | e^−λt von Hand | `pexp(t, rate)` | hoch | — |

```r
# Füllmenge ~ N(500, 10): P(X <= 475)
pnorm(475, mean = 500, sd = 10)

# z-Wert für 95 % zweiseitig
qnorm(0.975)                          # 1.959964

# Ist-Zustand: Anteil außerhalb 10 +/- 0,15 mm bei sigma = 0,05
pnorm(9.85, 10, 0.05) + pnorm(10.15, 10, 0.05, lower.tail = FALSE)

# Exponential: MTTF = 500 h -> P(Ausfall bis 1000 h)
pexp(1000, rate = 1/500)
```

---

## 3. Lage- und Streumaße

| Inhalt | klassisch (Hand/TR/Tabelle) | R-Lösung | Effizienzgewinn | Grenze |
|---|---|---|---|---|
| Mittelwert, Median | alle Werte aufsummieren / sortieren | `mean(x)`, `median(x)` | hoch: fehlertolerant, sofort für große Daten | — |
| Varianz, Standardabweichung | Abweichungen quadrieren, summieren, Wurzel | `var(x)`, `sd(x)` | hoch | — |
| Quantile, IQR, Spannweite | Daten sortieren, Position rechnen | `quantile(x)`, `IQR(x)`, `range(x)` | hoch | — |
| Lage-/Streumaße mehrerer Gruppen | für jede Gruppe einzeln rechnen | `group_by()` + `summarise()` | **sehr hoch** bei vielen Gruppen | Gruppendefinition sauber wählen |

```r
x <- c(9.98, 10.02, 9.96, 10.04, 10.00, 9.99, 10.03, 9.97)

mean(x); median(x)
sd(x); var(x)                 # sd hat dieselbe Einheit wie x
IQR(x); quantile(x, c(0.25, 0.75))
diff(range(x))                # Spannweite
```

---

## 4. Parameter vs. Schätzwerte, Bessel-Korrektur (n−1), Gesetz der großen Zahlen

| Inhalt | klassisch (Hand/TR/Tabelle) | R-Lösung | Effizienzgewinn | Grenze |
|---|---|---|---|---|
| n vs. n−1 bei der Varianz zeigen | Formel umstellen | `var(x)` mit `mean((x-mean(x))^2)` vergleichen | hoch | – |
| Erwartungstreue / Bessel **erleben** | über eine Stichprobe nicht sichtbar | viele Stichproben ziehen (`replicate`) | **sehr hoch**: Effekt wird erst durch Wiederholung sichtbar | — |
| Gesetz der großen Zahlen | theoretisch erklärt, 1 Stichprobe | `replicate(1000, mean(rnorm(...)))` | **sehr hoch**: empirisch statt Glaubenssatz | — |
| Standardfehler | σ/√n rechnen | `sd(mittel)` über viele Stichproben | hoch | Schätzung streut selbst |

```r
set.seed(42)
x <- c(2, 4, 4, 5, 5, 7, 9)

var(x)                                # teilt durch n-1 (Bessel)
mean((x - mean(x))^2)                 # teilt durch n
var(x) * (length(x) - 1) / length(x)  # entspricht der n-Version

# Gesetz der großen Zahlen + Verteilung des Mittelwerts
mittel <- replicate(1000, mean(rnorm(30, mean = 100, sd = 15)))
mean(mittel)                          # ~ 100
sd(mittel)                            # ~ 15/sqrt(30) = Standardfehler
```

> Merke: Die **Bessel-Korrektur** und das **Gesetz der großen Zahlen** sind
> von Hand kaum „sichtbar". Genau hier ist R nicht nur schneller, sondern
> **ermöglicht den Lerneffekt erst**.

---

## 5. Standardfehler & Konfidenzintervall für μ (bekanntes σ)

| Inhalt | klassisch (Hand/TR/Tabelle) | R-Lösung | Effizienzgewinn | Grenze |
|---|---|---|---|---|
| SE = σ/√n | Wurzel/Division von Hand | `sigma/sqrt(n)` | mittel | Konzept bleibt wichtig |
| KI: x̄ ± z·SE | z = 1,96 aus der Übersicht | `qnorm(0.975)` | hoch: exakter z statt Merkzahl | — |
| Ein bisschen anderen Stichprobenumfang testen | neue Rechnung | n ändern, neu rechnen | hoch | — |

```r
n <- 40; xbar <- 10.01; sigma <- 0.05
z <- qnorm(0.975)                      # 1.959964
c(unter = xbar - z * sigma / sqrt(n),
  ober  = xbar + z * sigma / sqrt(n))
```

---

## 6. t-Verteilung & Konfidenzintervall für μ (unbekanntes σ)

| Inhalt | klassisch (Hand/TR/Tabelle) | R-Lösung | Effizienzgewinn | Grenze |
|---|---|---|---|---|
| t-Quantil zu df | t-Tabelle ablesen | `qt(0.975, df)` | hoch: beliebiges df, exakt | — |
| KI bei unbekanntem σ | x̄ ± t·s/√n, s von Hand | `t.test(x)$conf.int` | **sehr hoch**: ganzes KI in einem Aufruf | Testausgabe kritisch lesen |
| Ein- vs. zweiseitig | Tabelle je nach Fall | `alternative = "less"/"greater"/"two.sided"` | hoch | Richtung muss man wählen |

```r
x <- c(9.98, 10.02, 9.96, 10.04, 10.00, 9.99, 10.03, 9.97)

t.test(x)$conf.int                     # KI für den Mittelwert
qt(0.975, df = length(x) - 1)          # t-Quantil für die Handformel
```

---

## 7. χ²-Verteilung & Konfidenzintervall für σ²

| Inhalt | klassisch (Hand/TR/Tabelle) | R-Lösung | Effizienzgewinn | Grenze |
|---|---|---|---|---|
| χ²-Quantile zu df | χ²-Tabelle (meist nur Prozentpunkte) | `qchisq(0.975, df)` | hoch: exakte, beliebige Quantile | — |
| KI für σ² | (n−1)·s²/χ²-Grenzen | zwei `qchisq()`-Werte einsetzen | hoch | — |
| KI für σ (Wurzel) | zusätzlich Wurzel ziehen | `sqrt()` auf die Grenzen | mittel | — |

```r
x  <- c(9.98, 10.02, 9.96, 10.04, 10.00, 9.99, 10.03, 9.97)
n  <- length(x); s2 <- var(x)

c(unter = (n - 1) * s2 / qchisq(0.975, df = n - 1),
  ober  = (n - 1) * s2 / qchisq(0.025, df = n - 1))
```

---

## 8. Prüfergebnisse auswerten und darstellen (Histogramm, Boxplot, QQ-Plot)

| Inhalt | klassisch (Hand/TR/Tabelle) | R-Lösung | Effizienzgewinn | Grenze |
|---|---|---|---|---|
| Histogramm | Klassen von Hand bilden, zeichnen | `ggplot(aes(x)) + geom_histogram()` | **sehr hoch**: Sekunden statt Zeichenarbeit | Klassenzahl wählen |
| Boxplot | Fünf-Zahlen-Zusammenfassung + Zeichnung | `geom_boxplot()` | **sehr hoch** | Ausreißerregel kennen |
| QQ-Plot (Normalität prüfen) | praktisch nicht von Hand | `stat_qq() + stat_qq_line()` | **sehr hoch**: Visuell statt Rechnen | Urteil bleibt subjektiv |
| Streudiagramm | unmöglich von Hand | `geom_point()`, `geom_smooth()` | **sehr hoch** | Korrelation ≠ Kausalität |
| Wiederholbarer Prüfbericht | jedes Mal neu | Skript + `Quarto`/R Markdown | hoch | — |

```r
library(tidyverse)

ggplot(daten, aes(x = masse_mm)) +
  geom_histogram(binwidth = 0.02, colour = "white")

ggplot(daten, aes(x = "", y = masse_mm)) +
  geom_boxplot()

ggplot(daten, aes(sample = masse_mm)) +
  stat_qq() + stat_qq_line()      # Punkte nahe der Linie -> normal
```

---

## 9. Kennzahlen und Ausreißer (IQR, 1,5·IQR-Regel, Schiefe/Wölbung)

| Inhalt | klassisch (Hand/TR/Tabelle) | R-Lösung | Effizienzgewinn | Grenze |
|---|---|---|---|---|
| Quartile & IQR | Daten sortieren, Position rechnen | `quantile()`, `IQR()` | hoch | — |
| Ausreißer finden | jeden Wert mit den Grenzen vergleichen | `boxplot.stats(x)$out`, Vektor-Filter | **sehr hoch**: automatisch für alle Werte | Ausreißer ≠ Fehler |
| Schiefe / Wölbung | sehr lange Formeln | `e1071::skewness()`, `e1071::kurtosis()` | hoch | Paket muss klar sein |

```r
x <- c(9.90, 10.00, 10.10, 9.95, 10.05, 12.50)   # 12,50 fällt auf

q  <- quantile(x, c(0.25, 0.75)); iqr <- IQR(x)
gr <- q + c(-1.5, 1.5) * iqr
x[x < gr[1] | x > gr[2]]        # Ausreißer per 1,5-IQR-Regel
boxplot.stats(x)$out            # dasselbe über die Boxplot-Statistik
```

---

## 10. Lebensdauerverteilungen (Exponential, Weibull, Badewannenkurve, MTBF)

| Inhalt | klassisch (Hand/TR/Tabelle) | R-Lösung | Effizienzgewinn | Grenze |
|---|---|---|---|---|
| Exponential, R(t) | e^−λt von Hand | `pexp(t, rate)`, `1 - pexp()` | hoch | Konstante Ausfallrate annehmen |
| Weibull, P(Ausfall ≤ t) | Formel mit e^−(t/η)^β — unpraktisch | `pweibull(t, shape, scale)` | **sehr hoch** | — |
| Weibull-Parameter aus Daten (β, η) | **Weibull-Papier**, grafisch, ungenau | `fitdistrplus::fitdist(x, "weibull")` (Maximum-Likelihood) | **sehr hoch**: objektiv, exakt statt „nach Augenmaß" | Modellgüte prüfen |
| 63,2 %-Quantil = Skalenparameter η | Papier ablesen | `qweibull(0.632, shape, scale)` | hoch | — |
| Badewannenkurve / Ausfallrate λ(t) | drei Phasen von Hand skizzieren | Weibull mit verschiedenen β simulieren | hoch | Interpretation bleibt fachlich |
| MTBF/MTTF schätzen | Mittelwerte von Hand | `mean(ausfallzeiten)` bzw. Weibull-Fit | hoch | Zensierung beachten (höher, V. Jg.) |

```r
# Exponential: MTTF = 500 h, P(Ausfall bis 1000 h) und Überlebensfunktion
pexp(1000, rate = 1/500)
1 - pexp(1000, rate = 1/500)

# Weibull: 63,2 %-Quantil ist der Skalenparameter eta
qweibull(0.632, shape = 1.5, scale = 500)

# Parameter aus echten Ausfalldaten schätzen (statt Weibull-Papier)
library(fitdistrplus)
fit <- fitdist(ausfallzeiten, "weibull")
fit$estimate          # shape (beta, Form), scale (eta, Lage)
plot(fit)
```

---

## Top-3: Wo der R-Nutzen am größten ist

1. **Lebensdauerverteilungen / Weibull-Fit (KM6).** Von Hand braucht man das
   **Weibull-Papier** und liest β und η grafisch ab — ungenau und langsam.
   `fitdistrplus::fitdist()` schätzt per Maximum-Likelihood in einer Zeile,
   liefert Gütekennzahlen und diagnostische Plots. Hier gewinnt R am
   deutlichsten.
2. **Verteilungen und Quantile (KM5/KM6).** Die `d/p/q/r`-Familie ersetzt das
   **gesamte Tabellen-Handbuch** (Binomial-, Normal-, t-, χ²-Tabelle):
   exakt, für jedes n, für jedes Quantil. Besonders schlagend bei großem n,
   wo Handrechnung schlicht nicht mehr praktikabel ist.
3. **Darstellung und Ausreißererkennung (KM6).** Histogramm, Boxplot, QQ-Plot
   und die 1,5·IQR-Regel sind von Hand kaum zu zeichnen bzw. mühsam; in
   `ggplot2` sind sie in Sekunden da — und sofort für einen ganzen Datensatz.

Dazu kommt als Querschnittnutzen die **Reproduzierbarkeit**: Ein R-Skript
liefert dieselbe Zahl immer wieder, während jede Handrechnung ein neuer
Fehlervektor ist.

---

## Wo R nicht hilft (und die Handrechnung sinnvoll bleibt)

- **Begriffe verstehen:** Was ein Konfidenzintervall *bedeutet* (und was nicht),
  was ein Parameter im Unterschied zu einem Schätzwert ist, warum der
  Standardfehler mit √n kleiner wird — das leistet kein `qnorm()`.
  Die z-Transformation bzw. die KI-Formel sollte man einmal von Hand gebaut
  haben, sonst ist die R-Ausgabe eine Blackbox.
- **Modellwahl und Interpretation:** Ob Normalverteilung, Binomial oder Weibull
  passt, welcher Test zur Frage gehört, welches Signifikanzniveau sinnvoll ist
  — das ist Urteilsvermögen, keine Rechnung.
- **Einmalige Überschlagsrechnung:** Der Mittelwert von fünf Zahlen ist von Hand
  schneller als jede Skript-Datei. R lohnt ab vielen Werten oder Wiederholung.
- **Datenqualität:** R rechnet auch mit falschen Daten korrekt — *garbage in,
  garbage out*. Fehlende Werte (`NA`), Ausreißer und Erhebung müssen
  menschlich geprüft werden.
- **Grafik lesen:** Ein QQ-Plot sagt nicht automatisch „normal / nicht normal";
  die Entscheidung bleibt bei der Person.

---

## Fazit

Für den III. Jahrgang gilt: R ist **kein Ersatz für das statistische Denken,
aber ein Verstärker für alles Rechnerische und Visuelle**. Den größten
Effizienzsprung gibt es dort, wo man von Hand sonst Tabellen wälzt, Papier
zeichnet oder gar nicht rechnen kann (Quantile, Simulation, Weibull-Fit,
große Stichproben). Am wenigsten bringt R beim **Aufbau des Begriffs-
verständnisses** — dort bleibt die Handrechnung (und die eine Skizze auf
Papier) weiterhin die beste Reihenfolge: **erst verstehen, dann in R
automatisieren.**
