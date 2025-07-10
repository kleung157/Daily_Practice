DROP TABLE IF EXISTS mbox;
CREATE TABLE mbox (
    line TEXT
);

SELECT * FROM mbox LIMIT 5;
SELECT line FROM mbox WHERE line ~ '^From ';
SELECT substring(line, ' (.+@[^ ]+) ') FROM mbox WHERE line ~ '^From ';

SELECT 
    substring(line, ' (.+@[^ ]+) ') AS email,
    COUNT(substring(line, ' (.+@[^ ]+) ')) AS count
FROM mbox 
WHERE line ~ '^From '
GROUP BY email 
ORDER BY count DESC;

SELECT
    email,
    count(email)
FROM (SELECT substring(line, ' (.+@[^ ]+) ') AS email FROM mbox WHERE line ~ '^From ') AS badsub
GROUP BY email
ORDER BY COUNT(email) DESC;

SELECT * FROM taxdata LIMIT 5;

SELECT purpose
FROM taxdata
WHERE purpose ~ '^[A-Z]'
ORDER BY purpose DESC
LIMIT 3;

SELECT purpose
FROM taxdata
WHERE purpose ~ '[.]$'
ORDER BY purpose DESC
LIMIT 10