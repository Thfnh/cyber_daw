
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        role VARCHAR(10) NOT NULL DEFAULT 'user'
        CHECK (role IN ('user', 'admin')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS challenges (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    difficulty VARCHAR(20) NOT NULL
        CHECK (difficulty IN ('Easy', 'Medium', 'Hard')),
    points INTEGER NOT NULL CHECK (points > 0),
    flag_hash CHAR(64) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS submissions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    challenge_id BIGINT NOT NULL REFERENCES challenges(id),
    submitted_hash CHAR(64) NOT NULL,
    is_correct BOOLEAN NOT NULL,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS solves (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    challenge_id BIGINT NOT NULL REFERENCES challenges(id),
    solved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, challenge_id)
);

CREATE INDEX IF NOT EXISTS idx_submissions_user_challenge
    ON submissions(user_id, challenge_id);

CREATE INDEX IF NOT EXISTS idx_solves_challenge
    ON solves(challenge_id);

----

INSERT INTO challenges (
    title,
    description,
    category,
    difficulty,
    points,
    flag_hash,
    is_active
)
SELECT
    'SQL Injection - Intro',
    'Study unsafe database query construction in an isolated lab.',
    'SQL Injection',
    'Easy',
    100,
    encode(digest(gen_random_uuid()::text, 'sha256'), 'hex'),
    TRUE
WHERE NOT EXISTS (
    SELECT 1 FROM challenges
    WHERE title = 'SQL Injection - Intro'
);

INSERT INTO challenges (
    title,
    description,
    category,
    difficulty,
    points,
    flag_hash,
    is_active
)
SELECT
    'Access Control - Intro',
    'Investigate object-level authorization in a local training app.',
    'Access Control',
    'Easy',
    150,
    encode(digest(gen_random_uuid()::text, 'sha256'), 'hex'),
    TRUE
WHERE NOT EXISTS (
    SELECT 1 FROM challenges
    WHERE title = 'Access Control - Intro'
);

