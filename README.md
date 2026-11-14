# Feature Engineering para predicción de Churn con DuckDB

## Descripción

Proyecto de preparación de variables para Machine Learning mediante Python, SQL y DuckDB.

El objetivo es generar características (features) por usuario que permitan analizar su comportamiento de compra y que puedan utilizarse posteriormente en un modelo de predicción de abandono de clientes (Churn).

## Tecnologías utilizadas

- Python
- DuckDB
- Pandas
- SQL

## Dataset

Se utilizan dos archivos CSV con datos sintéticos:

- `datos/usuarios.csv`: contiene los identificadores y nombres de los usuarios.
- `datos/compras.csv`: contiene los pedidos, fechas y montos de compra.

El dataset contiene cinco usuarios y nueve pedidos realizados entre octubre y diciembre de 2024.

## Features generadas

### Recency

Cantidad de días transcurridos desde la última compra hasta la fecha de corte.

Se calcula mediante DATE_DIFF y MAX sobre las fechas de compra.

Esta variable permite identificar usuarios que llevan mucho tiempo sin realizar compras, lo que puede representar un mayor riesgo de abandono.

### Frequency

Cantidad de pedidos únicos realizados por cada usuario.

Se calcula mediante COUNT(DISTINCT pedido_id).

Permite medir el nivel de actividad y la frecuencia de compra del cliente.

### Monetary

Gasto total acumulado por cada usuario.

Se calcula mediante SUM sobre los montos de compra.

Permite conocer el valor económico del cliente y diferenciar distintos niveles de consumo.

### Trend

Diferencia entre el gasto del último mes y el promedio mensual histórico.

Se utilizan funciones de ventana mediante OVER y PARTITION BY para calcular el promedio histórico de cada usuario.

Una tendencia negativa indica una disminución del gasto respecto de los meses anteriores, lo que puede representar una señal de posible abandono.

## Periodo de análisis

La fecha de corte establecida es el 1 de enero de 2025.

Para calcular Trend se compara el gasto de diciembre de 2024 con el promedio mensual de octubre y noviembre de 2024.

Los meses sin compras se contabilizan con gasto cero.

Se excluyen las compras realizadas en la fecha de corte o posteriormente para evitar utilizar información futura.

## Manejo de valores nulos

Se utiliza LEFT JOIN para conservar todos los usuarios, incluso aquellos que no realizaron compras.

Se utiliza COALESCE para reemplazar valores nulos por cero en las agregaciones de gasto y tendencia.

Frequency devuelve cero cuando el usuario no tiene pedidos.

Recency conserva un valor nulo cuando el usuario nunca realizó una compra, ya que no existe una fecha de última actividad.

Antes de utilizar estas variables en un modelo de Machine Learning, será necesario definir una estrategia de imputación para Recency.

## Instalación

Instalar las dependencias:

```bash
pip install -r requirements.txt
```

## Ejecución

Ejecutar desde la carpeta raíz del proyecto:

```bash
python features_churn.py
```

El script consulta los archivos CSV mediante DuckDB, ejecuta las consultas almacenadas en features.sql y genera el archivo features_churn.csv.

## Resultados obtenidos

| Usuario | Recency | Frequency | Monetary | Trend |
|---|---:|---:|---:|---:|
| 1 | 17 | 3 | 450.0 | 75.0 |
| 2 | 42 | 2 | 120.0 | -60.0 |
| 3 | 12 | 3 | 800.0 | 125.0 |
| 4 | 91 | 1 | 50.0 | -25.0 |
| 5 | NULL | 0 | 0.0 | 0.0 |

## Hallazgos principales

- El usuario 3 presenta el mayor gasto acumulado y una tendencia positiva.
- El usuario 2 presenta una tendencia negativa de -60, indicando una disminución de su actividad de compra.
- El usuario 4 presenta la mayor cantidad de días desde su última compra entre los usuarios con actividad.
- El usuario 5 no registra compras y presenta valores de cero en Frequency, Monetary y Trend.

Estos resultados permiten identificar diferentes patrones de comportamiento que podrían utilizarse como variables predictoras de abandono.

## Rendimiento

El tiempo total de ejecución se midió utilizando time.perf_counter() de Python.

| Operación | Tiempo de ejecución (segundos) |
|---|---:|
| Procesamiento completo | 4.504529 |

El tiempo incluye la conexión a DuckDB, el registro de las vistas, la ejecución de la consulta SQL, la generación del DataFrame y la exportación del archivo CSV.

Este resultado corresponde a una ejecución realizada en el equipo de desarrollo y puede variar según el hardware y las condiciones de ejecución.

## Conclusión

DuckDB permite realizar Feature Engineering directamente mediante consultas SQL sobre archivos CSV.

El uso de funciones de agregación, funciones de ventana y estrategias de manejo de nulos permite generar variables consistentes para el análisis del comportamiento de los usuarios.

Las features Recency, Frequency, Monetary y Trend constituyen una base para el desarrollo de futuros modelos de predicción de Churn.
