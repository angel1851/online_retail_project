# online_retail_project
Análisis de ventas y clientes de un ecommerce usando SQL para generar insights accionables de negocio

## ✅ Objetivo del proyecto:
Liderar un análisis de más de 500,000 registros de ventas en línea para:

### Medir ventas y ticket promedio. 
- Identificar productos más rentables y con mayor rotación.
- Detectar clientes más valiosos y concentración de ingresos (Pareto).
- Generar insights estratégicos sobre estacionalidad y oportunidades de crecimiento.

### Desafíos enfrentados:

- Datos dispersos con registros administrativos, devoluciones, valores nulos y ajustes contables.
- Algunos customer_id y productos estaban vacíos o eran irrelevantes para análisis de ventas.
- Distorsión en métricas clave si no se limpiaban los datos antes de calcular ingresos, tickets y rankings.

### Soluciones aplicadas:

- Limpieza de datos: filtré registros con valores nulos, cantidades negativas, precios en 0 y productos administrativos (POSTAGE, damages, manual).
- Uso de CTEs, window functions y subqueries para calcular rankings, acumulados y métricas de crecimiento sin perder precisión.
- Validación de resultados con salidas de ejemplo para asegurar confiabilidad de métricas.

### Impacto / Mejoras logradas:

- Métricas precisas de ventas por mes y ticket promedio por país.
- Identificación de productos y clientes estratégicos.
- Insights claros sobre concentración de ingresos, estacionalidad y oportunidades de crecimiento.
- Base limpia y lista para generar dashboards o análisis adicionales en Power BI / Tableau.

# Online Retail Project – Bloque 1: Ventas y comportamiento de clientes

## 1️⃣ Objetivo del Bloque

Analizar las ventas totales y el comportamiento de los clientes en la tienda online para:

- Calcular ventas totales por mes y ticket promedio.  
- Medir crecimiento mensual (%) y variación mes a mes.  
- Detectar meses fuertes y débiles.  
- Entender posibles razones de aumento o disminución de ventas.

---

## 2️⃣ Problemas detectados

- Registros administrativos y ajustes contables que distorsionaban métricas (`POSTAGE`, `DOT`, `manual`, `damaged`, `reverse adjustment`).  
- Valores nulos o inconsistentes (`?`, `faulty`).  
- Cantidades o precios negativos.  
- Clientes duplicados y productos repetidos.

Estos problemas impedían obtener métricas confiables para análisis mensual y toma de decisiones.

---

## 3️⃣ Solución aplicada

### 3.1 Limpieza de datos

- Filtrado de productos válidos (`productos`) excluyendo descripciones inválidas.  
- Creación de tabla `customers` con clientes únicos.  
- Creación de tabla `sales` limpia, solo con ventas reales y totales por línea.

**Fragmento representativo:**

```sql
-- Tabla de clientes únicos
CREATE TABLE customers AS
SELECT DISTINCT Customer_ID, Country
FROM retail
WHERE Customer_ID IS NOT NULL;

-- Tabla de productos válidos
CREATE TABLE productos AS
SELECT stock_code, description
FROM retail
WHERE LOWER(description) NOT IN ('', '?', 'faulty', 'damages')
  AND description NOT LIKE '%wrong%'
GROUP BY stock_code, description;

-- Tabla de ventas limpia
CREATE TABLE sales AS
SELECT invoice_date, invoice_no, stock_code, customer_id,
       quantity, unit_price, quantity*unit_price AS total_linea
FROM retail
WHERE quantity > 0 AND unit_price > 0;
```

### 3.2 Analisis de ventas
**Ventas totales por mes con ranking:**

```sql
WITH sales_month AS (
    SELECT YEAR(invoice_date) AS year,
           MONTH(invoice_date) AS month,
           SUM(total_linea) AS month_sales,
           COUNT(DISTINCT customer_id) AS new_customers
    FROM sales
    GROUP BY YEAR(invoice_date), MONTH(invoice_date)
)
SELECT year, month, month_sales, new_customers,
       RANK() OVER(ORDER BY month_sales DESC) AS ranking
FROM sales_month;
```

<img width="395" height="220" alt="image" src="https://github.com/user-attachments/assets/7c664678-4881-4044-9b41-4a4e6ce17e97" /> <br><br>



**Ticket promedio y por país:**
```sql
-- Ticket promedio general
SELECT SUM(total_linea)/COUNT(DISTINCT invoice_no) AS ticket_promedio
FROM sales;
```
<img width="121" height="48" alt="image" src="https://github.com/user-attachments/assets/57f1a058-21a0-44bf-980f-b6298d8bacbe" /> <br><br>

```sql
-- Ticket promedio por país

SELECT c.country,
       SUM(s.total_linea)/COUNT(DISTINCT s.invoice_no) AS ticket_promedio
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.country;
```
 <img width="247" height="213" alt="image" src="https://github.com/user-attachments/assets/4e9008a7-7f67-4e9d-bd0e-6a0e591b6ded" /> <br><br>

**Crecimiento mensual y variación mes a mes:**
```sql
WITH monthly AS (
    SELECT YEAR(invoice_date) AS year,
           MONTH(invoice_date) AS month,
           SUM(total_linea) AS total_sales
    FROM sales
    GROUP BY year, month
),
sales_lag AS (
    SELECT year, month, total_sales,
           LAG(total_sales) OVER (ORDER BY year, month) AS previous_month
    FROM monthly
)
SELECT year, month, total_sales,
       ROUND((total_sales-previous_month)/previous_month*100,2) AS pct_growth,
       ROUND(total_sales-previous_month,2) AS month_variation
FROM sales_lag
ORDER BY year, month;
```
<img width="423" height="218" alt="image" src="https://github.com/user-attachments/assets/a9b00c6b-85b9-4ebb-b18f-114a5dc72d51" /> <br><br>

# Bloque 2: Analisis de Productos
---
## ✅Objetivo

Identificar los productos que generan más ingresos, los de baja rotación y detectar patrones interesantes, garantizando que los datos estén limpios y libres de registros administrativos o ajustes contables que puedan distorsionar los resultados.

## ❌Problemas Detectados
Al correr el ranking inicial de productos, aparecieron registros no válidos que afectan la precisión del análisis:

- POSTAGE, manual, damaged, reverse adjustment, website fixed, faulty, ?, etc.

### Estos representan:

- Costos de envío
- Ajustes manuales o contables
- Errores operativos

Si no se filtran, distorsionan los resultados de los productos más vendidos o más rentables.
---
**Limpieza Aplicada**

Se creó una tabla limpia productos aplicando filtros:
```sql

CREATE TABLE productos AS
SELECT 
    stock_code,
    MAX(description) AS description
FROM retail
WHERE description NOT IN ('', '?', 'faulty', 'damages')
  AND description NOT LIKE '%wrongly%'
  AND description NOT LIKE '%wrong%'
  AND description NOT LIKE '%dotcom%'   
  AND description NOT LIKE '%adjustment%'
  AND description NOT LIKE '%lost in space%'
GROUP BY stock_code, description;
```

**Filtros aplicados:**
- Cantidades negativas → eliminadas
- Precios en 0 → eliminados
- Códigos administrativos (POST, DOT, M) → eliminados
- Palabras clave en descripciones (manual, postage, website, marked, damaged, reverse)

## Consultas de analisis
### 1️⃣ Top 10 Productos por unidades vendidas

```sql
SELECT	
    p.description,
    SUM(s.quantity) AS quantity,
    SUM(s.total_linea) AS total_revenue
FROM sales s
JOIN productos p ON s.stock_code = p.stock_code
GROUP BY p.description
ORDER BY quantity
LIMIT 10;
```
<img width="452" height="254" alt="image" src="https://github.com/user-attachments/assets/d1d8090f-8f6b-47a0-9186-fce5ef715a4c" /> <br><br>

### 2️⃣ Productos con baja rotación

```sql
SELECT	
    p.description,
    SUM(s.quantity) AS quantity,
    SUM(s.total_linea) AS total_revenue
FROM sales s
JOIN productos p ON s.stock_code = p.stock_code
GROUP BY p.description
ORDER BY quantity
LIMIT 10;
```
 <img width="485" height="256" alt="image" src="https://github.com/user-attachments/assets/e3f6e461-4a38-49cd-bd94-29138ea6f329" /> <br><br>

 ### 3️⃣ Patrones interesantes: productos de bajo volumen y alta facturación

 ```sql
SELECT 
    p.description,
    SUM(s.quantity) AS units,
    SUM(s.total_linea) AS revenue
FROM sales s
JOIN productos p ON s.stock_code = p.stock_code
GROUP BY p.description
HAVING units < 100
ORDER BY revenue DESC
LIMIT 10;
```
<img width="412" height="238" alt="image" src="https://github.com/user-attachments/assets/9089de80-c5f7-44d2-b0f5-233b1f2a4c37" /> <br><br>


### Insights de Negocio

- Los productos decorativos y de fiesta dominan las ventas totales.
- Algunos productos con bajo volumen generan altos ingresos, identificando oportunidades de optimización de stock o marketing.
- La limpieza de datos fue crucial para obtener métricas confiables y evitar distorsión por registros administrativos o errores operativos.
- Este análisis prepara la base para el ranking de clientes y Pareto en el siguiente bloque.
 

# Bloque 3: Análisis de Clientes

## ✅Objetivo
Identificar los clientes que generan mayor revenue y analizar cómo se distribuyen las ventas entre ellos.

Este análisis permite detectar clientes de alto valor y verificar si se cumple el principio de Pareto (80/20), donde un pequeño porcentaje de clientes genera la mayor parte de los ingresos.

**Clientes totales: 4335**


### 1️⃣Ranking customers
Primero se construyó un ranking de clientes según el revenue total generado.

**Consulta utilizada:**
```sql
SELECT
    customer_id, 
    SUM(total_linea) AS revenue,
    RANK() OVER(ORDER BY SUM(total_linea) DESC) AS ranking
FROM sales
WHERE customer_id IS NOT NULL
    AND TRIM(customer_id) <> ''
GROUP BY customer_id
LIMIT 10;
```
<img width="252" height="245" alt="image" src="https://github.com/user-attachments/assets/274a4f79-8b2b-4f6f-8854-289791f4c2b5" />

**Este ranking permite identificar los clientes con mayor contribución a las ventas totales.**

### 2️⃣Identificación de Clientes Más Valiosos y clientes totales (Análisis Pareto)

Para entender cómo se distribuyen los ingresos entre los clientes, se aplicó un análisis Pareto utilizando Common Table Expressions (CTE) y window functions.

**Consulta utilizada:**
```sql
WITH customer_revenue AS (
    SELECT	
        customer_id,
        SUM(total_linea) AS revenue
    FROM sales
    WHERE TRIM(customer_id) <> ''
    GROUP BY customer_id
),

pareto AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY revenue DESC) AS c_rank,
        customer_id,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative,
        SUM(revenue) OVER (ORDER BY revenue DESC) /
        SUM(revenue) OVER () AS cumulative_percentage
    FROM customer_revenue
)

SELECT *
FROM pareto 
WHERE cumulative_percentage <= 0.8;
```
<img width="506" height="301" alt="image" src="https://github.com/user-attachments/assets/95268165-0cc2-4bff-9e6d-0c79a12b1d43" />

**Este análisis permite identificar qué clientes generan aproximadamente el 80% del revenue total**

### Insights de Negocio

- El análisis Pareto muestra que 1135 clientes generan aproximadamente el 80% del revenue total.
- Considerando que el dataset contiene 4335 clientes únicos, esto significa que solo el 26% de los clientes genera el 80% de las ventas.
- Este patrón confirma una alta concentración de ingresos, consistente con el principio de Pareto, donde una minoría de clientes aporta la mayor parte del valor del negocio.
- Identificar este segmento permite enfocar estrategias como:
  - Programas de fidelización
  - Ofertas personalizadas
  - Estrategias de retención para clientes de alto valor
 

## Conclusiones y Recomendaciones de Negocio
### Conclusiones

El análisis exploratorio de ventas permitió identificar patrones clave en el comportamiento de productos y clientes dentro del dataset.

**Los resultados muestran que:**

- Los productos decorativos y artículos de eventos concentran una parte importante de las ventas, indicando que el negocio tiene una fuerte orientación hacia productos de regalo y celebraciones.
- Durante el proceso de limpieza se identificaron registros administrativos y de ajuste de inventario (por ejemplo: postage, manual adjustments o damages/showroom), los cuales fueron filtrados para asegurar que el análisis reflejara únicamente transacciones comerciales reales.
- El análisis de clientes reveló una alta concentración de ingresos.
- De un total de 4335 clientes, aproximadamente 1135 clientes generan el 80% del revenue, lo que significa que solo el 26% de los clientes aporta la mayor parte de las ventas.

Este patrón confirma el principio de Pareto, común en negocios minoristas.

### Recomendaciones de Negocio

A partir de los hallazgos del análisis, se pueden considerar las siguientes estrategias:

**1. Estrategias de Fidelización**

Los clientes de alto valor identificados en el análisis Pareto representan una oportunidad clave para incrementar ingresos mediante:

- Programas de lealtad
- Descuentos exclusivos
- Acceso anticipado a productos

**2. Optimización del Portafolio de Productos**

El análisis de productos sugiere que algunos artículos con bajo volumen pero alto revenue podrían representar productos de alto margen.

Se recomienda:

- Reforzar su visibilidad en campañas
- Analizar su margen de ganancia
- Evaluar oportunidades de posicionamiento premium.

**3. Mejora Continua en Calidad de Datos**

El proceso de limpieza evidenció la presencia de registros administrativos dentro de las ventas, lo que puede distorsionar análisis comerciales.

Se recomienda:

- Mantener categorías separadas para transacciones internas
- Establecer validaciones en el sistema de registro de ventas.

**Conclusión Final**

Este análisis demuestra cómo el uso de SQL, técnicas de limpieza de datos y funciones analíticas permite transformar datos transaccionales en insights accionables para la toma de decisiones de negocio.

```
---Tools used:
- SQL (MySQL)
- Data Cleaning
- Window Functions
- CTEs
- Business Analysis
 ```
