library(readxl)
data <- read_excel("data\\personendaten.xlsx")
write.csv2(data, "data/personendaten.csv", row.names = FALSE)
