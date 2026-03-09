# Título: Práctica 3
# Módulo: Análisis Exploratorio de Datos Espaciales
# Autor: Mauricio Tabares
# Fecha: 2025-04-09

# Desarrollo Práctica # 3 -------------------------------------------------

# Instalar y cargar librerías ---------------------------------------------
install.packages(c("pacman", "tidyverse", "janitor", "sf"))
library(pacman)
p_load(tidyverse, janitor, DataExplorer,ggplot2,plotly,sf)

# Importar los datos alfanuméricos ----------------------------------------
df <- read.csv("data/2019_paro_registrado_16_64.csv", sep = ",", encoding = "utf8")
class(df) # Clase del objeto
dim(df) # Dimensiones del objeto, filas y columnas
View(df) # Ver el df

# Limpiar y preparar los datos: -------------------------------------------

# Estructura de los datos
str(df) # Estructura del df
glimpse(df) # Estructura del df

# 1-Corregir los nombres de las variables o columnas ------------------------
df_clean <- clean_names(df)
glimpse(df_clean) # Estructura del df
View(df_clean)

# Identificación de valores NA con DataExplorer
profile_missing(df_clean) # Tabla de datos
plot_missing(df_clean) # Gráfico de datos

# Eliminar filas o columnas que estén completamente vacías
df_clean <- remove_empty(df_clean, which = c("rows","cols"), quiet = FALSE) # Eliminar
dim(df_clean) # Dimensiones del objeto, filas y columnas

# Procesamiento: agrupar y extraer datos ----------------------------------

# Agrupar por codigo_barrio y obtener el máximo de peso_paro
df_clean_paro <- df_clean %>%
  group_by(codigo_barrio,pop_16_a_64,suma_paro) %>%
  summarise(max_peso_paro = max(peso_paro, na.rm = TRUE))
View(df_clean_paro)

# Exportar resultados y validar CSV ---------------------------------------

# Guardar el archivo
write.csv(df_clean_paro, file = "result/df_clean_paro.csv", row.names = FALSE)

# Cargar el archivo y validar
df_resultado <- read.csv("result/df_clean_paro.csv", sep = ",", encoding = "utf8")
class(df_resultado)
View(df_resultado)

# Importar los datos GeoJSON ----------------------------------------------

# Cargar los datos y convertir a un dataframe plano (sin geometría de punto)
df_geojson <- st_read("data/activ_econ_activas.geojson") %>%
  st_drop_geometry()
class(df_geojson)
dim(df_geojson)
glimpse(df_geojson)
View(df_geojson)

# Agrupar y contar las ocurrencias [Por Código]

# df_geojson_count <- df_geojson %>%
#   group_by(Codi_Barri, Codi_Grup_Activitat) %>%
#   summarise(conteo = n(), .groups = 'drop') %>%
#   pivot_wider(names_from = Codi_Grup_Activitat, values_from = conteo, values_fill = list(conteo = 0))
# glimpse(df_geojson_count)

# Agrupar y contar las ocurrencias [Por Categoría]

df_geojson_count <- df_geojson %>%
  group_by(Codi_Barri, Nom_Grup_Activitat) %>%
  summarise(conteo = n(), .groups = 'drop') %>%
  pivot_wider(names_from = Nom_Grup_Activitat, values_from = conteo, values_fill = list(conteo = 0))

# Corregir los nombres de las variables o columnas ------------------------
df_geojson_clean <- clean_names(df_geojson_count)
df_geojson_clean$codi_barri <- as.integer(df_geojson_clean$codi_barri) # Convertir código a entero
glimpse(df_geojson_clean) # Estructura del df
View(df_geojson_clean)

# Guardar el archivo
write.csv(df_geojson_clean, file = "result/df_clean_activ_econ.csv", row.names = FALSE)

# Cargar el archivo y validar
df_resultado2 <- read.csv("result/df_clean_activ_econ.csv", sep = ",", encoding = "utf8")
class(df_resultado2)
View(df_resultado2)

# Guardar los objetos de la sesión R --------------------------------------
save.image(file=".RData")
