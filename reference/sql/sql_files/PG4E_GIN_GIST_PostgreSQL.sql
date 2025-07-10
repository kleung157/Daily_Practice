-- Using PostgreSQL built-in features (much easier and more efficient)

-- ts_vector is a special "array" of stemmed words, passed through a stop-word
-- filter + positions within the document
SELECT to_tsvector('english', 'This is SQL and Python and other fun teaching stuff');
SELECT to_tsvector('english', 'More people should learn SQL from UMSI');
SELECT to_tsvector('english', 'UMSI also teaches Python and also SQL');

-- ts_query is an "array" of lower case, stemmed words with
-- stop words removed plus logical operators & = and, ! = not, | = or
SELECT to_tsquery('english', 'teaching');
SELECT to_tsquery('english', 'teaches');
SELECT to_tsquery('english', 'and');
SELECT to_tsquery('english', 'SQL');
SELECT to_tsquery('english', 'Teach | teaches | teaching | and | the | if');

-- Plaintext just pulls out the keywords
SELECT plainto_tsquery('english', 'SQL Python');
SELECT plainto_tsquery('english', 'Teach teaches teaching and the if');

-- A phrase is words that comes in order
SELECT phraseto_tsquery('english', 'SQL Python');

-- Websearch is in PostgreSQL >=11 and a bit like
-- https://www.google.com/advanced_search
SELECT websearch_to_tsquery('english', 'SQL -not Python');

SELECT to_tsquery('english', 'teaching') @@ 
    to_tsvector('english', 'UMSI also teaches Python and also SQL');

-- Lets do an english language inverted index using a tsvector index.

DROP TABLE docs CASCADE;
DROP INDEX gin1;

CREATE TABLE docs(
    id SERIAL,
    doc TEXT,
    PRIMARY KEY(id)
);

CREATE INDEX gin1 ON docs USING gin(to_tsvector('english', doc));

INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');

-- Filler rows
INSERT INTO docs (doc) SELECT 'Neon ' || generate_series(10000, 20000);

SELECT * FROM docs LIMIT 5;

SELECT
    id,
    doc
FROM docs
WHERE to_tsquery('english', 'learn') @@ to_tsvector('english', doc);

EXPLAIN SELECT id, doc FROM docs WHERE to_tsquery('english', 'learn') @@ to_tsvector('english', doc);

-- Creating GiST index (GiST faster than GIN)
DROP INDEX gin1;
EXPLAIN SELECT id, doc FROM docs WHERE to_tsquery('english', 'learn') @@ to_tsvector('english', doc);

CREATE INDEX gin1 ON docs USING gist(to_tsvector('english', doc));
EXPLAIN SELECT id, doc FROM docs WHERE to_tsquery('english', 'learn') @@ to_tsvector('english', doc);




