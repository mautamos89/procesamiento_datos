# Título: Práctica 1
# Módulo: Análisis Exploratorio de Datos Espaciales
# Autor: Mauricio Tabares
# Fecha: 2025-03-27

# Desarrollo Práctica # 1 -------------------------------------------------

# Instalar y cargar librerías ---------------------------------------------
install.packages(c("pacman", "tidyverse", "janitor"))
library(pacman)
p_load(tidyverse, janitor, DataExplorer)

# Importar los datos ------------------------------------------------------
df <- read.csv("datos/bbdd_ejemplo.csv", sep = ",", encoding = "utf8")
class(df)
View(df)

# Limpiar y preparar los datos: -------------------------------------------

# Estructura de los datos
str(df)
summary(df)
glimpse(df)

# 1-Corregir los nombres de las variables o columnas ------------------------
df_clean <- clean_names(df)
View(df_clean)

# 2-Detectar y corregir la posible presencia de observaciones vacías --------

# Detectar vacíos (espacio en blanco "")
vacios <- sapply(df_clean, function(x) sum(x == ""))
print(vacios)

# Reemplazar vacíos por NA
df_clean[df_clean == ""] <- NA
View(df_clean)

# 3-Detectar y gestionar la presencia de valores NA -------------------------
# na.fail(df)

# Recuento de valores NA totales, por variable y por fila
sum(is.na(df_clean))
colSums(is.na(df_clean))
rowSums(is.na(df_clean))

# Identificación de valores NA con DataExplorer
profile_missing(df_clean)
plot_missing(df_clean)

# Eliminar filas que estén completamente vacías
df_clean <- remove_empty(df_clean, which = c("rows","cols"), quiet = FALSE)
dim(df_clean)

# Eliminar columna con el mayor registro de NA
df_clean <- df_clean %>%
  select(!estado_o_provincia) #%>% 
  # mutate(estado_o_provincia = replace_na(estado_o_provincia,"Valor desconocido"))
dim(df_clean)
View(df_clean)

# eliminar los valores NA con la función na.exclude()
df_clean <- na.exclude(df_clean)
dim(df_clean)
View(df_clean)

# Validar exclusión de valores NA
profile_missing(df_clean)
plot_missing(df_clean)

# 4-Detectar la presencia, y corregir, posibles errores tipográficos --------
df_clean <- df_clean %>%
  mutate(pais = recode(pais, 'Canada' = 'Canadá'))
View(df_clean)

# 5-Detectar posibles registros duplicados y gestionar su presencia -------

# Detectar duplicados
duplicados <- df_clean[duplicated(df_clean), ]
print(duplicados)
 
# Contar el número de duplicados
num_duplicados <- sum(duplicated(df_clean))
print(num_duplicados)

# Eliminar registros duplicados
df_clean <- df_clean %>%
  distinct()

# Validar limpieza de duplicados
num_duplicados <- sum(duplicated(df_clean))
print(num_duplicados)

# 6-Estandarizar o normalizar las cadenas de texto almacenadas en las variables (uso de mayúsculas y minúsculas)

# Capitalizar la primera letra de cada palabra
df_clean <- df_clean %>%
  mutate(across(where(is.character), ~ str_to_title(.)))
View(df_clean)

# 7-Separar los valores presentes en la variable [nacimiento], en tres nuevas columnas: [DIA], [MES] y [AÑO]
df_clean <- df_clean %>%
  separate(fecha_de_nacimiento, into = c("mes", "dia", "anno"), sep = "/", convert = TRUE)
View(df_clean)

# 8-Separar los valores presentes en la variable [VEHICULO] en dos nuevas columnas: [FECHA_VEHICULO] y [MODELO_VEHICULO]
df_clean <- df_clean %>%
  separate(vehiculo, into = c("fecha_vehiculo", "modelo_vehiculo"), sep = " ", extra = "merge", fill = "right")
View(df_clean)

# 9-Crear una nueva variable que almacene el índice de masa corporal de cada una de las personas de la base de datos.
df_clean <- mutate(df_clean, indice_masa_corporal = peso / ((talla/100)^2))
View(df_clean)

# 10-Crear una nueva variable ([IMC]) que clasifique cada observación en función de su valor de IMC, según la siguiente relación de valores:
  
# Menor de 18,5 = peso bajo; Entre 18,5 y 24,9 = peso normal;
# Entre 24,9 y 29,9 = sobrepeso; Igual o mayor de 30 = obesidad

df_clean <- df_clean %>% 
  mutate(IMC = case_when(
    indice_masa_corporal < 18.5 ~ "Peso bajo",
    indice_masa_corporal >= 18.5 & indice_masa_corporal < 24.9 ~ "Peso normal",
    indice_masa_corporal >= 24.9 & indice_masa_corporal < 29.9 ~ "Sobrepeso",
    indice_masa_corporal >= 30 ~ "Obesidad"))
View(df_clean)

# Exportar resultados y validar CSV ---------------------------------------

# Guardar el archivo
write.csv(df_clean, file = "resultados/df_clean.csv", row.names = FALSE)

# Cargar el archivo y validar
df_resultado <- read.csv("resultados/df_clean.csv", sep = ",", encoding = "utf8")
class(df_resultado)
View(df_resultado)

# Guardar los objetos de la sesión R --------------------------------------
save.image(file=".RData")

