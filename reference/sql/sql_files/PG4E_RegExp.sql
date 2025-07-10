-- Regex
DROP TABLE IF EXISTS em;
CREATE TABLE em (
    id SERIAL,
    PRIMARY KEY (id),
    email TEXT
);

INSERT INTO em (email) VALUES ('csev@umich.edu');
INSERT INTO em (email) VALUES ('coleen@umich.edu');
INSERT INTO em (email) VALUES ('sally@uiuc.edu');
INSERT INTO em (email) VALUES ('ted79@umuc.edu');
INSERT INTO em (email) VALUES ('glenn1@apple.com');
INSERT INTO em (email) VALUES ('nbody@apple.com');

SELECT * FROM em;

SELECT email FROM em WHERE email ~ 'umich';
SELECT email FROM em WHERE email ~ '^c';
SELECT email FROM em WHERE email ~ 'edu$';
SELECT email FROM em WHERE email ~ '^[gnt]';
SELECT email FROM em WHERE email ~ '[0-9]';
SELECT email FROM em WHERE email ~ '[0-9][0-9]';

SELECT substring(email FROM '[0-9]+') FROM em WHERE email ~ '[0-9]';
SELECT substring(email FROM '.+@(.*)$') FROM em;
SELECT DISTINCT substring(email FROM '.+@(.*)$') FROM em;
SELECT substring(email FROM '.+@(.*)$') AS domain_name, 
COUNT(substring(email FROM '.+@(.*)$')) AS domain_name_count
FROM em 
GROUP BY domain_name;
SELECT * FROM em WHERE substring(email FROM '.+@(.*)$') = 'umich.edu';

DROP TABLE IF EXISTS tw;
CREATE TABLE tw (
    id SERIAL,
    PRIMARY KEY (id),
    tweet TEXT
);

INSERT INTO tw (tweet) VALUES ('This is #SQL and #FUN stuff');
INSERT INTO tw (tweet) VALUES ('More people should learn #SQL FROM #UMSI');
INSERT INTO tw (tweet) VALUES ('#UMSI also teaches #PYTHON');

SELECT * FROM tw;
SELECT id, tweet FROM tw WHERE tweet ~ '#SQL';
SELECT regexp_matches(tweet, '#([A-Za-z0-9_]+)', 'g') FROM tw;
SELECT DISTINCT regexp_matches(tweet, '#([A-Za-z0-9_]+)', 'g') FROM tw;
SELECT id, regexp_matches(tweet, '#([A-Za-z0-9_]+)', 'g') FROM tw;