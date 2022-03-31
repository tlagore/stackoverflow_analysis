DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS "languages";
DROP TABLE IF EXISTS posttags;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS known_languages;

CREATE TABLE users (
    "userid" INTEGER,
    "username" TEXT
);

CREATE TABLE "languages" (
    languageid INTEGER,
    language TEXT
);

CREATE TABLE posttags (
    postid INTEGER,
    tag TEXT
);

CREATE TABLE posts (
    postid INTEGER,
    posttypeid INTEGER,
    parentid INTEGER,
    acceptedid INTEGER,
    postdate TEXT,
    score INTEGER,
    postviewcount INTEGER,
    title TEXT,
    userid INTEGER,
    answercount INTEGER,
    commentcount INTEGER,
    favoritecount INTEGER,
    postlastactivdate TEXT
);

CREATE TABLE known_languages (
    userid INTEGER,
    languageid INTEGER,
    language TEXT
);

.mode csv
.import data/posts.csv --skip 1 posts 
.import data/users.csv users
.import data/languages.csv --skip 1 languages
.import data/poststags.csv --skip 1 posttags
.mode list

CREATE UNIQUE INDEX user_index ON users(userid);
CREATE UNIQUE INDEX post_index ON posts(postid);
CREATE UNIQUE INDEX language_index ON languages(languageid);
CREATE INDEX posttag_index on posttags(postid);

-- DELETE any languages that apepar more than once (IDs should be unique)
-- DELETE FROM languages
-- WHERE rowid NOT IN
--     ( SELECT min(rowid)
--         FROM languages
--         GROUP BY language
--         ORDER BY languageid);