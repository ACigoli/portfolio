-- Screenshots gallery for projects (JSON array of R2-backed URLs, same
-- stringified-array pattern already used for `technologies`). Useful for
-- private/closed-source projects that can't link a live demo or repo.

ALTER TABLE projects ADD COLUMN images TEXT NOT NULL DEFAULT '[]';
