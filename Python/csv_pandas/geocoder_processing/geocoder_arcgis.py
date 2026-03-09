# Instalar y cargar librerías
# pip install geocoder
import time
import geocoder as gc

def geoprocesar_direcciones(df, columna_direccion):
    """
    Recibe un DataFrame y el nombre de la columna de dirección.
    Crea las columnas latitud/longitud y las rellena usando ArcGIS.
    """
    print("\nScript 2 | Función-A: geocodificar direcciones del df\n")
    # 1. Preparamos las columnas (solo una vez)
    # Usamos float para que Pandas sepa que vienen números
    df['latitud'] = None
    df['longitud'] = None

    print(f"Registros a geocodificar: {len(df)}")

    # 2. Iteramos sobre el DataFrame
    for index, row in df.iterrows():
        direccion = row[columna_direccion]
    
        try:
            g = gc.arcgis(direccion)
            if g.ok:
                df.at[index, 'latitud'] = g.latlng[0] # Método at asigna valor
                df.at[index, 'longitud'] = g.latlng[1]
            else:
                # Si el servicio no encuentra nada, ya pusimos None al inicio del DF
                # pero podemos forzarlo para estar seguros
                df.at[index, ['latitud', 'longitud']] = None
                
        except Exception:
            # Si falla el internet o el servicio, asigna None y SIGUE
            df.at[index, ['latitud', 'longitud']] = None
            continue # Salta explícitamente al siguiente registro del bucle
        
        time.sleep(0.25)

    print(df.head(50))
    print("Geocoficación finalizada")
    return df