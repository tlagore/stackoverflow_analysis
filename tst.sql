WITH language_names AS
    (SELECT language FROM languages),
-- summary removes any nulls we want to avoid and checks only for questions 
-- also ensures the tags are only languages
summary AS 
    (SELECT users.userid, posts.postid, posttags.tag AS language FROM posts 
        JOIN users ON users.userid == posts.userid 
        JOIN posttags ON posttags.postid == posts.postid 
        WHERE posts.postid IS NOT NULL
        AND users.userid IS NOT NULL 
        AND posts.parentid IS NOT NULL
        AND tag IN (SELECT * FROM language_names)
        AND posts.posttypeid == 1
        AND users.userid == 8124507),
-- post_languages_count_of_1 gets only posts that have just 1 language in the tag
post_languages_count_of_1 AS
    (SELECT userid, postid, COUNT(*)
        FROM summary
        GROUP BY userid, postid
        HAVING COUNT(*) == 1),
-- language_count_gt_1 gets the languages a user has more than 1 question with
language_count_gt_1 AS 
    (SELECT userid, language, COUNT(*) AS language_count
    FROM summary
    GROUP BY userid, language
    HAVING COUNT(*) > 1),
-- known_languages filters the summary by inner joining with 
-- languages that have a count gt 1 and post languages of just 1
-- also selects only distinct. Users will have 1 language per row
known_languages AS (
    SELECT DISTINCT s.userid, s.language AS languages FROM summary AS s
    INNER JOIN post_languages_count_of_1 AS plc 
        ON plc.userid == s.userid AND plc.postid == s.postid
    INNER JOIN language_count_gt_1 AS lc 
        ON lc.userid == s.userid AND lc.language == s.language
    and lc.language == 'javascript' OR lc.language == 'php'
    )
-- finalize the query by group_concating the languages into one row with a user
SELECT * FROM language_count_gt_1;



SELECT users.userid, posts.postid, posttags.tag AS language FROM posts 
        JOIN users ON users.userid == posts.userid 
        JOIN posttags ON posttags.postid == posts.postid 
        WHERE posts.postid IS NOT NULL
        AND users.userid IS NOT NULL 
        AND posts.parentid IS NOT NULL
        AND tag IN (SELECT language FROM languages)
        AND posts.posttypeid == 1
        AND users.userid == 1324631;


WITH summary AS 
-- summary removes any nulls we want to avoid and checks only for questions 
-- also ensures the tags are only languages
    (SELECT users.userid, posts.postid, posttags.tag AS language FROM posts 
        JOIN users ON users.userid == posts.userid 
        JOIN posttags ON posttags.postid == posts.postid OR posttags.postid == posts.parentid
        WHERE posts.postid IS NOT NULL
        AND users.userid IS NOT NULL 
        -- AND posts.parentid IS NOT NULL
        AND tag IN (SELECT language FROM languages)),
-- post_languages_count_of_1 gets only posts that have just 1 language in the tag
post_languages_count_of_1 AS
    (SELECT userid, postid, COUNT(*)
        FROM summary
        GROUP BY userid, postid
        HAVING COUNT(*) == 1),
-- language_count_gt_1 gets the languages a user has more than 1 question with
language_count_gt_1 AS 
    (SELECT userid, language, COUNT(*) AS language_count
    FROM summary
    GROUP BY userid, language
    HAVING COUNT(*) > 1),
-- known_languages filters the summary by inner joining with 
-- languages that have a count gt 1 and post languages of just 1
-- also selects only distinct. Users will have 1 language per row
known_languages AS (
    SELECT DISTINCT s.userid, s.language AS languages FROM summary AS s
    INNER JOIN post_languages_count_of_1 AS plc 
        ON plc.userid == s.userid AND plc.postid == s.postid
    INNER JOIN language_count_gt_1 AS lc 
        ON lc.userid == s.userid and lc.language == s.language
    )
-- finalize the query by group_concating the languages into one row with a user
SELECT userid, group_concat(languages)
    FROM known_languages
    GROUP BY userid
    HAVING COUNT(*) > 1;


-----------------------------------------------------
-- THE OG!
WITH summary AS 
-- summary removes any nulls we want to avoid and checks only for questions 
-- also ensures the tags are only languages
    (SELECT users.userid, posts.postid, posttags.tag AS language FROM posts 
        JOIN users ON users.userid == posts.userid 
        JOIN posttags ON posttags.postid == posts.postid 
        -- WHERE posts.postid IS NOT NULL
        AND users.userid IS NOT NULL 
        -- AND posts.parentid IS NOT NULL
        AND tag IN (SELECT language FROM languages)),
-- post_languages_count_of_1 gets only posts that have just 1 language in the tag
post_languages_count_of_1 AS
    (SELECT userid, postid, COUNT(*)
        FROM summary
        GROUP BY userid, postid
        HAVING COUNT(*) == 1),
-- language_count_gt_1 gets the languages a user has more than 1 question with
language_count_gt_1 AS 
    (SELECT userid, language, COUNT(*) AS language_count
    FROM summary
    GROUP BY userid, language
    HAVING COUNT(*) > 1),
-- known_languages filters the summary by inner joining with 
-- languages that have a count gt 1 and post languages of just 1
-- also selects only distinct. Users will have 1 language per row
known_languages AS (
    SELECT DISTINCT s.userid, s.language AS languages FROM summary AS s
    INNER JOIN post_languages_count_of_1 AS plc 
        ON plc.userid == s.userid AND plc.postid == s.postid
    INNER JOIN language_count_gt_1 AS lc 
        ON lc.userid == s.userid and lc.language == s.language
    )
-- finalize the query by group_concating the languages into one row with a user
SELECT userid, group_concat(languages)
    FROM known_languages
    GROUP BY userid
    HAVING COUNT(*) > 1;
-------------------------------------------------