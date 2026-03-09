# Título: Práctica 2
# Módulo: Análisis Exploratorio de Datos Espaciales
# Autor: Mauricio Tabares
# Fecha: 2025-03-30

# Desarrollo Práctica # 2 -------------------------------------------------

# Instalar y cargar librerías ---------------------------------------------
install.packages(c("pacman", "tidyverse", "janitor","htmlwidgets"))
library(pacman)
p_load(tidyverse, janitor, DataExplorer,ggplot2,plotly,htmlwidgets)

# Importar los datos ------------------------------------------------------
df <- read.csv("datos/massachusetts.csv", sep = ",", encoding = "utf8")
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

# 3-Detectar y gestionar la presencia de valores NA -------------------------

# Recuento de valores NA totales, por variable y por fila
sum(is.na(df_clean)) # Contar los NA del df
colSums(is.na(df_clean)) # Contar los NA por columna
rowSums(is.na(df_clean)) # Contar los NA por fila

# Identificación de valores NA con DataExplorer
profile_missing(df_clean) # Tabla de datos
plot_missing(df_clean) # Gráfico de datos

# Eliminar filas o columnas que estén completamente vacías
df_clean <- remove_empty(df_clean, which = c("rows","cols"), quiet = FALSE) # Eliminar
dim(df_clean) # Dimensiones del objeto, filas y columnas

# Reemplazar NA por 0 (cero)
# df_clean[is.na(df_clean)] <- 0 # Asignar valor de 0 (cero) a los NA
# View(df_clean)

# Validar gestión de NA con DataExplorer
# profile_missing(df_clean) # Tabla de datos
# plot_missing(df_clean) # Gráfico de datos

# eliminar los valores NA con la función na.exclude()
# df_clean <- na.exclude(df_clean)
# dim(df_clean)
# View(df_clean)

# Detectar outliers -------------------------------------------------------

# Función para detectar outliers en una columna
detect_outliers <- function(x) {
  IQR_val <- IQR(x, na.rm = TRUE)
  lower_limit <- quantile(x, 0.25, na.rm = TRUE) - 1.5 * IQR_val
  upper_limit <- quantile(x, 0.75, na.rm = TRUE) + 1.5 * IQR_val
  x < lower_limit | x > upper_limit
}

# Identificar outliers y NA aplicando función
df_outliers <- df_clean %>%
  mutate(across(where(is.numeric), ~ detect_outliers(.), .names = "outlier_{col}")) %>% # Crear columna temporal y aplicar función
  mutate(any_outlier = if_else(rowSums(select(., starts_with("outlier_"))) > 0, TRUE, FALSE)) %>% # Calcular campo any_outlier
  mutate(any_na = if_else(rowSums(is.na(.)) > 0, TRUE, FALSE)) %>% # Calcular campo any_na
  # filter(any_outlier | any_na) # Aplicar el filtro
  # filter(!any_outlier & !any_na) # Invertir el filtro
  select(-starts_with("outlier_")) # Eliminar columnas temporales
View(df_outliers)

# Resumen estadístico de los datos ----------------------------------------
summary(df_outliers) # Resumen estadístico de variables

# Gráficos: histograma o gráfico de barras --------------------------------

# Crear el gráfico y guardarlo en una variable
grafico_barra <- df_outliers %>% 
  filter(!is.na(homicides)) |> # Se filtran los valores NA
  ggplot(aes(y = reorder(str_to_title(name), +homicides), x = homicides)) +  # Reordenar por variable en orden decreciente
  geom_bar(stat = "identity") +
  labs(title = "Distribución de homicidios por condado",
       subtitle = "Estado de Massachusett",
       x = "Homicidios",
       y = "Condados") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +  # Para rotar las etiquetas del eje x
  theme_minimal()  # Usar un tema minimalista

# Ver el gráfico
grafico_barra
# Guardar el gráfico en la ruta especificada
ggsave(filename = "plots/grafico_barra.png", plot = grafico_barra, dpi = 300, bg = "white")

# Gráficos: gráfico de densidad -------------------------------------------

grafico_densidad <- df_outliers %>%
  filter(!is.na(avg_income)) %>% 
  filter(!is.na(life_expectancy)) %>%
  ggplot(aes(avg_income, colour = factor(round(life_expectancy, 0)), fill = factor(round(life_expectancy, 0)))) +
  geom_density(alpha = 0.2) +
  labs(
    title = "Distribución del Ingreso Promedio",
    subtitle = "Estado de Massachusett",
    x = "Ingreso Promedio",
    y = "Densidad de Ingresos",
    color = "Expectativa de vida",
    fill = "Expectativa de vida"
  ) +
  theme_minimal()

# Ver el gráfico
grafico_densidad
# Guardar el gráfico en la ruta especificada
ggsave(filename = "plots/grafico_densidad.png", plot = grafico_densidad, dpi = 300, bg = "white")

# Gráficos: diagrama de caja -----------------------------------

grafico_caja <- df_outliers |>
  filter(!is.na(housing_costs)) |>
  ggplot(aes(x="",y = housing_costs)) +  # Cambiamos a ggplot2 para usar la variable housing_costs
  geom_boxplot() +
  geom_jitter(colour = "#964000", size = 2, alpha = 0.5) +
  labs(
    title = "Distribución de los costos de vivienda",
    subtitle = "Estado de Massachusett",
    x = "Costos de vivienda",
    y = "Valor de los costos"
  ) +
  theme_minimal()  # Agregamos un tema para mejorar la presentación

# Ver el gráfico
grafico_caja
# Guardar el gráfico en la ruta especificada
ggsave(filename = "plots/grafico_caja.png", plot = grafico_caja, dpi = 300, bg = "white")

# Gráficos: gráfico de dispersión -----------------------------------------

# Calcular el modelo de regresión
# modelo <- lm(housing_costs ~ avg_income, data = df_outliers)
modelo <- lm(homicides ~ housing_problems, data = df_outliers)
# Calcular R2
r_squared <- summary(modelo)$r.squared

# Crear el gráfico
grafico_dispersion <- df_outliers %>% 
  filter(!is.na(homicides)) %>% 
  filter(!is.na(housing_problems)) %>% 
  ggplot(aes(x = homicides, y = housing_problems, color = str_to_title(name)))+ 
  geom_point(size = 2.5) +  # Ajusta el tamaño de los puntos
  geom_smooth(method = lm, se = FALSE, color = "black",linewidth = 0.35) +  # Línea de regresión en color negro
  labs(
    title = "Relación entre los homicidios y la dificultad con la vivienda", 
    subtitle = "Estado de Massachusetts", 
    x = "Homicidios", 
    y = "Dificultad con la vivienda",
    color = 'Condado'
  ) +
  annotate("text", x = 10, y = Inf, label = paste("R² =", round(r_squared, 2)), 
           hjust = 1.1, vjust = 1.5, size = 4, color = "black") +
  theme_minimal()  # Cambia el tema del gráfico

# Ver el gráfico
grafico_dispersion
# Guardar el gráfico en la ruta especificada
ggsave(filename = "plots/grafico_dispersion.png", plot = grafico_dispersion, dpi = 300, bg = "white")

# Gráficos: gráfico de burbujas -------------------------------------------

grafico_burbuja <- df_outliers |>
  mutate(etiqueta = paste("Condado: ", str_to_title(name),
                          "\nHomicidios: ", round(homicides,2),
                          "\nDificultad con la vivienda: ", round(housing_problems,2),
                          "\nHijos en pobreza: ", children_in_poverty, sep="")) %>% 
  ggplot(aes(x = homicides, y = housing_problems, size = children_in_poverty, colour = str_to_title(name), text = etiqueta)) + 
  geom_point(alpha = 0.6) + 
  scale_size(range = c(1, 7), name = "") + 
  scale_color_viridis_d() + 
  labs(
    title = "Relación entre los costos de vivienda y el ingreso promedio",
    subtitle = "El tamaño del círculo representa un valor adicional (puedes ajustar esto)",
    x = "Homicidios",
    y = "Dificultad con la Vivienda",
    color = "Condado"
  ) + 
  theme_minimal()

# Convertir el gráfico a un gráfico interactivo
grafico_interactivo <- ggplotly(grafico_burbuja, tooltip = "etiqueta")
grafico_interactivo # Ver el gráfico

# Guardar el gráfico interactivo como una página web en la carpeta "plots"
htmlwidgets::saveWidget(grafico_interactivo, "plots/grafico_burbuja.html", selfcontained = TRUE)

# Exportar resultados y validar CSV ---------------------------------------

# Guardar el archivo
write.csv(df_outliers, file = "resultados/df_outliers.csv", row.names = FALSE)

# Cargar el archivo y validar
df_resultado <- read.csv("resultados/df_outliers.csv", sep = ",", encoding = "utf8")
class(df_resultado)
View(df_resultado)

# Guardar los objetos de la sesión R --------------------------------------
save.image(file=".RData")

