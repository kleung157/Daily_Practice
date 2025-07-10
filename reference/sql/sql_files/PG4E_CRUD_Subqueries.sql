DROP TABLE IF EXISTS album;
CREATE TABLE album(
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS track;
CREATE TABLE track (
    id SERIAL,
    title VARCHAR(128),
    len INTEGER, 
    rating INTEGER, 
    count INTEGER,
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    UNIQUE(title, album_id),
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS track_raw;
CREATE TABLE track_raw (
    title TEXT,
    artist TEXT,
    album TEXT,
    album_id INTEGER,
    count INTEGER,
    rating INTEGER,
    len INTEGER
);


INSERT INTO album (title) SELECT DISTINCT album FROM track_raw ORDER BY album;

SELECT * FROM album;

UPDATE track_raw SET album_id = (SELECT album.id FROM album WHERE album.title = track_raw.album);

INSERT INTO track (title, album_id) SELECT title, album_id FROM track_raw;

SELECT * FROM track;

SELECT * FROM track_raw;

SELECT 
    track.title AS track, 
    album.title AS album
FROM track
JOIN album
    ON track.album_id = album.id
ORDER BY track.title 
LIMIT 3;