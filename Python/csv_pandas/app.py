# coding=utf-8
# Título: Práctica 2-Procesamiento de datos con archivos CSV
# Requerimientos: Python 3x
# Librerías: pandas, time, os, pathlib, geocoder
# Autor: Mauricio Tabares Mosquera
# Fecha: 2026-02-23

import pandas as pd
from csv_processing.read_write_csv import unificar_dataframe, limpiar_df, crear_df_csv, list_files, inicializar_dataframe, exportar_csv
from geocoder_processing.geocoder_arcgis import geoprocesar_direcciones
from pathlib import Path
from time import strftime

# Inicio de script
print("\nScript iniciado: ".upper() + strftime("%Y-%m-%d %H:%M:%S"))

# Variables de usuario

# Ruta de archivos csv
folder_path = Path(r"D:\msc\8_analisis_espacial_python\practica_2\files")
# Nombre archivo de salida
nombre_archivo = "datos_alumnos"

# Ejecutar funciones

# Crear dataframe 'maestro' vacío
columna_vacio = ['codigo', 'nombre', 'apellidos', 'direccion', 'latitud', 'longitud']
df_vacio = inicializar_dataframe(columna_vacio)
# Listar los archivos csv dentro de la carpeta
listado = list_files(folder_path)
# Crear los dfs para cada archivo csv
csv_a_df = crear_df_csv(listado)
# Aplicar la limpieza de los df
df_csv_limpio = limpiar_df(csv_a_df)
# Unificar df
df_datos_alumnos = unificar_dataframe(df_csv_limpio)
# Geodificar direcciones
df_datos_alumnos = geoprocesar_direcciones(df_datos_alumnos, 'direccion')
# Unir df vacío con el temporal con datos
df_vacio = pd.concat([df_vacio, df_datos_alumnos], ignore_index=True)
# print(f"Total de registros consolidados: {len(df_vacio)}")
# Exportar df
exportar_csv(df_vacio, "datos_alumnos") # Ejecutar función

# Leer y comprobar el archivo exportado
print("\nVerificar archivo exportado:\n")
df_csv_cargado = pd.read_csv(f'.\{nombre_archivo}.csv', sep=";", encoding='utf-8')
variable_df = ", ".join([variable for variable in df_csv_cargado.columns]) # Nombre variables
print(f"Nombre variable: {variable_df}")
print(f'Número de filas: {df_csv_cargado.shape[0]}\nNúmero de columnas: {df_csv_cargado.shape[1]}') # Dimensionalidad del df_csv_cargado
print(f"\nImprimir primeros registros:")
print(df_csv_cargado.head()) # Imprimir el df_csv_cargado

# Fin script
print("\nScript terminado: ".upper() + strftime("%Y-%m-%d %H:%M:%S"))