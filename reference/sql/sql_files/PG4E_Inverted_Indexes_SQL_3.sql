-- Reverse Index (with stop words) in SQL
DROP TABLE IF EXISTS docs02;
CREATE TABLE docs02 (
    id SERIAL,
    doc TEXT,
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS invert02;
CREATE TABLE invert02 (
    keyword TEXT,
    doc_id INTEGER REFERENCES docs02(id) ON DELETE CASCADE
);

INSERT INTO docs02 (doc) VALUES
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

DROP TABLE IF EXISTS stop_words;
CREATE TABLE stop_words (
    word TEXT UNIQUE
);

INSERT INTO stop_words (word) VALUES
('i'), ('a'), ('about'), ('an'), ('are'), ('as'), ('at'), ('be'),
('by'), ('com'), ('for'), ('from'), ('how'), ('in'), ('is'), ('it'), ('of'),
('on'), ('or'), ('that'), ('the'), ('this'), ('to'), ('was'), ('what'),
('when'), ('where'), ('who'), ('will'), ('with');

SELECT * FROM docs02;
SELECT * FROM stop_words;

SELECT
    DISTINCT D.id,
    s.keyword AS keyword
FROM
    docs02 AS D,
    unnest(string_to_array(lower(D.doc), ' ')) AS s(keyword)
ORDER BY D.id ASC;

SELECT
    DISTINCT D.id,
    s.keyword AS keyword
FROM
    docs02 AS D,
    unnest(string_to_array(lower(D.doc), ' ')) AS s(keyword)
WHERE s.keyword NOT IN (SELECT word FROM stop_words)
ORDER BY D.id ASC;

INSERT INTO invert02 (doc_id, keyword)
SELECT
    DISTINCT D.id,
    s.keyword AS keyword
FROM
    docs02 AS D,
    unnest(string_to_array(lower(D.doc), ' ')) AS s(keyword)
WHERE s.keyword NOT IN (SELECT word FROM stop_words)
ORDER BY D.id ASC;

SELECT keyword, doc_id FROM invert02 ORDER BY keyword, doc_id LIMIT 10;