-- ESPERANZA DE VIDA MUNDIAL:

SELECT * 
FROM world_life_expectancy;

-- ----------------------------------------
-- ----------------------------------------

-- LIMPIEZA DE DATOS:

-- Búsqueda de duplicados:

SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year)) 
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1
;	

#Creación de una tabla temporal para consulta y búsqueda de duplicados

SELECT *
FROM (
	SELECT Row_ID, CONCAT(Country, Year), 
	ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy
	) AS Row_table
WHERE Row_Num > 1
;	

#Limpieza

SET SQL_SAFE_UPDATES = 0;

DELETE FROM world_life_expectancy
WHERE 
	Row_ID IN (
    SELECT Row_ID
FROM (
	SELECT Row_ID, CONCAT(Country, Year), 
	ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy
	) AS Row_table
WHERE Row_Num > 1
)
;

-- ----------------------------------------------------------

-- Búsqueda y reemplazo de nulos:

SELECT * 
FROM world_life_expectancy
WHERE Status =  ''
;

SELECT * 
FROM world_life_expectancy
WHERE Status <>  ''
;

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;

# Reemplazo en variables faltantes en 'Status'

SET SQL_SAFE_UPDATES = 0;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status = 'Developing'
AND t2.Status <> ''
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status = 'Developed'
AND t2.Status <> ''
;


SELECT * 
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
;

# Query para obtener la media entre el año anterior y posterior.

SELECT t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`) /2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t2.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;


UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t2.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) /2,1)
WHERE t1.`Life expectancy` = ''
;

SELECT * 
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

-- ----------------------------------------------------------
-- ----------------------------------------------------------

-- ESPERANZA DE VIDA MUNDIAL (EDA):

-- ANÁLISIS EXPLORATORIO DE DATOS:

SELECT * 
FROM world_life_expectancy
;

# Búsqueda de máximos, mínimos y diferenciais en la esperanza de vida.

SELECT Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0 AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years DESC
;

-- Haiti, Zimbawe y Eritrea tienen el mayor incremento de esperanza de vida en 15 años con 28,7, 22,7 y 21,7 respectivamente.
-- Guyana, Seychelles y Kuwait tienen el menor incremento de esperanza de vida en 15 años con 1,3, 1,4 y 1,5 respectivamente.

# Análisis de crecimiento de esperanza de vida promedio mundial.

SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
AND `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year
;

-- La esperanza de vida ha incrementado aproximadamente unos 5 años desde el 2007 a 2022.

-- ----------------------------------------------------------

# Eesperanza de vida vs GDP (PIB)

SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0 
AND GDP > 0
ORDER BY GDP DESC
;

SELECT
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) Low_GDP_Life_Expectancy
FROM world_life_expectancy
;

-- 

-- ----------------------------------------------------------

# Diferencia entre países desarrollados y en vías de desarrollo.

SELECT Status, ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;

-- En países en vías de desarrollo, las expectativas de vida media rondan los 67 años (aprox).
-- En países desarrollados, las expectativas de vida media rondan los 79 años.

SELECT Status, COUNT(DISTINCT(Country))
FROM world_life_expectancy
GROUP BY Status
;

-- Existen 32 países desarrollados y 161 en vías de desarrollo.
-- Es importante mencionar que el resultado de la media de países desarrollados está cesgada por la baja cantidad de países que la conforman. 


SELECT Country, Status
FROM world_life_expectancy
WHERE Country = 'Chile'
;

-- Chile es un país en vías de desarrollo.

-- ----------------------------------------------------------

# BMI con Expectativas de vida.

SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0 
AND BMI > 0
ORDER BY BMI ASC
;

-- En general, el BMI está asociado con las expectativas de vida.  Esto se puede ver con los menores puntajes de BMI cuya expectativa de vida está por debajo de los 60.

-- ----------------------------------------------------------

# Mortalidad Adulta 

SELECT Country,  Year, `Life expectancy`, `Adult Mortality`, SUM(`Adult Mortality`) OVER (PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
;

SELECT Country,  Year, `Life expectancy`, `Adult Mortality`, SUM(`Adult Mortality`) OVER (PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
WHERE Country = 'Chile'
;

-- Chile muestra un leve descenso a medida que aumentan los años.

-- ----------------------------------------------------------
-- ----------------------------------------------------------