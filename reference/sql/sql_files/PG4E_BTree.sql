-- Generate Data

SELECT random(), random(), trunc(random()*100);
SELECT repeat('Neon ', 5);
SELECT generate_series(1, 5);
SELECT 'Neon' || generate_series(1,5);

-- [ 'Neon' + sr(x) for x in range(1,6) ]

CREATE TABLE textfun(
    CONTENT TEXT
);

INSERT INTO textfun (content) SELECT 'Neon' || generate_series(1,5);

SELECT * FROM textfun;

DELETE FROM textfun;

-- BTree Index is Default

CREATE INDEX textfun_b ON textfun (content);

SELECT pg_relation_size('textfun'), pg_indexes_size('textfun');

SELECT 
    (CASE WHEN (random() < 0.5)
        THEN 'https://www.pg4e.com/neon/'
        ELSE 'https://www.pg4e.com/LEMONS/'
        END);

SELECT 
    (CASE WHEN (random() < 0.5)
        THEN 'https://www.pg4e.com/neon/'
        ELSE 'https://www.pg4e.com/LEMONS/'
        END) || generate_series(1000, 1005);

INSERT INTO textfun (content)
SELECT 
    (CASE WHEN (random() < 0.5)
        THEN 'https://www.pg4e.com/neon/'
        ELSE 'https://www.pg4e.com/LEMONS/'
        END) || generate_series(100000, 200000);

SELECT pg_relation_size('textfun'), pg_indexes_size('textfun');

SELECT content FROM textfun WHERE content LIKE '%150000%';
SELECT upper(content) FROM textfun WHERE content LIKE '%150000%';
SELECT lower(content) FROM textfun WHERE content LIKE '%150000%';
SELECT right(CONTENT, 4) FROM textfun WHERE content LIKE '%150000%';
SELECT left(CONTENT, 4) FROM textfun WHERE content LIKE '%150000%';
SELECT strpos(CONTENT, 'ttps://') FROM textfun WHERE content LIKE '%150000%';
SELECT substr(CONTENT, 2, 4) FROM textfun WHERE content LIKE '%150000%';
SELECT split_part(CONTENT, '/', 4) FROM textfun WHERE content LIKE '%150000%';
SELECT translate(CONTENT, 'th.p/', 'TH!P_') FROM textfun WHERE content LIKE '%150000%';

-- LIKE-style wild cards
SELECT content FROM textfun WHERE content LIKE '%150000%';
SELECT content FROM textfun WHERE content LIKE '%150_00%';
SELECT content FROM textfun WHERE content IN ('https://www.pg4e.com/neon/150000', 'https://www.pg4e.com/neon/150001');

-- Don't want to fill up the server
DROP TABLE textfun;

SELECT ascii('G');