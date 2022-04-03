DELETE FROM known_languages;

WITH questions AS
    (SELECT 
        posts.postid, posts.parentid, users.userid, posttags.tag AS language FROM posts
        JOIN users ON users.userid == posts.userid
        JOIN posttags ON posttags.postid == posts.postid
        WHERE posts.postid IS NOT NULL
        AND users.userid IS NOT NULL
        AND tag IN (SELECT language FROM languages)),
answers AS 
    (SELECT 
        posts.postid, posts.parentid, users.userid, posttags.tag AS language FROM posts
        JOIN users ON users.userid == posts.userid
        JOIN posttags ON posttags.postid == posts.parentid
        WHERE posts.postid IS NOT NULL
        AND users.userid IS NOT NULL
        AND tag IN (SELECT language FROM languages)),
summary AS
    (SELECT * FROM questions UNION ALL 
    SELECT * FROM answers),
-- first check only for posts that have just 1 language in the list of taggs
post_languages_count_of_1 AS
    (SELECT userid, postid, COUNT(*)
        FROM summary
        GROUP BY userid, postid
        HAVING COUNT(*) == 1),
filtered AS (
    SELECT * FROM summary AS s
    INNER JOIN post_languages_count_of_1 AS plc
        ON plc.userid == s.userid AND plc.postid == s.postid
),
-- ensure each language has been mentioned more than once
language_count_gt_1 AS
    (SELECT userid, language, COUNT(*) AS language_count
    FROM filtered
    GROUP BY userid, language
    HAVING COUNT(*) > 1),
known_languages AS (
    SELECT DISTINCT s.userid, s.language AS language FROM filtered AS s
    INNER JOIN language_count_gt_1 AS lc
        ON lc.userid == s.userid and lc.language == s.language
),
-- remove users that only know one language
users_gt_1_language AS (
    SELECT userid, COUNT(*)
    FROM known_languages
    GROUP BY userid 
    HAVING COUNT(*) > 1
)
INSERT INTO known_languages (userid, languageid, language) 
    SELECT kl.userid, l.languageid, kl.language FROM known_languages AS kl
    INNER JOIN languages AS l ON l.language = kl.language
    INNER JOIN users_gt_1_language AS ug1l ON ug1l.userid == kl.userid
    ORDER BY kl.language;
