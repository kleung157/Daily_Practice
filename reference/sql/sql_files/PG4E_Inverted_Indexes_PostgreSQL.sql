-- Precomputed languages on PostgresSQL
SELECT cfgname FROM pg_ts_config;

/* (1) Ignore the case of words in the index and in the query
   (2) Don't index low-meaning "stop words" that we will ignore if they are in a search query */
DROP TABLE IF EXISTS docs CASCADE;
CREATE TABLE docs (
    id SERIAL,
    doc TEXT,
    PRIMARY KEY(id)
);

INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');

SELECT * FROM docs;

-- Break the document column into one row per word + primary key
SELECT 
    DISTINCT D.id,
    s.keyword AS keyword
FROM 
    docs AS D,
    unnest(string_to_array(D.doc, ' ')) AS s(keyword)
ORDER BY D.id;

-- Lower case it all
SELECT
    DISTINCT D.id,
    s.keyword AS keyword
FROM 
    docs AS D,
    unnest(string_to_array(lower(D.doc), ' ')) AS s(keyword)
ORDER BY D.id;

DROP TABLE IF EXISTS docs_gin CASCADE;
CREATE TABLE docs_gin (
    keyword TEXT,
    doc_id INTEGER REFERENCES docs(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS stop_words;
CREATE TABLE stop_words (
    word TEXT UNIQUE
);

INSERT INTO stop_words (word) VALUES ('is'), ('this'), ('and');

-- All we do is throw out the words in the stop word list
SELECT
    DISTINCT D.id,
    s.keyword AS keyword
FROM 
    docs AS D,
    unnest(string_to_array(lower(D.doc), ' ')) AS s(keyword)
WHERE s.keyword NOT IN (SELECT word FROM stop_words)
ORDER BY id;

-- Put the stop-word free list into the GIN
INSERT INTO docs_gin (doc_id, keyword)
SELECT
    DISTINCT D.id,
    s.keyword AS keyword
FROM 
    docs AS D,
    unnest(string_to_array(lower(D.doc), ' ')) AS s(keyword)
WHERE s.keyword NOT IN (SELECT word FROM stop_words)
ORDER BY id;

SELECT * FROM docs_gin;

-- A one word query
SELECT DISTINCT D.doc
FROM docs AS D
JOIN docs_gin AS G
    ON D.id = G.doc_id
WHERE G.keyword = lower('UMSI');

-- A multi-word query
SELECT DISTINCT D.doc
FROM docs AS D
JOIN docs_gin AS G
    ON D.id = G.doc_id
WHERE G.keyword = ANY(string_to_array(lower('Meet fun people'), ' '));

-- A stop word query - as if it were never there
SELECT DISTINCT D.doc
FROM docs AS D
JOIN docs_gin AS G
    ON D.id = G.doc_id
WHERE G.keyword = lower('and');

-- Add stemming

-- We can make the index even smaller
-- (3) Only store the "stems" of words

-- Our simple approach is to make a "dictionary" of word -> stem
DROP TABLE IF EXISTS docs_stem;
CREATE TABLE docs_stem (
    word TEXT,
    stem TEXT
);

INSERT INTO docs_stem (word, stem) VALUES ('teaching', 'teach'), ('teaches', 'teach')

SELECT * FROM docs_stem;

-- Move the initial word extraction into a sub-query
SELECT
    id,
    keyword
FROM (
    SELECT 
        DISTINCT D.id,
        s.keyword AS keyword
    FROM 
        docs AS D,
        unnest(string_to_array(lower(D.doc), ' ')) AS s(keyword)
    ) AS X;

-- Add the stems as third column (may or may not exist)
SELECT
    id,
    keyword,
    stem
FROM (
    SELECT 
        DISTINCT D.id,
        s.keyword AS keyword
    FROM 
        docs AS D,
        unnest(string_to_array(lower(D.doc), ' ')) AS s(keyword)
    ) AS K
LEFT JOIN docs_stem AS S
   ON K.keyword = S.word;

-- If the stem is there, use it
SELECT 
    id,
    CASE 
	    WHEN stem IS NOT NULL THEN stem ELSE keyword END AS awesome, 
    keyword, 
    stem
FROM (
    SELECT 
        DISTINCT D.id,
        lower(s.keyword) AS keyword
    FROM 
        docs AS D,
        unnest(string_to_array(D.doc, ' ')) AS s(keyword)
    ) AS K
LEFT JOIN docs_stem AS S
   ON K.keyword = S.word;

-- Null Coalescing - return the first non-null in a list
-- x = stem or 'teaching'  # Python
SELECT COALESCE(NULL, NULL, 'umsi');
SELECT COALESCE('umsi', NULL, 'SQL');

-- If the stem is there, use it instead of the keyword
SELECT
    id,
    COALESCE(stem, keyword) AS keyword
FROM (
    SELECT 
        DISTINCT D.id,
        s.keyword AS keyword
    FROM 
        docs AS D,
        unnest(string_to_array(lower(D.doc), ' ')) AS s(keyword)
    ) AS K
LEFT JOIN docs_stem AS S
   ON K.keyword = S.word;

-- Insert only the stems
DELETE FROM docs_gin;

INSERT INTO docs_gin (doc_id, keyword)
SELECT
    id,
    COALESCE(stem, keyword) AS keyword
FROM (
    SELECT 
        DISTINCT D.id,
        s.keyword AS keyword
    FROM 
        docs AS D,
        unnest(string_to_array(lower(D.doc), ' ')) AS s(keyword)
    ) AS K
LEFT JOIN docs_stem AS S
   ON K.keyword = S.word;

SELECT * FROM docs_gin;

-- Let's do stop words and stems...
DELETE FROM docs_gin;

INSERT INTO docs_gin (doc_id, keyword)
SELECT
    id,
    COALESCE(stem, keyword) AS keyword
FROM (
    SELECT 
        DISTINCT D.id,
        s.keyword AS keyword
    FROM 
        docs AS D,
        unnest(string_to_array(lower(D.doc), ' ')) AS s(keyword)
    WHERE s.keyword NOT IN (SELECT word FROM stop_words)
    ) AS K
LEFT JOIN docs_stem AS S
   ON K.keyword = S.word;

SELECT * FROM docs_gin;

-- Let's do some queries
SELECT 
    COALESCE( (SELECT stem FROM docs_stem WHERE word = lower('SQL')), lower('SQL') );

-- Handling the stems in queries. Use the keyword if there is no stem.
SELECT
    DISTINCT doc
FROM docs AS D
JOIN docs_gin AS G
    ON D.id = G.doc_id
WHERE G.keyword = COALESCE( (SELECT stem FROM docs_stem WHERE word = lower('SQL')), lower('SQL') );

-- Prefer the stem over the actual keyword
SELECT COALESCE( (SELECT stem FROM docs_stem WHERE word = lower('teaching')), lower('teaching') );

SELECT
    DISTINCT doc
FROM docs AS D
JOIN docs_gin AS G
    ON D.id = G.doc_id
WHERE G.keyword = COALESCE( (SELECT stem FROM docs_stem WHERE word = lower('teaching')), lower('teaching') );

-- The technical term for converting search terms to their stems is called "conflation"
-- from https://en.wikipedia.org/wiki/Stemming








    