DELETE FROM known_languages;

WITH summary AS 
-- summary removes any nulls we want to avoid and checks only for questions 
-- also ensures the tags are only languages
    (SELECT users.userid, posts.postid, posttags.tag AS language FROM posts
        JOIN users ON users.userid == posts.userid
        JOIN posttags ON posttags.postid == posts.postid OR posttags.postid == posts.parentid
        WHERE posts.postid IS NOT NULL
        AND users.userid IS NOT NULL
        AND tag IN (SELECT language FROM languages)),
duplicates AS
    (SELECT postid
        FROM summary GROUP by
        postid
        HAVING COUNT(*) > 1),
filtered AS (
    SELECT * FROM summary
    WHERE postid NOT IN
        (SELECT postid FROM duplicates)
),
-- post_languages_count_of_1 gets only posts that have just 1 language in the tag
post_languages_count_of_1 AS
    (SELECT userid, postid, COUNT(*)
        FROM filtered
        GROUP BY userid, postid
        HAVING COUNT(*) == 1),
-- language_count_gt_1 gets the languages a user has more than 1 question with
language_count_gt_1 AS
    (SELECT userid, language, COUNT(*) AS language_count
    FROM filtered
    GROUP BY userid, language
    HAVING COUNT(*) > 1),
answered_own AS (
    SELECT p2.userid, p2.postid
    FROM posts AS p1
    JOIN posts AS p2
        ON p1.postid == p2.parentid
    WHERE p1.userid == p2.userid
),
-- known_languages filters the summary by inner joining with
-- languages that have a count gt 1 and post languages of just 1
-- also selects only distinct. Users will have 1 language per row
known_languages AS (
    SELECT DISTINCT s.userid, s.language AS language FROM filtered AS s
    INNER JOIN post_languages_count_of_1 AS plc
        ON plc.userid == s.userid AND plc.postid == s.postid
    INNER JOIN language_count_gt_1 AS lc
        ON lc.userid == s.userid and lc.language == s.language
    WHERE
        s.postid NOT IN (SELECT * FROM duplicates)
        AND NOT EXISTS
            (SELECT * FROM answered_own AS ao
            WHERE s.postid == ao.postid AND
                s.userid == ao.userid)
    )
-- finalize the query by group_concating the languages into one row with a user
INSERT INTO known_languages (userid, languageid, language) 
    SELECT kl.userid, l.languageid, kl.language FROM known_languages AS kl
    JOIN languages AS l ON l.language = kl.language
    ORDER BY languageid;