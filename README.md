# stade-gis-portfolio
GIS-Projekt mit PostGIS und QGIS — Landkreis Stade
# Stade GIS Portfolio

GIS-Projekt mit PostGIS und QGIS für den Landkreis Stade, Niedersachsen.

## Technologien / Tools
- QGIS 3.x
- PostgreSQL 18 + PostGIS 3.6
- OpenStreetMap Daten (Geofabrik)
- osm2pgsql

## Projekte

### Projekt 1 — Straßenkarte Landkreis Stade
- Datenquelle: OpenStreetMap (Geofabrik Niedersachsen)
- Import mit osm2pgsql in PostGIS
- Visualisierung in QGIS mit kategorisierter Symbolik
- Ergebnis: Straßenkarte mit Klassifizierung nach Straßentyp

### Projekt 4 — PostGIS Datenbank + SQL-Analyse
- 44 Millionen OSM-Objekte importiert
- SQL-Abfragen mit ST_Length, ST_Transform
- Analyse: Straßenlängen nach Typ, Schulen, Restaurants

## SQL-Abfragen / SQL-Abfragen
```sql
-- Alle Schulen im Landkreis Stade
SELECT name, amenity
FROM planet_osm_point
WHERE amenity = 'school'
ORDER BY name;

-- Straßenlängen nach Typ (in km)
SELECT highway,
       ROUND(SUM(ST_Length(ST_Transform(way, 4326)::geography)) / 1000) AS laenge_km
FROM planet_osm_line
WHERE highway IS NOT NULL
GROUP BY highway
ORDER BY laenge_km DESC;
```

## Autor / Autor
Maksym Marinin — GIS-Operator mit 17 Jahren Erfahrung
Stade, Niedersachsen, Deutschland
