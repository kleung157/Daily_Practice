-- String Array GIN index
DROP TABLE IF EXISTS docs03;
CREATE TABLE docs03 (
    id SERIAL,
    doc TEXT,
    PRIMARY KEY(id)
);

DROP INDEX array03;
CREATE INDEX array03 ON docs03 USING gin(string_to_array(doc, ' ') array_ops);

INSERT INTO docs03 (doc) VALUES
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

INSERT INTO docs03 (doc) SELECT 'Neon ' || generate_series(10000, 20000);

SELECT
    COUNT(*)
FROM docs03;

SELECT
    id,
    doc
FROM docs03
WHERE '{straightforward}' <@ string_to_array(doc, ' ');

EXPLAIN SELECT id, doc FROM docs03 WHERE '{straightforward}' <@ string_to_array(doc, ' ');

SELECT * FROM pg4e_debug;
