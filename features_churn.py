
import duckdb
import time

# Inicio del tiempo de ejecucion
inicio = time.perf_counter()

# Conexion a DuckDB en memoria
con = duckdb.connect()

# Registrar los archivos CSV como vistas
con.execute("""
    CREATE VIEW usuarios AS
    SELECT *
    FROM read_csv_auto('datos/usuarios.csv')
""")

con.execute("""
    CREATE VIEW compras AS
    SELECT *
    FROM read_csv_auto('datos/compras.csv')
""")

# Leer la consulta SQL
with open("features.sql", "r", encoding="utf-8") as archivo:
    consulta = archivo.read()

# Ejecutar la consulta
features = con.execute(consulta).df()

# Mostrar resultados
print("FEATURES PARA PREDICCION DE CHURN")
print(features.to_string(index=False))

# Exportar los resultados
features.to_csv("features_churn.csv", index=False)

# Cerrar conexion
con.close()

# Medir tiempo total
tiempo_total = time.perf_counter() - inicio

print(f"\nTiempo total: {tiempo_total:.6f} segundos")
print("Archivo features_churn.csv generado correctamente.")
