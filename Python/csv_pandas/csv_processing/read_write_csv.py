import os, pathlib, pandas as pd
from pathlib import Path

def inicializar_dataframe(columnas):
    """
    Crea y retorna un DataFrame vacío con las columnas especificadas.
    """
    print("\nScript 1 | Función-A: crear df 'maestro' vacío con campos específicos\n")
    df = pd.DataFrame(columns=columnas)
    print(f"Dataframe vacío creado con {len(columnas)} columnas\n")
    # print(df.info()) # Opcional
    return df

def list_files(ruta_entrada):
    """Retorna una lista con las rutas completas de los archivos CSV."""
    print("Script 1 | Función-B: listar archivos *.csv en carpeta\n")
    csv_files = [file for file in ruta_entrada.glob('*.csv')] # Lista de rutas completas con Glob
    # Imprimir y enumerar resultado
    for i, ruta in enumerate(csv_files, start=1):
        print(f"Archivo # {i} | {ruta.name}") # .name solo nombre de archivo

    return csv_files

def crear_df_csv(listado):
    """
    Crea un diccionario donde cada clave es 'df_nombre' y cada valor es un df.
    """
    print("\nScript 1 | Función-C: Crear df para cada archivo cargado\n")
    dict_dataframes = {} # Contenedor de df's como diccionario

    for archivo in listado:
        # Crear el nombre de la clave
        nombre_clave = f"df_{archivo.name[:-4]}"
        dict_dataframes[nombre_clave] = pd.read_csv(archivo, sep=";")
        print(f"Df creado: {nombre_clave} | Fuente: {archivo.name}")

    return dict_dataframes

def limpiar_df(diccionario_dfs):
    """
    Realiza la limpieza estandarizada de todos los df en el diccionario renombrando y eliminando columnas
    """
    print("\nScript 1 | Función-D: limpiar y estandarizar df cargados\n")
    columnas_a_eliminar = ['latitud', 'longitud', 'sexo', 'edad']
    
    for nombre, df in diccionario_dfs.items():
        # Renombrar columna si existe
        if '#alumnos_codigo' in df.columns:
            df.rename(columns={'#alumnos_codigo': 'codigo'}, inplace=True)
        
        # Eliminar columna no deseada
        diccionario_dfs[nombre] = df.drop(columns=columnas_a_eliminar, errors='ignore') # errors= ignore para continuar el script
        
        print(f"Limpieza completada en: {nombre}")
    
    return diccionario_dfs

def unificar_dataframe(diccionario_dfs):
    """
    Toma un diccionario de df y los une.
    """
    print("\nScript 1 | Función-E: unificar df\n")
    if not diccionario_dfs:
        print("El diccionario está vacío")
        return None

    df_unificado = pd.concat(diccionario_dfs.values(), ignore_index=True) # Unir los valores (df's) del diccionario
    print(f"Unificación exitosa: {len(df_unificado)} registros totales combinados")
    # print("df_unificado:")
    print(df_unificado.head(10))

    return df_unificado

def exportar_csv(df, nombre_archivo):
    """
    Exporta el DataFrame a la raíz del proyecto (donde se ejecuta el script).
    """
    print("\nScript 1 | Función-F: exportar csv a carpeta raíz\n")
    ruta_final = os.path.join(Path.cwd(), f"{nombre_archivo}.csv") # Cwd = current working directory

    try:
        # 2. Exportar con encoding compatible con Excel (utf-8-sig)
        df.to_csv(ruta_final, index=False, sep=";", encoding='utf-8')
        print(f"Archivo exportado {ruta_final}")
        
    except Exception as e:
        print(f"Error al exportar: {e}")
