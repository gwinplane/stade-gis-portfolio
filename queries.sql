-- =============================================
-- GIS-Abfragen: Landkreis Stade
-- Autor: Maksym Marinin
-- Daten: OpenStreetMap (Geofabrik Niedersachsen)
-- Datenbank: PostgreSQL 18 + PostGIS 3.6
-- =============================================


-- ---------------------------------------------
-- Abfrage 1: Alle Schulen im Landkreis Stade
-- Zeigt Name und Geometrie aller Schulen
-- Ergebnis: 18 Schulen gefunden
-- ---------------------------------------------
SELECT name, amenity, way
FROM planet_osm_point
WHERE amenity = 'school'
ORDER BY name;


-- ---------------------------------------------
-- Abfrage 2: Alle Einrichtungstypen (amenity)
-- GROUP BY = gruppiert gleiche Werte zusammen
-- COUNT = zählt wie viele es gibt
-- ORDER BY anzahl DESC = sortiert absteigend
-- Ergebnis: bench=1032, waste_basket=381 ...
-- ---------------------------------------------
SELECT amenity, COUNT(*) AS anzahl
FROM planet_osm_point
WHERE amenity IS NOT NULL
GROUP BY amenity
ORDER BY anzahl DESC
LIMIT 20;


-- ---------------------------------------------
-- Abfrage 3: Alle Restaurants mit Küche
-- Einfacher SELECT mit WHERE-Filter
-- ---------------------------------------------
SELECT name, cuisine
FROM planet_osm_point
WHERE amenity = 'restaurant'
ORDER BY name;


-- ---------------------------------------------
-- Abfrage 4: Straßenlängen nach Typ (in km)
-- ST_Length = PostGIS Funktion für Linienlänge
-- ST_Transform(way, 4326) = Koordinaten in
--   Grad umrechnen (lon/lat) für geography
-- ::geography = geografische Berechnung in Meter
-- SUM = alle Längen addieren
-- ROUND = auf ganze Zahl runden
-- / 1000 = Meter in Kilometer umrechnen
-- Ergebnis: track=1399km, residential=870km ...
-- ---------------------------------------------
SELECT highway,
       ROUND(SUM(ST_Length(ST_Transform(way, 4326)::geography)) / 1000) AS laenge_km
FROM planet_osm_line
WHERE highway IS NOT NULL
GROUP BY highway
ORDER BY laenge_km DESC;


-- ---------------------------------------------
-- Abfrage 5: Anzahl Objekte pro Tabelle
-- UNION ALL = mehrere SELECT zusammenfügen
-- Zeigt wie viele Objekte importiert wurden
-- ---------------------------------------------
SELECT 'point' AS tabelle, COUNT(*) AS anzahl FROM planet_osm_point
UNION ALL
SELECT 'line', COUNT(*) FROM planet_osm_line
UNION ALL
SELECT 'polygon', COUNT(*) FROM planet_osm_polygon
UNION ALL
SELECT 'roads', COUNT(*) FROM planet_osm_roads;


-- ---------------------------------------------
-- Abfrage 6: Alle Gebäude in Stade
-- building IS NOT NULL = hat einen Gebäudetyp
-- ST_Area = PostGIS Funktion für Fläche
-- Ergebnis: Gebäudeflächen in Quadratmeter
-- ---------------------------------------------
SELECT name,
       building,
       ROUND(ST_Area(ST_Transform(way, 4326)::geography)) AS flaeche_m2
FROM planet_osm_polygon
WHERE building IS NOT NULL
AND name IS NOT NULL
ORDER BY flaeche_m2 DESC
LIMIT 20;