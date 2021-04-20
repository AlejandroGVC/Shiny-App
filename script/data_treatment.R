# MAPA Y PLOTLY ----

# carga datos pib por provincia ----

datos_pib_prov <- read_excel("dat/Tabla_1-Tabla 1.xlsx") %>% 
  select('Comunidad Autónoma', 'Valor...47') %>% 
  rename('CCAA' = 'Comunidad Autónoma', 'pib' = 'Valor...47') %>% 
  mutate(CCAA = tolower(CCAA)) %>% 
  separate(CCAA, paste0("CCAA",1:2), sep=',') %>% 
  select(CCAA1, pib) %>% 
  separate(CCAA1, paste0("CCAA1",1:2), sep='/') %>% 
  select(CCAA11, pib) %>% 
  rename(name = CCAA11)

lista <- c('araba', 'balears', 'girona', 'lleida', 'ourense')
lista_c <- c('álava', 'baleares', 'gerona', 'lérida', 'orense')
indice <- matrix(NA, ncol = length(lista))
n <- length(lista)
for (i in 1:n){
  indice[i] <- which(datos_pib_prov == lista[i])
  datos_pib_prov$name[indice[i]] <-  lista_c[i]
}

  
# carga datos mapa ----

mapdata <- get_data_from_map(download_map_data("countries/es/es-all"))

ccaa <- as.data.frame(cbind(mapdata$`hc-a2`, mapdata$name)) %>% 
  mutate(V2 = tolower(V2)) %>% 
  rename(code = V1) %>% 
  rename(name = V2)
ccaa$name <- str_remove(ccaa$name, 'la ')
ccaa$name <- str_remove(ccaa$name, 'las ')
  

# merge de mapa con datos pib ----

data_hcmap_ggplot <- merge(datos_pib_prov, ccaa, by = 'name')

# GRAFICO PREDICCIONES Y TABLA ----

# carga datos  ---- 

datos_prov <- read_excel("dat/Tabla_1-Tabla 1.xlsx") %>%
  select('Comunidad Autónoma', starts_with('Valor...')) %>%
  column_to_rownames(var = 'Comunidad Autónoma')
colnames(datos_prov) <- 2000:2019

