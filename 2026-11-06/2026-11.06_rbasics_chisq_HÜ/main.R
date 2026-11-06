library(readxl)
daten <- read_excel("data\\personendaten.xlsx")
write.csv2(data, "data/personendaten.csv", row.names = FALSE)
