-- Inverted string index with SQL

DROP TABLE IF EXISTS docs01;
CREATE TABLE docs01 (
    id SERIAL,
    doc TEXT,
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS invert01;
CREATE TABLE invert01 (
    keyword TEXT,
    doc_id INTEGER REFERENCES docs01(id) ON DELETE CASCADE
);

INSERT INTO docs01 (doc) VALUES
('one so having a book handy probably will turn out to be helpful'),
('Terminology Interpreter and compiler'),
('Python is a highlevel language intended to be'),
('relatively straightforward for humans to read and write and for'),
('computers to read and process Other highlevel languages include Java'),
('C PHP Ruby Basic Perl JavaScript and many more The actual'),
('hardware inside the Central Processing Unit CPU does not understand'),
('any of these highlevel languages'),
('The CPU understands a language we call machine'),
('language Machine language is very simple and frankly very');

SELECT * FROM docs01;

-- Break document column into one row per word + primary key
SELECT
    D.id,
    s.keyword AS keyword
FROM 
    docs01 AS D,
    unnest(string_to_array(lower(D.doc), ' ')) AS s(keyword)
ORDER BY D.id;


-- Discard duplicate rows
INSERT INTO invert01 (doc_id, keyword)
SELECT
    DISTINCT D.id,
    s.keyword AS keyword
FROM 
    docs01 AS D,
    unnest(string_to_array(lower(D.doc), ' ')) AS s(keyword)
ORDER BY D.id;

SELECT keyword, doc_id FROM invert01 ORDER BY keyword, doc_id LIMIT 10;
