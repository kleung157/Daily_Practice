DROP TABLE IF EXISTS unesco_raw;
CREATE TABLE unesco_raw (
    name TEXT,
    description TEXT,
    justification TEXT,
    year INTEGER,
    longitude FLOAT,
    latitude FLOAT,
    area_hectares FLOAT,
    category TEXT,
    category_id INTEGER,
    state TEXT,
    state_id INTEGER,
    region TEXT,
    region_id INTEGER,
    iso TEXT,
    iso_id INTEGER
);

DROP TABLE IF EXISTS category;
CREATE TABLE category (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS state;
CREATE TABLE state (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS region;
CREATE TABLE region (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS iso;
CREATE TABLE iso (
    id SERIAL,
    name VARCHAR(128) NOT NULL UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS unesco;
CREATE TABLE unesco (
    name TEXT,
    year INTEGER,
    category_id INTEGER,
    state_id INTEGER,
    region_id INTEGER,
    iso_id INTEGER
);

INSERT INTO category (name) SELECT DISTINCT category FROM unesco_raw ORDER BY category;
SELECT * FROM category;

INSERT INTO state (name) SELECT DISTINCT state FROM unesco_raw ORDER BY state;
SELECT * FROM state;

INSERT INTO region (name) SELECT DISTINCT region FROM unesco_raw ORDER BY region;
SELECT * FROM region;

INSERT INTO iso (name) SELECT DISTINCT iso FROM unesco_raw ORDER BY iso;
SELECT * FROM iso;

UPDATE unesco_raw SET category_id = (SELECT category.id FROM category WHERE category.name = unesco_raw.category);
UPDATE unesco_raw SET state_id = (SELECT state.id FROM state WHERE state.name = unesco_raw.state);
UPDATE unesco_raw SET region_id = (SELECT region.id FROM region WHERE region.name = unesco_raw.region);
UPDATE unesco_raw SET iso_id = (SELECT iso.id FROM iso WHERE iso.name = unesco_raw.iso);
SELECT * FROM unesco_raw

INSERT INTO unesco (name, YEAR, category_id, state_id, region_id, iso_id) SELECT name, YEAR, category_id, state_id, region_id, iso_id FROM unesco_raw;
SELECT * FROM unesco;

SELECT 
    unesco.name AS Name,
    YEAR AS Year,
    category.name AS Category,
    state.name AS State,
    region.name AS Region,
    iso.name AS Iso
FROM unesco
JOIN category
    ON unesco.category_id = category.id
JOIN state
    ON unesco.state_id = state.id
JOIN region
    ON unesco.region_id = region.id
JOIN iso
    ON unesco.iso_id = iso.id
ORDER BY 
    region.name, 
    unesco.name
LIMIT 3;



