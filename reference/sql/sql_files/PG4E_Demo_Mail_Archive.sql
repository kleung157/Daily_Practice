-- Using a natural language index on an email corpus

-- http://mbox.dr-chuck.net/sakai.devel/

-- gmane.py
-- datecompat.py
-- hidden-dist.py

-- gmane.py
-- Pulls data from the web and puts it into messages table
-- Loads at least 300 messages (can be stopped and started)

-- CREATE TABLE if NOT EXISTS messages
-- CREATE TABLE IF NOT EXISTS messages
--    (id SERIAL, email TEXT, sent_at TIMESTAMPTZ,
--     subject TEXT, headers TEXT, body TEXT)

SELECT * FROM messages LIMIT 5;

SELECT COUNT(*) FROM messages;

-- Making a language oriented inverted inde in mail messages
CREATE INDEX messages_gin ON messages USING gin(to_tsvector('english', body));

-- Shows stemming
SELECT to_tsvector('english', body) FROM messages LIMIT 1;

SELECT to_tsquery('english', 'easier');
SELECT to_tsquery('english', 'easy');
SELECT to_tsquery('english', 'notification');

SELECT id, to_tsquery('english', 'neon') @@ to_tsvector('english', body) FROM messages LIMIT 10;
SELECT id, to_tsquery('english', 'notifications') @@ to_tsvector('english', body) FROM messages LIMIT 10;
SELECT id, to_tsquery('english', 'golden') @@ to_tsvector('english', body) FROM messages LIMIT 10;

-- Extract from the headers and make a new column for display purposes
ALTER TABLE messages ADD COLUMN sender TEXT;
SELECT substring(headers, '\nFrom: [^\n]*<([^>]*)') FROM messages LIMIT 10;
UPDATE messages SET sender=substring(headers, '\nFrom: [^\n]*<([^>]*)');

SELECT sender FROM messages LIMIT 10;
SELECT subject, sender FROM messages WHERE to_tsquery('english', 'monday') @@ to_tsvector('english', body) LIMIT 10;

EXPLAIN ANALYZE SELECT subject, sender FROM messages WHERE to_tsquery('english', 'monday') @@ to_tsvector('english', body);

-- We did not make a spanish index 
-- (still works sequential scan but have to create a GIN index in spanish for index scan)
EXPLAIN ANALYZE SELECT subject, sender FROM messages WHERE to_tsquery('spanish', 'monday') @@ to_tsvector('spanish', body);

SELECT subject, sender FROM messages WHERE to_tsquery('spanish', 'monday') @@ to_tsvector('spanish', body);
SELECT to_tsquery('spanish', 'monday');

-- GiST index
DROP INDEX messages_gin;
CREATE INDEX messages_gist ON messages USING gist(to_tsvector('english', body));
DROP INDEX messages_gist;

SELECT subject, sender FROM messages WHERE to_tsquery('english', 'monday') @@ to_tsvector('english', body);
EXPLAIN ANALYZE SELECT subject, sender FROM messages WHERE to_tsquery('english', 'monday') @@ to_tsvector('english', body);

-- https://www.postgresql.org/docs/current/functions-textsearch.html
SELECT id, subject, sender FROM messages WHERE to_tsquery('english', 'personal & learning') @@ to_tsvector('english', body);
SELECT id, subject, sender FROM messages WHERE to_tsquery('english', 'learning & personal') @@ to_tsvector('english', body);

-- Both words but in order
SELECT id, subject, sender FROM messages WHERE to_tsquery('english', 'personal <-> learning') @@ to_tsvector('english', body);
SELECT id, subject, sender FROM messages WHERE to_tsquery('english', 'learning <-> personal') @@ to_tsvector('english', body);
SELECT id, subject, sender FROM messages WHERE to_tsquery('english', '! learning & personal') @@ to_tsvector('english', body);

-- plainto_tsquery() Is tolerant of "syntax errors" in the expression
SELECT id, subject, sender FROM messages WHERE to_tsquery('english', '(personal learning') @@ to_tsvector('english', body);
SELECT id, subject, sender FROM messages WHERE plainto_tsquery('english', '(personal learning') @@ to_tsvector('english', body);

-- phraseto_tsquery() implies followed by
SELECT id, subject, sender FROM messages WHERE to_tsquery('english', 'I <-> think') @@ to_tsvector('english', body);
SELECT id, subject, sender FROM messages WHERE phraseto_tsquery('english', 'I think') @@ to_tsvector('english', body);

-- https://www.postgresql.org/docs/12/textsearch-controls.html#TEXTSEARCH-RANKING
SELECT id, subject, sender,
    ts_rank(to_tsvector('english', body), to_tsquery('english', 'personal & learning')) AS ts_rank
FROM messages 
WHERE to_tsquery('english', 'personal & learning') @@ to_tsvector('english', body)
ORDER BY ts_rank DESC;

-- A different ranking algorithm
SELECT id, subject, sender,
    ts_rank_cd(to_tsvector('english', body), to_tsquery('english', 'personal & learning')) AS ts_rank
FROM messages 
WHERE to_tsquery('english', 'personal & learning') @@ to_tsvector('english', body)
ORDER BY ts_rank DESC;

SELECT id, subject, sender FROM messages WHERE to_tsquery('english', '! personal & learning') @@ to_tsvector('english', body);

-- websearch_to_tsquery is in PostgreSQL > 11
SELECT id, subject, sender FROM messages WHERE websearch_to_tsquery('english', '-personal learning') @@ to_tsvector('english', body) LIMIT 10;

-- Indexing within structured data - Email messages from address (advanced)
SELECT substring(headers, '\nFrom: [^\n]*<([^>]*)') FROM messages LIMIT 10;

-- Extract from the headers and make a new column
ALTER TABLE messages ADD COLUMN sender TEXT;
UPDATE messages SET sender=substring(headers, '\nFrom: [^\n]*<([^>]*)');

CREATE INDEX messages_From ON messages (substring(headers, '\nFrom: [^\n]*<([^>]*)'));

SELECT sender, subject FROM messages WHERE substring(headers, '\nFrom: [^\n]*<([^>]*)') = 'john@caret.cam.ac.uk';
EXPLAIN ANALYZE SELECT sender, subject FROM messages WHERE substring(headers, '\nFrom: [^\n]*<([^>]*)') = 'john@caret.cam.ac.uk';

SELECT subject, substring(headers, '\nLines: ([0-9]*)') AS lines FROM messages LIMIT 100;
SELECT AVG(substring(headers, '\nLines: ([0-9]*)')::integer) FROM messages;




