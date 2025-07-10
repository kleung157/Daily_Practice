CREATE TABLE pg4e_debug (
    id SERIAL,
    query VARCHAR(4096),
    result VARCHAR(4096),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(id)
);

SELECT 
    query,
    result, 
    created_at 
FROM pg4e_debug;

CREATE TABLE pg4e_result (
    id SERIAL,
    link_id INTEGER UNIQUE,
    score FLOAT,
    title VARCHAR(4096),
    note VARCHAR(4096),
    debug_log VARCHAR(8192),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

ALTER TABLE pg4e_debug ADD COLUMN neon373 TEXT;

SELECT neon373 FROM pg4e_debug LIMIT 1;
SELECT * FROM pg4e_debug;