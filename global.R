library(sf)
library(stringr)
library(tm)

# Load the data: the health NGOs table, the 14 senegalese regions, and the senegalese 
ong  = read.csv("data/ongs.csv", colClasses="character")
link = read.csv("data/link.csv", colClasses="character")
reg  = read_sf("data/regions_senegal.gpkg", quiet=TRUE)
sen  = read_sf("data/contour_senegal.gpkg", quiet=TRUE)

# In datatable presentation, ONG table colums must be named differently

# colnames(ong)
ongCols = c(
  "ID"="id",
  "Nom"="lib",
  "Régions d'implantation"="reg_lib",
  "Codes régions"="reg",
  "Nb. rég"="n_reg",
  "Domaines d'interv."="domaines",
  "Adresse du siège"="adresse_siege",
  "Responsable"="responsable",
  "N° d'agrément"="num_agrement"
)


# Extract the keywords of the ONG action domains 
suppressWarnings({
  v = ong$domaines %>%
    VectorSource() %>%
    Corpus() %>% 
    tm_map(removePunctuation) %>% 
    tm_map(removeWords, stopwords("french")) %>% 
    tm_map(stripWhitespace) %>% 
    TermDocumentMatrix() %>% 
    as.matrix() %>% 
    rowSums() %>% 
    sort(decreasing=TRUE)
})

df = data.frame(word=names(v), freq=v, stringsAsFactors=FALSE)
df = df[df$freq > 30, ]
keywords = df$word
names(keywords) = paste0(str_to_title(keywords), " (", df$freq,")")

# For text-mining methods, see
# http://www.sthda.com/french/wiki/text-mining-et-nuage-de-mots-avec-le-logiciel-r-5-etapes-simples-a-savoir
