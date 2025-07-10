-- https://www.pg4e.com/lectures/06-JSON.sql

DROP TABLE IF EXISTS jtrack CASCADE;

CREATE TABLE IF NOT EXISTS jtrack(id SERIAL, body JSONB);

-- JSON import with copy, often easier with Python, but for
-- simple JSON without embedded newlines in the JSON values, this is good enough.

-- http://adpgtech.blogplot.com/2014/09/importing-jason-data.html

-- https://www.pg4e.com/code/library.jstxt

\copy jtrack (body) FROM 'library.jstxt' WITH CSV QUOTE E'\x01' DELIMITER E'\x02';

-- Had to use TXT DELIMITER \t instead of the above options. 
SELECT COUNT(*) FROM jtrack;

SELECT * FROM jtrack LIMIT 5;
SELECT pg_typeof(body) FROM jtrack LIMIT 1;

SELECT body->>'name' FROM jtrack LIMIT 5;

-- Could we use parenthesis and cast to convert to text?
SELECT pg_typeof(body->'name') FROM jtrack LIMIT 1;
SELECT pg_typeof(body->'name'::text) FROM jtrack LIMIT 1;
SELECT pg_typeof(body->'name')::text FROM jtrack LIMIT 1;
SELECT pg_typeof((body->'name')::text) FROM jtrack LIMIT 1;

-- Yes we could, but why even try? 
SELECT pg_typeof(body->>'name') FROM jtrack LIMIT 1;

SELECT MAX((body->>'count')::int) FROM jtrack;

SELECT body->>'name' AS name FROM jtrack ORDER BY (body->>'count')::int DESC LIMIT 5;

-- Yes you need the cast even though it is an integer in the JSON 
SELECT pg_typeof(body->'count') FROM jtrack LIMIT 1;
SELECT pg_typeof(body->>'count') FROM jtrack LIMIT 1;

-- Look into JSON for a value
SELECT COUNT(*) FROM jtrack WHERE body->>'name' = 'Summer Nights';

-- Ask if the body contains a key/value pair
SELECT COUNT(*) FROM jtrack WHERE body @> '{"name": "Summer Nights"}';

-- Adding something to the JSONB column
UPDATE jtrack SET body = body || '{"favorite": "yes"}' WHERE (body->'count')::int > 200;

-- Should see some with and without "favorite"
SELECT body FROM jtrack WHERE (body->'count')::int > 160 LIMIT 5;

-- We have an operator to check is a tag is present
SELECT COUNT(*) FROM jtrack WHERE body ? 'favorite';

-- https://bitnine.net/blog-postgresql/postgresql-internals-jsonb-type-and-its-indexes/

-- Lets throw SOME bulk INTO the table
INSERT INTO jtrack (body)
SELECT ('{ "type": "Neon", "series": "24 Hours of Lemons", "number": ' || generate_series(1000,5000) || '}')::jsonb;

-- Prepare three indexes...
DROP INDEX jtrack_btree;
DROP INDEX jtrack_gin;
DROP INDEX jtrack_gin_path_ops;

CREATE INDEX jtrack_btree ON jtrack USING BTREE ((body->>'name'));
CREATE INDEX jtrack_gin ON jtrack USING gin (body);
CREATE INDEX jtrack_gin_path_ops ON jtrack USING gin (body jsonb_path_ops);

-- Might need to wait a little while, while PostgreSQL catches up
-- See which query uses which index
EXPLAIN SELECT COUNT(*) FROM jtrack WHERE body->>'artist' = 'Queen';

-- BTREE
EXPLAIN SELECT COUNT(*) FROM jtrack WHERE body->>'name' = 'Summer Nights';

-- gin
EXPLAIN SELECT COUNT(*) FROM jtrack WHERE body ? 'favorite';

-- gin_path_ops (key-value pairs)
EXPLAIN SELECT COUNT(*) FROM jtrack WHERE body @> '{"name": "Summer Nights"}';
EXPLAIN SELECT COUNT(*) FROM jtrack WHERE body @> '{"artist": "Queen"}';
EXPLAIN SELECT COUNT(*) FROM jtrack WHERE body @> '{"name": "Folsom Prison Blues", "artist": "Johnny Cash"}';

-- https://stackoverflow.com/questions/30074452/how-to-update-a-jsonb-columns-field-in-postgresql

-- Updating a numeric field in JSONB

-- Failure and then success
SELECT (body->'count') + 1 FROM jtrack LIMIT 1;
SELECT (body->'count')::int + 1 FROM jtrack LIMIT 1;

SELECT (body->>'count')::int FROM jtrack WHERE body->>'name' = 'Summer Nights';
SELECT ( (body->>'count')::int + 1 ) FROM jtrack WHERE body->>'name' = 'Summer Nights';

UPDATE jtrack SET body = jsonb_set(body, '{ count }', ( (body->>'count')::int + 1 )::text::jsonb )
WHERE body->>'name' = 'Summer Nights';

-- Don't want to run out of space for data or indexes
DROP TABLE IF EXISTS jtrack CASCADE;