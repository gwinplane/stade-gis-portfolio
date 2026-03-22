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

-- =============================================
-- Neue SQL-Abfragen: Datenanalyse Stade
-- Datum: März 2026
-- =============================================


-- ---------------------------------------------
-- Abfrage 7: Alle Bäckereien mit Namen
-- AND = zwei Bedingungen gleichzeitig
-- IS NOT NULL = nur Objekte mit Namen
-- ---------------------------------------------
SELECT name, shop
FROM planet_osm_point
WHERE shop = 'bakery'
AND name IS NOT NULL
ORDER BY name;


-- ---------------------------------------------
-- Abfrage 8: Bäckerei-Ketten nach Filialanzahl
-- GROUP BY name, shop = gruppiere nach Name
-- COUNT(*) = zähle Filialen pro Gruppe
-- ---------------------------------------------
SELECT name, shop, COUNT(*) AS anzahl
FROM planet_osm_point
WHERE shop = 'bakery'
AND name IS NOT NULL
GROUP BY name, shop
ORDER BY anzahl DESC;


-- ---------------------------------------------
-- Abfrage 9: Datenbereinigung mit LOWER()
-- LOWER() = macht Text kleingeschrieben
-- Löst Problem: "von Allwörden" vs "Von Allwörden"
-- Ergebnis: von allwörden = 8 Filialen
-- ---------------------------------------------
SELECT LOWER(name), shop, COUNT(*) AS anzahl
FROM planet_osm_point
WHERE shop = 'bakery'
GROUP BY LOWER(name), shop
ORDER BY anzahl DESC;


-- ---------------------------------------------
-- Abfrage 10: Top 5 Städte nach Einwohnerzahl
-- ::integer = Text in Zahl umwandeln
-- Wichtig! Ohne ::integer sortiert PostgreSQL
-- alphabetisch statt numerisch!
-- LIMIT 5 = nur 5 Ergebnisse zeigen
-- ---------------------------------------------
SELECT name, place, population
FROM planet_osm_point
WHERE place IS NOT NULL
AND population IS NOT NULL
ORDER BY population::integer DESC
LIMIT 5;


-- ---------------------------------------------
-- Abfrage 11: Supermarkt-Ketten nach Filialanzahl
-- Kombination von LOWER(), COUNT(), GROUP BY
-- Ergebnis: REWE = 6 Filialen (Marktführer!)
-- ---------------------------------------------
SELECT LOWER(name), COUNT(*) AS anzahl
FROM planet_osm_point
WHERE shop = 'supermarket'
AND name IS NOT NULL
GROUP BY LOWER(name)
ORDER BY anzahl DESC;