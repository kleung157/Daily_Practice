-- Strings, arrays, and rows
SELECT string_to_array('Hello World', ' ');
SELECT unnest(string_to_array('Hello World', ' '));

-- Inverted string index with SQL
DROP TABLE IF EXISTS docs;
CREATE TABLE docs (
    id SERIAL,
    doc TEXT,
    PRIMARY KEY (id)
);

INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');

SELECT * FROM docs;

-- Break the document column into one row per word + primary key
SELECT
    D.id,
    s.keyword AS keyword
FROM 
    docs AS D,
    unnest(string_to_array(D.doc, ' ')) AS s(keyword)
ORDER BY id;

-- Discard duplicate rows
SELECT
    DISTINCT D.id,
    s.keyword AS keyword
FROM 
    docs AS D,
    unnest(string_to_array(D.doc, ' ')) AS s(keyword)
ORDER BY id;

DROP TABLE IF EXISTS docs_gin;
CREATE TABLE docs_gin(
    keyword TEXT,
    doc_id INTEGER REFERENCES docs(id) ON DELETE CASCADE
);

-- Insert the key word / primary key rows into a table
INSERT INTO docs_gin (doc_id, keyword)
SELECT 
    DISTINCT D.id,
    s.keyword AS keyword
FROM 
    docs AS D,
    unnest(string_to_array(D.doc, ' ')) AS s(keyword)
ORDER BY id;
    
SELECT * FROM docs_gin ORDER BY doc_id;

-- Find all the distinct documents that match a keyword
SELECT 
    DISTINCT G.doc_id, 
    G. keyword
FROM docs_gin AS G
WHERE G.keyword = 'UMSI';

SELECT 
    DISTINCT D.id,
    D.doc
FROM docs AS D
JOIN docs_gin AS G
    ON D.id = G.doc_id
WHERE G.keyword = 'UMSI';

-- We can remove duplicates and have more than one keyword
SELECT DISTINCT D.doc
FROM docs AS D
JOIN docs_gin AS G
    ON D.id = G.doc_id
WHERE G.keyword IN ('fun', 'keyword');

-- We can handle a phrase
SELECT DISTINCT D.doc
FROM docs AS D
JOIN docs_gin AS G
    ON D.id = G.doc_id
WHERE G.keyword = ANY(string_to_array('I want to learn', ' '));

-- This can go sideways - (foreshadowing atop words)
SELECT 
    DISTINCT D.id, 
    D.doc
FROM docs AS D
JOIN docs_gin AS G
    ON D.id = G.doc_id
WHERE G.keyword = ANY(string_to_array('Search for Lemons and Neons', ' '));

